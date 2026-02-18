import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool isAlert;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.25 : 0.12),
            color.withOpacity(isDark ? 0.15 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isAlert && value > 0 ? 0.5 : 0.2),
          width: isAlert && value > 0 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
