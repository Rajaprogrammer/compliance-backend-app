import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/date_utils.dart';
import '../utils/helpers.dart';
import '../widgets/loading_overlay.dart';

class CreateTaskScreen extends StatefulWidget {
  final bool oneOnly; // if true => AD_HOC + generateCount=1
  const CreateTaskScreen({super.key, required this.oneOnly});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _api = ApiService();
  bool _busy = false;

  String _clientId = '';
  final _clientName = TextEditingController();
  final _clientEmail = TextEditingController();

  final _assignedToEmail = TextEditingController();
  final _title = TextEditingController();
  final _type = TextEditingController(text: 'FILING');

  String _category = 'OTHER';
  String _priority = 'MEDIUM';

  final _dueDmy = TextEditingController();
  final _triggerDays = TextEditingController(text: '15');

  String _recurrence = 'AD_HOC';
  final _generateCount = TextEditingController(text: '1');

  // mail settings
  bool _sendStart = true;
  bool _sendCompletion = true;

  final _to = TextEditingController();
  final _cc = TextEditingController();
  final _bcc = TextEditingController();
  bool _ccAssigneeStart = false;
  bool _ccManagerStart = false;

  final _startSubject = TextEditingController(text: 'We started {{taskTitle}}');
  final _startBody = TextEditingController(
    text:
        'Dear {{clientName}},\\n\\nWe started work on {{taskTitle}}.\\nDue: {{dueDate}}\\n\\nAdd to calendar: {{addToCalendarUrl}}\\n\\nRegards,\\nCompliance Team',
  );

  bool _ccAssigneeCompletion = false;
  bool _ccManagerCompletion = false;
  final _completionSubject = TextEditingController(text: 'Completed: {{taskTitle}}');
  final _completionBody = TextEditingController(
    text:
        'Dear {{clientName}},\\n\\nWe have completed {{taskTitle}}.\\nCompleted at: {{completedAt}}\\n\\nRegards,\\nCompliance Team',
  );

  @override
  void initState() {
    super.initState();
    if (widget.oneOnly) {
      _recurrence = 'AD_HOC';
      _generateCount.text = '1';
    }
    final auth = context.read<AuthProvider>();
    if (!auth.canEditDetails) {
      _assignedToEmail.text = auth.email;
    }
  }

  @override
  void dispose() {
    _clientName.dispose();
    _clientEmail.dispose();
    _assignedToEmail.dispose();
    _title.dispose();
    _type.dispose();
    _dueDmy.dispose();
    _triggerDays.dispose();
    _generateCount.dispose();
    _to.dispose();
    _cc.dispose();
    _bcc.dispose();
    _startSubject.dispose();
    _startBody.dispose();
    _completionSubject.dispose();
    _completionBody.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final auth = context.read<AuthProvider>();
    final app = context.read<AppProvider>();

    if (_title.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Title is required', isError: true);
      return;
    }
    if ((_clientId.isEmpty) && _clientName.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Select a client or enter client name', isError: true);
      return;
    }

    String dueYmd;
    try {
      dueYmd = AppDateUtils.dmyToYmd(_dueDmy.text.trim());
    } catch (e) {
      Helpers.showSnackBar(context, e.toString(), isError: true);
      return;
    }

    setState(() => _busy = true);
    final res = await _api.createTask({
      'clientId': _clientId.isEmpty ? null : _clientId,
      'clientName': _clientName.text.trim().isEmpty ? null : _clientName.text.trim(),
      'clientEmail': _clientEmail.text.trim().isEmpty ? null : _clientEmail.text.trim(),
      'assignedToEmail': _assignedToEmail.text.trim().isEmpty ? null : _assignedToEmail.text.trim(),
      'title': _title.text.trim(),
      'type': _type.text.trim(),
      'category': _category,
      'priority': _priority,
      'dueDateYmd': dueYmd,
      'triggerDaysBefore': int.tryParse(_triggerDays.text.trim()) ?? 15,
      'recurrence': widget.oneOnly ? 'AD_HOC' : _recurrence,
      'generateCount': widget.oneOnly ? 1 : (int.tryParse(_generateCount.text.trim()) ?? 1),
      // Start mail
      'sendClientStartMail': _sendStart,
      'clientToEmails': Helpers.parseEmailList(_to.text),
      'clientCcEmails': Helpers.parseEmailList(_cc.text),
      'clientBccEmails': Helpers.parseEmailList(_bcc.text),
      'ccAssigneeOnClientStart': _ccAssigneeStart,
      'ccManagerOnClientStart': _ccManagerStart,
      'clientStartSubject': _startSubject.text,
      'clientStartBody': _startBody.text,
      // Completion mail
      'sendClientCompletionMail': _sendCompletion,
      'ccAssigneeOnCompletion': _ccAssigneeCompletion,
      'ccManagerOnCompletion': _ccManagerCompletion,
      'clientCompletionSubject': _completionSubject.text,
      'clientCompletionBody': _completionBody.text,
    });
    setState(() => _busy = false);

    if (!mounted) return;
    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Create failed', isError: true);
      return;
    }
    Helpers.showSnackBar(context, 'Task(s) created', isSuccess: true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();

    return LoadingOverlay(
      isLoading: _busy,
      message: 'Creating…',
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.oneOnly ? 'Create ONE task' : 'Create task / series'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (auth.canAccessClients)
                DropdownButtonFormField<String>(
                  value: _clientId.isEmpty ? null : _clientId,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('(select client)')),
                    ...app.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _clientId = (v ?? '')),
                  decoration: const InputDecoration(labelText: 'Client (list)'),
                ),
              const SizedBox(height: 10),
              TextField(controller: _clientName, decoration: const InputDecoration(labelText: 'Client name (if not in list)')),
              const SizedBox(height: 10),
              TextField(controller: _clientEmail, decoration: const InputDecoration(labelText: 'Client email (optional)')),
              const SizedBox(height: 10),
              TextField(
                controller: _assignedToEmail,
                enabled: auth.canEditDetails,
                decoration: InputDecoration(
                  labelText: 'Assignee email',
                  helperText: auth.canEditDetails ? null : 'Associates create tasks assigned to themselves',
                ),
              ),
              const SizedBox(height: 10),
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      items: AppConstants.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v ?? _category),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      items: AppConstants.priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => _priority = v ?? _priority),
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
                  Expanded(child: TextField(controller: _dueDmy, decoration: const InputDecoration(labelText: 'Due (DD-MM-YYYY)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _triggerDays, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Trigger days'))),
                ],
              ),
              const SizedBox(height: 10),
              if (!widget.oneOnly)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _recurrence,
                        items: AppConstants.recurrenceTypes.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (v) => setState(() => _recurrence = v ?? _recurrence),
                        decoration: const InputDecoration(labelText: 'Recurrence'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _generateCount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Generate count'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Text('Start email', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
              SwitchListTile(
                value: _sendStart,
                onChanged: (v) => setState(() => _sendStart = v),
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
                      onChanged: (v) => setState(() => _ccAssigneeStart = v),
                      title: Text('CC assignee', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      value: _ccManagerStart,
                      onChanged: (v) => setState(() => _ccManagerStart = v),
                      title: Text('CC manager', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              TextField(controller: _startSubject, decoration: const InputDecoration(labelText: 'Start subject')),
              const SizedBox(height: 10),
              TextField(controller: _startBody, maxLines: 5, decoration: const InputDecoration(labelText: 'Start body')),
              const SizedBox(height: 16),
              Text('Completion email', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
              SwitchListTile(
                value: _sendCompletion,
                onChanged: (v) => setState(() => _sendCompletion = v),
                title: Text('Send completion email', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                contentPadding: EdgeInsets.zero,
              ),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      value: _ccAssigneeCompletion,
                      onChanged: (v) => setState(() => _ccAssigneeCompletion = v),
                      title: Text('CC assignee', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      value: _ccManagerCompletion,
                      onChanged: (v) => setState(() => _ccManagerCompletion = v),
                      title: Text('CC manager', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              TextField(controller: _completionSubject, decoration: const InputDecoration(labelText: 'Completion subject')),
              const SizedBox(height: 10),
              TextField(controller: _completionBody, maxLines: 5, decoration: const InputDecoration(labelText: 'Completion body')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(widget.oneOnly ? 'Create task' : 'Create task(s)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
