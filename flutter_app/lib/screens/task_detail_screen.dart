import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';
import '../models/audit_log_model.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/date_utils.dart';
import '../utils/helpers.dart';
import '../widgets/category_pill.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/priority_pill.dart';
import '../widgets/status_pill.dart';
import 'create_task_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _api = ApiService();
  bool _busy = false;

  Future<void> _setBusy(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  TaskModel? _findTask(AppProvider app) {
    try {
      return app.tasks.firstWhere((t) => t.id == widget.taskId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _download(Future<ApiResponse> f) async {
    await _setBusy(() async {
      final res = await f;
      if (!mounted) return;
      if (!res.ok) {
        Helpers.showSnackBar(context, res.error ?? 'Download failed', isError: true);
        return;
      }
      final fileName = (res.data is Map ? res.data['fileName'] : null)?.toString() ?? 'download.bin';
      final base64 = (res.data is Map ? res.data['base64'] : null)?.toString() ?? '';
      final mime = (res.data is Map ? res.data['mime'] : null)?.toString();
      await Helpers.downloadBase64File(context: context, base64Data: base64, fileName: fileName, mimeType: mime);
    });
  }

  Future<void> _uploadAttachment(String taskId) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      Helpers.showSnackBar(context, 'Could not read file bytes', isError: true);
      return;
    }
    final type = await _pickDocType();
    if (type == null) return;

    await _setBusy(() async {
      final res = await _api.uploadFile(
        '/tasks_uploadattachment',
        bytes,
        file.name,
        {'taskId': taskId, 'type': type},
      );
      if (!mounted) return;
      if (!res.ok) {
        Helpers.showSnackBar(context, res.error ?? 'Upload failed', isError: true);
        return;
      }
      Helpers.showSnackBar(context, 'Uploaded', isSuccess: true);
    });
  }

  Future<String?> _pickDocType() async {
    final types = ['CHALLAN', 'RETURN', 'ACK', 'OTHER'];
    return await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text('Document type', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
            ),
            ...types.map((t) => ListTile(
                  title: Text(t),
                  onTap: () => Navigator.pop(ctx, t),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnackBar(context, 'Could not open link: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final task = _findTask(app);

    return LoadingOverlay(
      isLoading: _busy,
      message: 'Working…',
      child: Scaffold(
        appBar: AppBar(
          title: Text(task?.title ?? 'Task'),
          actions: [
            IconButton(
              tooltip: 'Create one task',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTaskScreen(oneOnly: true)),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: task == null
            ? const Center(child: LoadingIndicator(size: 44))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    GlassCard(
                      title: 'Quick info',
                      subtitle: 'Status, dates, calendar, exports',
                      accentColor: AppTheme.primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              StatusPill.forTask(task),
                              CategoryPill(category: task.category ?? 'OTHER'),
                              PriorityPill(priority: task.priority ?? 'MEDIUM'),
                              if ((task.seriesId ?? '').isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.purple.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('SERIES', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.purple, fontSize: 11)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${app.getClientName(task.clientId) ?? task.clientName ?? "No client"}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start: ${AppDateUtils.ymdToDmy(task.startDateYmd)} • Due: ${AppDateUtils.ymdToDmy(task.dueDateYmd)}\n'
                            'Assignee: ${task.assignedToEmail ?? "—"}\n'
                            'Start mail sent: ${task.clientStartMailSent ? "Yes" : "No"}',
                            style: GoogleFonts.inter(color: AppTheme.gray, fontWeight: FontWeight.w600, height: 1.3),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if ((task.calendarHtmlLink ?? '').isNotEmpty)
                                OutlinedButton.icon(
                                  onPressed: () => _openLink(task.calendarHtmlLink!),
                                  icon: const Icon(Icons.calendar_month_rounded),
                                  label: const Text('Open Calendar'),
                                ),
                              OutlinedButton.icon(
                                onPressed: () => _download(_api.exportTaskHistoryXlsx(task.id)),
                                icon: const Icon(Icons.grid_on_rounded),
                                label: const Text('History XLSX'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _download(_api.reportTaskHistoryPdf(task.id)),
                                icon: const Icon(Icons.picture_as_pdf_rounded),
                                label: const Text('History PDF'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StatusUpdateCard(task: task),
                    const SizedBox(height: 14),
                    if (auth.canEditDetails) ...[
                      _EditDetailsCard(task: task),
                      const SizedBox(height: 14),
                    ],
                    _AttachmentsCard(task: task, onUpload: () => _uploadAttachment(task.id)),
                    const SizedBox(height: 14),
                    _CommentsCard(taskId: task.id),
                    const SizedBox(height: 14),
                    _TimelineCard(taskId: task.id),
                    const SizedBox(height: 22),
                    _DangerZone(task: task),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatusUpdateCard extends StatefulWidget {
  final TaskModel task;
  const _StatusUpdateCard({required this.task});

  @override
  State<_StatusUpdateCard> createState() => _StatusUpdateCardState();
}

class _StatusUpdateCardState extends State<_StatusUpdateCard> {
  final _api = ApiService();
  String _status = '';
  final _note = TextEditingController();
  String _delayReason = '';
  final _delayNotes = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status ?? 'PENDING';
    _note.text = widget.task.statusNote ?? '';
    _delayReason = widget.task.delayReason ?? '';
    _delayNotes.text = widget.task.delayNotes ?? '';
  }

  @override
  void dispose() {
    _note.dispose();
    _delayNotes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final res = await _api.updateTaskStatus(
      taskId: widget.task.id,
      newStatus: _status,
      statusNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
      delayReason: _delayReason.isEmpty ? null : _delayReason,
      delayNotes: _delayNotes.text.trim().isEmpty ? null : _delayNotes.text.trim(),
    );
    setState(() => _busy = false);
    if (!mounted) return;
    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Save failed', isError: true);
      return;
    }
    Helpers.showSnackBar(context, 'Status saved', isSuccess: true);
  }

  Future<void> _snooze() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked == null) return;
    final ymd = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    setState(() => _busy = true);
    final res = await _api.bulkUpdate(taskIds: [widget.task.id], op: 'SNOOZE', payload: {'snoozedUntilYmd': ymd});
    setState(() => _busy = false);
    if (!mounted) return;
    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Snooze failed', isError: true);
      return;
    }
    Helpers.showSnackBar(context, 'Snoozed', isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'Update status',
      subtitle: 'Includes delay reason + notes',
      accentColor: AppTheme.warning,
      trailing: _busy ? const LoadingIndicator() : null,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _status,
            items: AppConstants.taskStatuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: _busy ? null : (v) => setState(() => _status = v ?? _status),
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Status note (optional)'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _delayReason.isEmpty ? null : _delayReason,
            items: const [
              DropdownMenuItem(value: 'CLIENT_DELAY', child: Text('CLIENT_DELAY')),
              DropdownMenuItem(value: 'INTERNAL_DELAY', child: Text('INTERNAL_DELAY')),
            ],
            onChanged: _busy ? null : (v) => setState(() => _delayReason = v ?? ''),
            decoration: const InputDecoration(labelText: 'Delay reason (optional)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _delayNotes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Delay notes (optional)'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _snooze,
                  icon: const Icon(Icons.snooze_rounded),
                  label: const Text('Snooze'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditDetailsCard extends StatefulWidget {
  final TaskModel task;
  const _EditDetailsCard({required this.task});

  @override
  State<_EditDetailsCard> createState() => _EditDetailsCardState();
}

class _EditDetailsCardState extends State<_EditDetailsCard> {
  final _api = ApiService();
  bool _busy = false;
  bool _applySeries = false;

  late TextEditingController _title;
  late TextEditingController _type;
  late TextEditingController _due;
  late TextEditingController _trigger;
  late TextEditingController _snooze;
  late TextEditingController _assignee;

  String _category = 'OTHER';
  String _priority = 'MEDIUM';

  // start mail
  bool _sendStart = true;
  late TextEditingController _to;
  late TextEditingController _cc;
  late TextEditingController _bcc;
  bool _ccAssigneeStart = false;
  bool _ccManagerStart = false;
  late TextEditingController _startSubj;
  late TextEditingController _startBody;

  // completion mail
  bool _sendComp = true;
  late TextEditingController _compSubj;
  late TextEditingController _compBody;
  bool _ccAssigneeComp = false;
  bool _ccManagerComp = false;

  @override
  void initState() {
    super.initState();

    final t = widget.task;

    _title = TextEditingController(text: t.title);
    _type = TextEditingController(text: t.type ?? '');

    _category = t.normalizedCategory;
    _priority = t.normalizedPriority;

    _due = TextEditingController(text: AppDateUtils.ymdToDmy(t.dueDateYmd));
    _trigger = TextEditingController(text: (t.triggerDaysBefore ?? 15).toString());
    _snooze = TextEditingController(text: AppDateUtils.ymdToDmy(t.snoozedUntilYmd));
    _assignee = TextEditingController(text: t.assignedToEmail ?? '');

    _sendStart = t.sendClientStartMail;
    _to = TextEditingController(text: Helpers.joinEmails(t.clientToEmails));
    _cc = TextEditingController(text: Helpers.joinEmails(t.clientCcEmails));
    _bcc = TextEditingController(text: Helpers.joinEmails(t.clientBccEmails));
    _ccAssigneeStart = t.ccAssigneeOnClientStart;
    _ccManagerStart = t.ccManagerOnClientStart;
    _startSubj = TextEditingController(text: t.clientStartSubject ?? '');
    _startBody = TextEditingController(text: t.clientStartBody ?? '');

    _sendComp = t.sendClientCompletionMail;
    _ccAssigneeComp = t.ccAssigneeOnCompletion;
    _ccManagerComp = t.ccManagerOnCompletion;
    _compSubj = TextEditingController(text: t.clientCompletionSubject ?? '');
    _compBody = TextEditingController(text: t.clientCompletionBody ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _type.dispose();
    _due.dispose();
    _trigger.dispose();
    _snooze.dispose();
    _assignee.dispose();

    _to.dispose();
    _cc.dispose();
    _bcc.dispose();
    _startSubj.dispose();
    _startBody.dispose();

    _compSubj.dispose();
    _compBody.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);

    String? dueYmd;
    if (_due.text.trim().isNotEmpty) {
      try {
        dueYmd = AppDateUtils.dmyToYmd(_due.text.trim());
      } catch (e) {
        setState(() => _busy = false);
        if (!mounted) return;
        Helpers.showSnackBar(context, e.toString(), isError: true);
        return;
      }
    }

    String? snoozeYmd;
    if (_snooze.text.trim().isNotEmpty) {
      try {
        snoozeYmd = AppDateUtils.dmyToYmd(_snooze.text.trim());
      } catch (e) {
        setState(() => _busy = false);
        if (!mounted) return;
        Helpers.showSnackBar(context, e.toString(), isError: true);
        return;
      }
    }

    final res = await _api.updateTask({
      'taskId': widget.task.id,
      'applyToSeries': _applySeries,
      'title': _title.text.trim(),
      'type': _type.text.trim(),
      'category': _category,
      'priority': _priority,
      'dueDateYmd': dueYmd,
      'triggerDaysBefore': int.tryParse(_trigger.text.trim()) ?? 15,
      'snoozedUntilYmd': snoozeYmd,
      'assignedToEmail': _assignee.text.trim(),

      'sendClientStartMail': _sendStart,
      'clientToEmails': Helpers.parseEmailList(_to.text),
      'clientCcEmails': Helpers.parseEmailList(_cc.text),
      'clientBccEmails': Helpers.parseEmailList(_bcc.text),
      'ccAssigneeOnClientStart': _ccAssigneeStart,
      'ccManagerOnClientStart': _ccManagerStart,
      'clientStartSubject': _startSubj.text,
      'clientStartBody': _startBody.text,

      'sendClientCompletionMail': _sendComp,
      'ccAssigneeOnCompletion': _ccAssigneeComp,
      'ccManagerOnCompletion': _ccManagerComp,
      'clientCompletionSubject': _compSubj.text,
      'clientCompletionBody': _compBody.text,
    });

    setState(() => _busy = false);
    if (!mounted) return;

    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Save failed', isError: true);
      return;
    }
    Helpers.showSnackBar(context, 'Saved', isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    final hasSeries = (widget.task.seriesId ?? '').isNotEmpty;

    return GlassCard(
      title: 'Edit details',
      subtitle: hasSeries ? 'Series available (apply-to-series supported)' : 'One task only',
      accentColor: AppTheme.purple,
      trailing: _busy ? const LoadingIndicator() : null,
      child: Column(
        children: [
          if (hasSeries)
            SwitchListTile(
              value: _applySeries,
              onChanged: _busy ? null : (v) => setState(() => _applySeries = v),
              title: Text('Apply to series', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
              contentPadding: EdgeInsets.zero,
            ),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _category,
                  items: AppConstants.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: _busy ? null : (v) => setState(() => _category = v ?? _category),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _priority,
                  items: AppConstants.priorities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: _busy ? null : (v) => setState(() => _priority = v ?? _priority),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(controller: _type, decoration: const InputDecoration(labelText: 'Type')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _due, decoration: const InputDecoration(labelText: 'Due (DD-MM-YYYY)'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _trigger, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Trigger days'))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _snooze, decoration: const InputDecoration(labelText: 'Snoozed until (DD-MM-YYYY)'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _assignee, decoration: const InputDecoration(labelText: 'Assignee email'))),
            ],
          ),
          const SizedBox(height: 16),

          Align(alignment: Alignment.centerLeft, child: Text('Start email', style: GoogleFonts.inter(fontWeight: FontWeight.w900))),
          SwitchListTile(
            value: _sendStart,
            onChanged: _busy ? null : (v) => setState(() => _sendStart = v),
            title: Text('Send start email', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            contentPadding: EdgeInsets.zero,
          ),
          TextField(controller: _to, decoration: const InputDecoration(labelText: 'To overrides (;)')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _cc, decoration: const InputDecoration(labelText: 'CC overrides (;)'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _bcc, decoration: const InputDecoration(labelText: 'BCC overrides (;)'))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  value: _ccAssigneeStart,
                  onChanged: _busy ? null : (v) => setState(() => _ccAssigneeStart = v),
                  title: Text('CC assignee', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  value: _ccManagerStart,
                  onChanged: _busy ? null : (v) => setState(() => _ccManagerStart = v),
                  title: Text('CC manager', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          TextField(controller: _startSubj, decoration: const InputDecoration(labelText: 'Start subject')),
          const SizedBox(height: 10),
          TextField(controller: _startBody, maxLines: 5, decoration: const InputDecoration(labelText: 'Start body')),

          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: Text('Completion email', style: GoogleFonts.inter(fontWeight: FontWeight.w900))),
          SwitchListTile(
            value: _sendComp,
            onChanged: _busy ? null : (v) => setState(() => _sendComp = v),
            title: Text('Send completion email', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            contentPadding: EdgeInsets.zero,
          ),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  value: _ccAssigneeComp,
                  onChanged: _busy ? null : (v) => setState(() => _ccAssigneeComp = v),
                  title: Text('CC assignee', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  value: _ccManagerComp,
                  onChanged: _busy ? null : (v) => setState(() => _ccManagerComp = v),
                  title: Text('CC manager', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          TextField(controller: _compSubj, decoration: const InputDecoration(labelText: 'Completion subject')),
          const SizedBox(height: 10),
          TextField(controller: _compBody, maxLines: 5, decoration: const InputDecoration(labelText: 'Completion body')),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onUpload;
  const _AttachmentsCard({required this.task, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final items = task.attachments;
    return GlassCard(
      title: 'Attachments',
      subtitle: 'Upload and open documents',
      accentColor: AppTheme.teal,
      trailing: IconButton(
        onPressed: onUpload,
        icon: const Icon(Icons.upload_file_rounded),
      ),
      child: items.isEmpty
          ? const Text('No attachments yet.')
          : Column(
              children: items.reversed.map((a) {
                final fileName = (a['fileName'] ?? '').toString();
                final type = (a['type'] ?? 'DOC').toString();
                final link = (a['driveWebViewLink'] ?? '').toString();
                return ListTile(
                  title: Text('$type • $fileName', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                  subtitle: Text(link.isEmpty ? 'No link' : link, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: link.isEmpty ? null : const Icon(Icons.open_in_new_rounded),
                  onTap: link.isEmpty
                      ? null
                      : () async {
                          try {
                            await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                          } catch (_) {}
                        },
                );
              }).toList(),
            ),
    );
  }
}

class _CommentsCard extends StatefulWidget {
  final String taskId;
  const _CommentsCard({required this.taskId});

  @override
  State<_CommentsCard> createState() => _CommentsCardState();
}

class _CommentsCardState extends State<_CommentsCard> {
  final _api = ApiService();
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final stream = FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .limit(250)
        .snapshots();

    return GlassCard(
      title: 'Comments',
      subtitle: 'Mentions notify teammates',
      accentColor: AppTheme.orange,
      trailing: _busy ? const LoadingIndicator(size: 18) : null,
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: LoadingIndicator()),
                );
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('No comments yet.'),
                );
              }
              final comments = docs.map((d) => CommentModel.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();
              return Column(
                children: comments.map((c) {
                  return ListTile(
                    title: Text(c.authorName ?? c.authorEmail, style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      c.text,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(AppDateUtils.formatDateTime(c.createdAt), style: GoogleFonts.inter(fontSize: 11, color: AppTheme.gray)),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _text,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write a comment…',
              prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _busy
                  ? null
                  : () async {
                      final t = _text.text.trim();
                      if (t.isEmpty) {
                        Helpers.showSnackBar(context, 'Write a comment first', isError: true);
                        return;
                      }
                      setState(() => _busy = true);
                      final res = await _api.addComment(widget.taskId, t);
                      setState(() => _busy = false);
                      if (!mounted) return;
                      if (!res.ok) {
                        Helpers.showSnackBar(context, res.error ?? 'Comment failed', isError: true);
                        return;
                      }
                      _text.clear();
                      Helpers.showSnackBar(context, 'Comment added', isSuccess: true);
                    },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Add comment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String taskId;
  const _TimelineCard({required this.taskId});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('auditLogs')
        .where('taskId', isEqualTo: taskId)
        .limit(250)
        .snapshots();

    return GlassCard(
      title: 'Timeline',
      subtitle: 'Audit logs for status, edits, uploads, offline updates',
      accentColor: AppTheme.gray,
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: LoadingIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Text('No timeline entries yet.');
          }
          final items = docs
              .map((d) => AuditLogModel.fromJson(d.data() as Map<String, dynamic>, d.id))
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return Column(
            children: items.map((a) {
              return ListTile(
                title: Text(a.action, style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
                subtitle: Text(
                  '${a.actorEmail ?? ''}\n${a.details.isNotEmpty ? a.details.toString() : ''}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                trailing: Text(AppDateUtils.formatDateTime(a.timestamp), style: GoogleFonts.inter(fontSize: 11, color: AppTheme.gray)),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final TaskModel task;
  const _DangerZone({required this.task});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final api = ApiService();

    return GlassCard(
      title: 'Danger zone',
      subtitle: 'Delete task / series',
      accentColor: AppTheme.danger,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete task?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok != true) return;
                final res = await api.deleteTask(task.id, applyToSeries: false);
                if (!context.mounted) return;
                if (!res.ok) {
                  Helpers.showSnackBar(context, res.error ?? 'Delete failed', isError: true);
                  return;
                }
                Helpers.showSnackBar(context, 'Deleted', isSuccess: true);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete task'),
            ),
          ),
          if ((task.seriesId ?? '').isNotEmpty && auth.canEditDetails) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete entire series?'),
                      content: const Text('Deletes all tasks in this series.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete series'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  final res = await api.deleteTask(task.id, applyToSeries: true);
                  if (!context.mounted) return;
                  if (!res.ok) {
                    Helpers.showSnackBar(context, res.error ?? 'Delete failed', isError: true);
                    return;
                  }
                  Helpers.showSnackBar(context, 'Series deleted', isSuccess: true);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Delete series'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
