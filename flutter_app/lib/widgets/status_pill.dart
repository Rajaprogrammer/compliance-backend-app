import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/task_model.dart';
import '../utils/date_utils.dart';

enum PillType { normal, danger, warning, success, muted, info }

class StatusPill extends StatelessWidget {
  final String text;
  final PillType type;
  final IconData? icon;
  final bool compact;

  const StatusPill({
    super.key,
    required this.text,
    this.type = PillType.normal,
    this.icon,
    this.compact = false,
  });

  factory StatusPill.forTask(TaskModel task, {bool compact = false}) {
    final today = AppDateUtils.todayYmd();
    
    if (task.status == 'COMPLETED') {
      return StatusPill(text: 'DONE', type: PillType.success, icon: Icons.check_circle_rounded, compact: compact);
    }

    // Check if snoozed
    if (task.snoozedUntilYmd != null && task.snoozedUntilYmd!.isNotEmpty) {
      if (task.snoozedUntilYmd!.compareTo(today) > 0) {
        return StatusPill(text: 'SNOOZED', type: PillType.info, icon: Icons.snooze_rounded, compact: compact);
      }
    }
    
    if (task.dueDateYmd == null || task.dueDateYmd!.isEmpty) {
      return StatusPill(text: 'NO DUE', type: PillType.muted, compact: compact);
    }

    final dd = AppDateUtils.diffDays(today, task.dueDateYmd!);
    final sd = task.startDateYmd != null ? AppDateUtils.diffDays(today, task.startDateYmd!) : null;

    if (dd < 0) return StatusPill(text: 'OVERDUE', type: PillType.danger, icon: Icons.warning_rounded, compact: compact);
    if (dd == 0) return StatusPill(text: 'TODAY', type: PillType.danger, icon: Icons.schedule_rounded, compact: compact);
    if (dd <= 3) {
      if (sd != null && sd > 0) {
        return StatusPill(text: 'HIGH ALERT', type: PillType.danger, icon: Icons.priority_high_rounded, compact: compact);
      }
      return StatusPill(text: 'DUE SOON', type: PillType.warning, icon: Icons.access_time_rounded, compact: compact);
    }
    if (sd != null && sd == 0) {
      return StatusPill(text: 'START TODAY', type: PillType.warning, icon: Icons.play_arrow_rounded, compact: compact);
    }
    if (dd <= 7) return StatusPill(text: 'THIS WEEK', type: PillType.warning, compact: compact);
    
    return StatusPill(text: 'OK', type: PillType.muted, compact: compact);
  }

  factory StatusPill.forStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return const StatusPill(text: 'COMPLETED', type: PillType.success);
      case 'IN_PROGRESS':
        return const StatusPill(text: 'IN PROGRESS', type: PillType.info);
      case 'CLIENT_PENDING':
        return const StatusPill(text: 'CLIENT PENDING', type: PillType.warning);
      case 'APPROVAL_PENDING':
        return const StatusPill(text: 'APPROVAL PENDING', type: PillType.warning);
      case 'PENDING':
      default:
        return const StatusPill(text: 'PENDING', type: PillType.muted);
    }
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
      case PillType.info:
        bgColor = AppTheme.primary.withOpacity(0.15);
        textColor = AppTheme.primary;
        break;
      case PillType.muted:
        bgColor = AppTheme.gray.withOpacity(0.15);
        textColor = AppTheme.gray;
        break;
      default:
        bgColor = AppTheme.primary.withOpacity(0.15);
        textColor = AppTheme.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 10 : 12, color: textColor),
            SizedBox(width: compact ? 3 : 4),
          ],
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: compact ? 10 : 11,
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
