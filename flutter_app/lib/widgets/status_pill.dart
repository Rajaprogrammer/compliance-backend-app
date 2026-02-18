import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/task_model.dart';
import '../utils/date_utils.dart';

enum PillType { normal, danger, warning, success, muted }

class StatusPill extends StatelessWidget {
  final String text;
  final PillType type;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.text,
    this.type = PillType.normal,
    this.icon,
  });

  factory StatusPill.forTask(TaskModel task) {
    final today = AppDateUtils.todayYmd();
    if (task.status == 'COMPLETED') {
      return const StatusPill(text: 'DONE', type: PillType.success, icon: Icons.check_circle);
    }
    if (task.dueDateYmd == null || task.dueDateYmd!.isEmpty) {
      return const StatusPill(text: 'NO DUE', type: PillType.muted);
    }
    final dd = AppDateUtils.diffDays(today, task.dueDateYmd!);
    if (dd < 0) return const StatusPill(text: 'OVERDUE', type: PillType.danger, icon: Icons.warning_rounded);
    if (dd == 0) return const StatusPill(text: 'TODAY', type: PillType.danger, icon: Icons.schedule);
    if (dd <= 3) return const StatusPill(text: 'SOON', type: PillType.warning, icon: Icons.access_time);
    if (dd <= 7) return const StatusPill(text: 'THIS WEEK', type: PillType.warning);
    return const StatusPill(text: 'OK', type: PillType.muted);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor, textColor;
    switch (type) {
      case PillType.danger:
        bgColor = AppTheme.danger.withOpacity(0.15);
        textColor = AppTheme.danger;
        break;
      case PillType.warning:
        bgColor = AppTheme.warning.withOpacity(0.15);
        textColor = AppTheme.orange;
        break;
      case PillType.success:
        bgColor = AppTheme.success.withOpacity(0.15);
        textColor = AppTheme.success;
        break;
      case PillType.muted:
        bgColor = const Color(0xFF8E8E93).withOpacity(0.15);
        textColor = const Color(0xFF8E8E93);
        break;
      default:
        bgColor = AppTheme.primary.withOpacity(0.15);
        textColor = AppTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
