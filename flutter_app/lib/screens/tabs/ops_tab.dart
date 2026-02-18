import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/date_utils.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_overlay.dart';

class OpsTab extends StatefulWidget {
  const OpsTab({super.key});

  @override
  State<OpsTab> createState() => _OpsTabState();
}

class _OpsTabState extends State<OpsTab> {
  final _api = ApiService();

  bool _busy = false;

  final _fromCtrl = TextEditingController(text: '01-01-2026');
  final _toCtrl = TextEditingController(text: '31-12-2026');
  bool _includeAudit = true;

  final _monthCtrl = TextEditingController(text: AppDateUtils.todayYmd());
  final _offlineLimitCtrl = TextEditingController(text: '600');

  // Partner-only admin state
  Map<String, dynamic>? _settings;
  Map<String, dynamic>? _calSettings;
  List<Map<String, dynamic>> _users = [];

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _monthCtrl.dispose();
    _offlineLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _downloadFromApi(Future<ApiResponse> future, {required String defaultName}) async {
    setState(() => _busy = true);
    final res = await future;
    setState(() => _busy = false);
    if (!mounted) return;

    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Operation failed', isError: true);
      return;
    }
    final fileName = (res.data is Map ? (res.data['fileName'] ?? defaultName) : defaultName).toString();
    final base64 = (res.data is Map ? (res.data['base64'] ?? '') : '').toString();
    final mime = (res.data is Map ? (res.data['mime'] ?? '') : '').toString();
    await Helpers.downloadBase64File(
      context: context,
      base64Data: base64,
      fileName: fileName,
      mimeType: mime.isEmpty ? null : mime,
    );
  }

  Future<PlatformFile?> _pickXlsx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  Future<void> _uploadXlsxToEndpoint(String endpoint, PlatformFile file, {Map<String, String> fields = const {}}) async {
    final bytes = file.bytes;
    if (bytes == null) {
      Helpers.showSnackBar(context, 'Could not read file bytes', isError: true);
      return;
    }
    setState(() => _busy = true);
    final res = await _api.uploadFile(endpoint, bytes, file.name, fields);
    setState(() => _busy = false);
    if (!mounted) return;

    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Upload failed', isError: true);
      return;
    }
    Helpers.showSnackBar(context, 'Upload complete', isSuccess: true, durationSeconds: 4);
  }

  Future<void> _loadPartnerAdmin() async {
    setState(() => _busy = true);
    final s = await _api.getSettings();
    final c = await _api.getCalendarSettings();
    final u = await _api.listUsers();
    setState(() {
      _busy = false;
      _settings = s.ok && s.data is Map ? Map<String, dynamic>.from(s.data['data'] ?? {}) : null;
      _calSettings = c.ok && c.data is Map ? Map<String, dynamic>.from(c.data['data'] ?? {}) : null;
      _users = (u.ok && u.data is Map && u.data['users'] is List)
          ? List<Map<String, dynamic>>.from(u.data['users'])
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.canAccessOps) {
      return const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Ops locked',
          subtitle: 'Ops & Reports are available to PARTNER and MANAGER roles.',
        ),
      );
    }

    return LoadingOverlay(
      isLoading: _busy,
      message: 'Working…',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              title: 'Ops & Reports',
              subtitle: 'Imports, exports, offline updates, and admin tools',
              accentColor: AppTheme.viewAccents['ops'],
              child: Column(
                children: [
                  _sectionTitle('Import (XLSX)'),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadFromApi(_api.exportImportTemplate(), defaultName: 'Client_Tasks_Import_Template.xlsx'),
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Template'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final f = await _pickXlsx();
                            if (f == null) return;
                            final pwd = await _askText('Import password (optional)');
                            await _uploadXlsxToEndpoint('/tasks_bulkimportxlsx', f, fields: {
                              if (pwd != null && pwd.trim().isNotEmpty) 'importPassword': pwd.trim(),
                            });
                          },
                          icon: const Icon(Icons.upload_file_rounded),
                          label: const Text('Import'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Firm range exports'),
                  TextField(
                    controller: _fromCtrl,
                    decoration: const InputDecoration(labelText: 'From (DD-MM-YYYY)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _toCtrl,
                    decoration: const InputDecoration(labelText: 'To (DD-MM-YYYY)'),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: _includeAudit,
                    onChanged: (v) => setState(() => _includeAudit = v),
                    title: Text('Include history (AuditLogs)', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _downloadFromApi(
                            _api.exportFirmRangeXlsx(fromDmy: _fromCtrl.text.trim(), toDmy: _toCtrl.text.trim(), includeAudit: _includeAudit),
                            defaultName: 'Firm_Range.xlsx',
                          ),
                          child: const Text('XLSX'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _downloadFromApi(
                            _api.reportFirmRangePdf(fromDmy: _fromCtrl.text.trim(), toDmy: _toCtrl.text.trim()),
                            defaultName: 'Firm_Range.pdf',
                          ),
                          child: const Text('PDF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Quick exports'),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _quick('NEXT_7', 'Next 7'),
                      _quick('NEXT_15', 'Next 15'),
                      _quick('NEXT_30', 'Next 30'),
                      _quick('OVERDUE', 'Overdue'),
                      _quick('APPROVAL_PENDING', 'Approval'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Reports'),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _downloadFromApi(_api.reportDailyDigestPdf(), defaultName: 'Daily_Digest.pdf'),
                          child: const Text('Daily digest PDF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _monthCtrl,
                    decoration: const InputDecoration(labelText: 'Month (YYYY-MM-DD; any date in month)'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _downloadFromApi(_api.reportMonthlyPdf(_monthCtrl.text.trim()), defaultName: 'Monthly.pdf'),
                          child: const Text('Monthly PDF'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Offline updates'),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadFromApi(_api.exportTasksUpdateTemplate(), defaultName: 'Tasks_Update_Template.xlsx'),
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Update template'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final limit = int.tryParse(_offlineLimitCtrl.text.trim()) ?? 600;
                            await _downloadFromApi(_api.exportTasksForUpdate(limit: limit), defaultName: 'Tasks_Export_For_Update.xlsx');
                          },
                          icon: const Icon(Icons.download_for_offline_rounded),
                          label: const Text('Export tasks'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _offlineLimitCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Export limit (e.g., 600)'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final f = await _pickXlsx();
                      if (f == null) return;
                      await _uploadXlsxToEndpoint('/tasks_bulkupdate_from_xlsx', f);
                    },
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Upload updates XLSX'),
                  ),
                  const SizedBox(height: 18),
                  if (auth.isPartner) ...[
                    _sectionTitle('Partner admin'),
                    OutlinedButton.icon(
                      onPressed: _loadPartnerAdmin,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Load admin data'),
                    ),
                    const SizedBox(height: 10),
                    if (_settings != null) _settingsCard(),
                    const SizedBox(height: 10),
                    if (_calSettings != null) _calendarCard(),
                    const SizedBox(height: 10),
                    if (_users.isNotEmpty) _usersCard(),
                    const SizedBox(height: 10),
                    _migrateCard(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quick(String mode, String label) {
    return OutlinedButton(
      onPressed: () => _downloadFromApi(_api.quickExport(mode), defaultName: '$mode.xlsx'),
      child: Text(label),
    );
  }

  Widget _sectionTitle(String t) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(t, style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
        ),
      );

  Future<String?> _askText(String title) async {
    final ctrl = TextEditingController();
    final v = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Optional')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Skip')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('OK')),
        ],
      ),
    );
    return v;
  }

  Widget _settingsCard() {
    final digest = TextEditingController(text: ((_settings!['dailyInternalEmails'] ?? []) as List).join('; '));
    final windowDays = TextEditingController(text: (_settings!['dailyWindowDays'] ?? 30).toString());
    bool sendToAssignees = (_settings!['sendDailyToAssignees'] ?? true) == true;

    return GlassCard(
      title: 'Daily digest settings',
      subtitle: 'Partner-only',
      accentColor: AppTheme.purple,
      child: Column(
        children: [
          TextField(controller: digest, decoration: const InputDecoration(labelText: 'Internal emails (;)')),
          const SizedBox(height: 10),
          TextField(controller: windowDays, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Window days')),
          const SizedBox(height: 10),
          SwitchListTile(
            value: sendToAssignees,
            onChanged: (v) => setState(() => sendToAssignees = v),
            title: Text('Send to assignees', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final res = await _api.updateSettings({
                'dailyInternalEmails': digest.text,
                'dailyWindowDays': int.tryParse(windowDays.text) ?? 30,
                'sendDailyToAssignees': sendToAssignees,
              });
              if (!mounted) return;
              if (!res.ok) {
                Helpers.showSnackBar(context, res.error ?? 'Save failed', isError: true);
                return;
              }
              Helpers.showSnackBar(context, 'Saved', isSuccess: true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _calendarCard() {
    final startHH = TextEditingController(text: (_calSettings!['startHH'] ?? 10).toString());
    final endHH = TextEditingController(text: (_calSettings!['endHH'] ?? 12).toString());
    final tz = TextEditingController(text: (_calSettings!['timeZone'] ?? 'Asia/Kolkata').toString());

    return GlassCard(
      title: 'Calendar settings',
      subtitle: 'Partner-only',
      accentColor: AppTheme.teal,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: startHH, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Start HH'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: endHH, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'End HH'))),
            ],
          ),
          const SizedBox(height: 10),
          TextField(controller: tz, decoration: const InputDecoration(labelText: 'Time zone')),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final res = await _api.updateCalendarSettings({
                'startHH': int.tryParse(startHH.text) ?? 10,
                'endHH': int.tryParse(endHH.text) ?? 12,
                'timeZone': tz.text.trim(),
              });
              if (!mounted) return;
              if (!res.ok) {
                Helpers.showSnackBar(context, res.error ?? 'Save failed', isError: true);
                return;
              }
              Helpers.showSnackBar(context, 'Saved', isSuccess: true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _usersCard() {
    return GlassCard(
      title: 'Team',
      subtitle: 'Partner-only role management',
      accentColor: AppTheme.orange,
      child: Column(
        children: _users.take(200).map((u) {
          final email = (u['email'] ?? '').toString();
          final uid = (u['uid'] ?? '').toString();
          final role = (u['role'] ?? 'ASSOCIATE').toString();
          final active = (u['active'] ?? true) == true;
          return ListTile(
            title: Text(email.isEmpty ? uid : email, style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            subtitle: Text('Role: $role • ${active ? "active" : "inactive"}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.edit_rounded),
            onTap: () => _editUser(u),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _editUser(Map<String, dynamic> u) async {
    final uid = (u['uid'] ?? '').toString();
    final role = ValueNotifier<String>((u['role'] ?? 'ASSOCIATE').toString());
    final active = ValueNotifier<bool>((u['active'] ?? true) == true);
    final mgr = TextEditingController(text: (u['managerEmail'] ?? '').toString());
    final name = TextEditingController(text: (u['displayName'] ?? '').toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit user', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 12),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Display name')),
                const SizedBox(height: 10),
                TextField(controller: mgr, decoration: const InputDecoration(labelText: 'Manager email')),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: role,
                  builder: (_, v, __) => DropdownButtonFormField<String>(
                    value: v,
                    items: const [
                      DropdownMenuItem(value: 'PARTNER', child: Text('PARTNER')),
                      DropdownMenuItem(value: 'MANAGER', child: Text('MANAGER')),
                      DropdownMenuItem(value: 'ASSOCIATE', child: Text('ASSOCIATE')),
                    ],
                    onChanged: (x) => role.value = x ?? 'ASSOCIATE',
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<bool>(
                  valueListenable: active,
                  builder: (_, v, __) => SwitchListTile(
                    value: v,
                    onChanged: (x) => active.value = x,
                    title: Text('Active', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => _busy = true);
                          final r1 = await _api.setUserRole(uid: uid, role: role.value, active: active.value);
                          final r2 = await _api.setUserManager(uid: uid, managerEmail: mgr.text.trim());
                          final r3 = await _api.setUserDisplayName(uid: uid, displayName: name.text.trim());
                          setState(() => _busy = false);

                          if (!mounted) return;
                          if (!r1.ok || !r2.ok || !r3.ok) {
                            Helpers.showSnackBar(context, 'Save failed', isError: true);
                            return;
                          }
                          Helpers.showSnackBar(context, 'Saved', isSuccess: true);
                          Navigator.pop(ctx);
                          await _loadPartnerAdmin();
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _migrateCard() {
    return GlassCard(
      title: 'Role migration',
      subtitle: 'Convert legacy WORKER roles to ASSOCIATE',
      accentColor: AppTheme.pink,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                setState(() => _busy = true);
                final res = await _api.migrateRoles(dryRun: true, limit: 800);
                setState(() => _busy = false);
                if (!mounted) return;
                if (!res.ok) {
                  Helpers.showSnackBar(context, res.error ?? 'Dry run failed', isError: true);
                  return;
                }
                Helpers.showSnackBar(context, 'Dry run complete (see logs/server response)', isSuccess: true, durationSeconds: 5);
              },
              child: const Text('Dry run'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Run migration?'),
                    content: const Text('This will update users.role where role == WORKER.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Run')),
                    ],
                  ),
                );
                if (ok != true) return;

                setState(() => _busy = true);
                final res = await _api.migrateRoles(dryRun: false, limit: 800);
                setState(() => _busy = false);
                if (!mounted) return;
                if (!res.ok) {
                  Helpers.showSnackBar(context, res.error ?? 'Migration failed', isError: true);
                  return;
                }
                Helpers.showSnackBar(context, 'Migration done', isSuccess: true);
                await _loadPartnerAdmin();
              },
              child: const Text('Run'),
            ),
          ),
        ],
      ),
    );
  }
}
