import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/client_model.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/date_utils.dart';
import '../utils/helpers.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_overlay.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _api = ApiService();
  bool _busy = false;

  final _from = TextEditingController(text: '01-01-2026');
  final _to = TextEditingController(text: '31-12-2026');

  ClientModel? _client(AppProvider app) => app.clientsById[widget.clientId];

  Future<void> _save(ClientModel c) async {
    setState(() => _busy = true);
    final res = await _api.updateClient({
      'clientId': c.id,
      'name': _name.text.trim(),
      'pan': _pan.text.trim(),
      'gstin': _gstin.text.trim(),
      'cin': _cin.text.trim(),
      'assessmentYear': _ay.text.trim(),
      'engagementType': _eng.text.trim(),
      'primaryEmail': _email.text.trim(),
      'ccEmails': Helpers.parseEmailList(_cc.text),
      'bccEmails': Helpers.parseEmailList(_bcc.text),
    });
    setState(() => _busy = false);
    if (!mounted) return;
    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Save failed', isError: true);
      return;
    }
    Helpers.showSnackBar(context, 'Saved', isSuccess: true);
  }

  late final _name = TextEditingController();
  late final _pan = TextEditingController();
  late final _gstin = TextEditingController();
  late final _cin = TextEditingController();
  late final _ay = TextEditingController();
  late final _eng = TextEditingController();
  late final _email = TextEditingController();
  late final _cc = TextEditingController();
  late final _bcc = TextEditingController();

  bool _inited = false;
  void _initIfNeeded(ClientModel c) {
    if (_inited) return;
    _inited = true;
    _name.text = c.name;
    _pan.text = c.pan ?? '';
    _gstin.text = c.gstin ?? '';
    _cin.text = c.cin ?? '';
    _ay.text = c.assessmentYear ?? '';
    _eng.text = c.engagementType ?? '';
    _email.text = c.primaryEmail ?? '';
    _cc.text = Helpers.joinEmails(c.ccEmails);
    _bcc.text = Helpers.joinEmails(c.bccEmails);
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _name.dispose();
    _pan.dispose();
    _gstin.dispose();
    _cin.dispose();
    _ay.dispose();
    _eng.dispose();
    _email.dispose();
    _cc.dispose();
    _bcc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final c = _client(app);

    if (!auth.canAccessClients) {
      return const Scaffold(
        body: Center(child: Text('Clients are partner-only')),
      );
    }

    if (c == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _initIfNeeded(c);

    return LoadingOverlay(
      isLoading: _busy,
      message: 'Working…',
      child: Scaffold(
        appBar: AppBar(title: Text(c.name)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              GlassCard(
                title: 'Client details',
                subtitle: 'Edit and save master profile',
                accentColor: AppTheme.viewAccents['clients'],
                child: Column(
                  children: [
                    TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _pan, decoration: const InputDecoration(labelText: 'PAN'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _gstin, decoration: const InputDecoration(labelText: 'GSTIN'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _cin, decoration: const InputDecoration(labelText: 'CIN'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _ay, decoration: const InputDecoration(labelText: 'Assessment Year'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: _eng, decoration: const InputDecoration(labelText: 'Engagement type')),
                    const SizedBox(height: 10),
                    TextField(controller: _email, decoration: const InputDecoration(labelText: 'Primary email')),
                    const SizedBox(height: 10),
                    TextField(controller: _cc, decoration: const InputDecoration(labelText: 'CC emails (;)')),
                    const SizedBox(height: 10),
                    TextField(controller: _bcc, decoration: const InputDecoration(labelText: 'BCC emails (;)')),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _save(c),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GlassCard(
                title: 'Client history exports',
                subtitle: 'XLSX + PDF for a date range',
                accentColor: AppTheme.orange,
                child: Column(
                  children: [
                    TextField(controller: _from, decoration: const InputDecoration(labelText: 'From (DD-MM-YYYY)')),
                    const SizedBox(height: 10),
                    TextField(controller: _to, decoration: const InputDecoration(labelText: 'To (DD-MM-YYYY)')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final fromYmd = AppDateUtils.dmyToYmd(_from.text.trim());
                              final toYmd = AppDateUtils.dmyToYmd(_to.text.trim());
                              final res = await _api.exportClientHistoryXlsx(clientId: c.id, fromYmd: fromYmd, toYmd: toYmd);
                              if (!context.mounted) return;
                              if (!res.ok) {
                                Helpers.showSnackBar(context, res.error ?? 'Export failed', isError: true);
                                return;
                              }
                              await Helpers.downloadBase64File(
                                context: context,
                                fileName: (res.data['fileName'] ?? 'Client_History.xlsx').toString(),
                                base64Data: (res.data['base64'] ?? '').toString(),
                                mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                              );
                            },
                            child: const Text('XLSX'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final fromYmd = AppDateUtils.dmyToYmd(_from.text.trim());
                              final toYmd = AppDateUtils.dmyToYmd(_to.text.trim());
                              final res = await _api.reportClientHistoryPdf(clientId: c.id, fromYmd: fromYmd, toYmd: toYmd);
                              if (!context.mounted) return;
                              if (!res.ok) {
                                Helpers.showSnackBar(context, res.error ?? 'PDF failed', isError: true);
                                return;
                              }
                              await Helpers.downloadBase64File(
                                context: context,
                                fileName: (res.data['fileName'] ?? 'Client_History.pdf').toString(),
                                base64Data: (res.data['base64'] ?? '').toString(),
                                mimeType: (res.data['mime'] ?? 'application/pdf').toString(),
                              );
                            },
                            child: const Text('PDF'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
