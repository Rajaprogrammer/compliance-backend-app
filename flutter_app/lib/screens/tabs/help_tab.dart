import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../widgets/glass_card.dart';

class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: GlassCard(
        title: 'Help',
        subtitle: 'Keyboard-first web features are mapped to mobile actions',
        accentColor: AppTheme.viewAccents['help'],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Roles', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'ASSOCIATE: update status, add comments, upload attachments.\n'
              'MANAGER: everything associate + edit details, ops/reports.\n'
              'PARTNER: everything + clients + admin settings.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.gray),
            ),
            const SizedBox(height: 16),
            Text('Notes', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              '• Dates are stored as YYYY-MM-DD (IST) and shown as DD-MM-YYYY.\n'
              '• Start/completion emails and calendar links are controlled by backend settings.\n'
              '• Exports/Reports download base64 files and open locally.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.gray),
            ),
          ],
        ),
      ),
    );
  }
}
