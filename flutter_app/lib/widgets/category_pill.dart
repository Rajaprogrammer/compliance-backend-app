import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class CategoryPill extends StatelessWidget {
  final String category;
  final bool compact;

  const CategoryPill({super.key, required this.category, this.compact = false});

  String get normalized {
    final u = category.toUpperCase().replaceAll(' ', '_');
    if (u == 'INCOME_TAX' || u == 'INCOME_TAX_RETURN' || u == 'INCOME') return 'INCOME_TAX';
    if (['GST', 'TDS', 'ROC', 'ACCOUNTING', 'AUDIT'].contains(u)) return u;
    return 'OTHER';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[normalized] ?? AppTheme.gray;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        normalized.replaceAll('_', ' '),
        style: GoogleFonts.inter(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
