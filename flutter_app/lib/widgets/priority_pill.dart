import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class PriorityPill extends StatelessWidget {
  final String priority;
  final bool compact;

  const PriorityPill({super.key, required this.priority, this.compact = false});

  String get normalized => priority.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.priorityColors[normalized] ?? AppTheme.orange;
    IconData icon;
    switch (normalized) {
      case 'HIGH':
        icon = Icons.arrow_upward_rounded;
        break;
      case 'LOW':
        icon = Icons.arrow_downward_rounded;
        break;
      default:
        icon = Icons.remove_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: color),
          SizedBox(width: compact ? 2 : 3),
          Text(
            normalized,
            style: GoogleFonts.inter(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
