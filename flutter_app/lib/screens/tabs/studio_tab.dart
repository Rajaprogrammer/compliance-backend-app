import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/glass_card.dart';

class StudioTab extends StatefulWidget {
  const StudioTab({super.key});

  @override
  State<StudioTab> createState() => _StudioTabState();
}

class _StudioTabState extends State<StudioTab> {
  final _subject = TextEditingController(text: 'We started {{taskTitle}}');
  final _body = TextEditingController(
    text:
        'Dear {{clientName}},\\n\\nWe started work on {{taskTitle}}.\\nDue: {{dueDate}}\\n\\nAdd to calendar: {{addToCalendarUrl}}\\n\\nRegards,\\nCompliance Team',
  );

  bool _tokenMode = true; // token mode = keep \n tokens for Excel

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  void _insertVar(String key) {
    final text = _body.text;
    final sel = _body.selection;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;
    final next = text.replaceRange(start, end, key);
    _body.text = next;
    _body.selection = TextSelection.collapsed(offset: start + key.length);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: GlassCard(
        title: 'Studio',
        subtitle: 'Draft templates + Excel-safe copy',
        accentColor: AppTheme.viewAccents['studio'],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Template variables', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
                ),
                Switch(
                  value: _tokenMode,
                  onChanged: (v) => setState(() => _tokenMode = v),
                  activeColor: AppTheme.primary,
                ),
                Text(_tokenMode ? 'Excel token mode' : 'Real lines', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.templateVariables.map((v) {
                return OutlinedButton(
                  onPressed: () => _insertVar(v['key'] ?? ''),
                  child: Text(v['name'] ?? ''),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Subject', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(controller: _subject),
            const SizedBox(height: 14),
            Text('Body', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _body,
              maxLines: 10,
              decoration: const InputDecoration(hintText: 'Write your email body…'),
              onChanged: (v) {
                if (!_tokenMode) return;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Helpers.copyToClipboard(context, _subject.text, successMessage: 'Subject copied'),
                    child: const Text('Copy subject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final text = _tokenMode
                          ? Helpers.realLinesToTokens(Helpers.tokensToRealLines(_body.text))
                          : Helpers.tokensToRealLines(_body.text);
                      Helpers.copyToClipboard(context, text, successMessage: _tokenMode ? 'Body copied (Excel-safe)' : 'Body copied');
                    },
                    child: Text(_tokenMode ? 'Copy body (Excel-safe)' : 'Copy body'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _tokenMode
                  ? 'Tip: Token mode keeps all lines inside a single Excel cell using \\n.'
                  : 'Tip: Real lines are easier to read; copy/paste into email editors directly.',
              style: GoogleFonts.inter(color: AppTheme.gray, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
