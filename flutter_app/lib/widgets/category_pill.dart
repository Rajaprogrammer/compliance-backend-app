import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class CategoryPill extends StatelessWidget {
  final String category;

  const CategoryPill({super.key, required this.category});

  String get normalized {
    final u = category.toUpperCase().replaceAll(' ', '_');
    if (u == 'INCOME_TAX' || u == 'INCOME_TAX_RETURN') return 'INCOME_TAX';
    if (['GST', 'TDS', 'ROC', 'ACCOUNTING', 'AUDIT'].contains(u)) return u;
    return 'OTHER';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[normalized] ?? AppTheme.categoryColors['OTHER']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        normalized.replaceAll('_', ' '),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
