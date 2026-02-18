import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            trailing: Switch(value: isDark, onChanged: (_) => app.toggleTheme(), activeColor: AppTheme.primary),
          ),
          _SettingsTile(icon: Icons.info_outline_rounded, title: 'Version', trailing: Text('1.0.0', style: GoogleFonts.inter(color: const Color(0xFF8E8E93)))),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const _SettingsTile({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [Icon(icon, color: AppTheme.primary), const SizedBox(width: 16), Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600))), if (trailing != null) trailing!]),
    );
  }
}
