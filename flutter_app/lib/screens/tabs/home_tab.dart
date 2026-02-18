import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_pill.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/empty_state.dart';
import '../../config/theme.dart';
import '../../utils/date_utils.dart';
import '../../screens/task_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<TaskModel>>(
      stream: app.tasksStream(isPartnerOrManager: auth.canSeeAllTasks),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState(isDark);
        }

        final stats = app.computeStats();
        final focusTasks = app.getFocusTasks(limit: 15);

        return RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  _getGreeting(),
                  style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 4),
                Text(
                  "Here's your compliance overview",
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.gray),
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 24),

                // KPI Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    KpiCard(label: 'Due Today', value: stats['dueToday'] ?? 0, icon: Icons.today_rounded, color: AppTheme.danger, isAlert: true)
                        .animate().fadeIn(duration: 350.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
                    KpiCard(label: 'This Week', value: stats['due7'] ?? 0, icon: Icons.date_range_rounded, color: AppTheme.warning)
                        .animate().fadeIn(duration: 350.ms, delay: 150.ms).scale(begin: const Offset(0.95, 0.95)),
                    KpiCard(label: 'Overdue', value: stats['overdue'] ?? 0, icon: Icons.warning_rounded, color: AppTheme.pink, isAlert: true)
                        .animate().fadeIn(duration: 350.ms, delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
                    KpiCard(label: 'Pending Approval', value: stats['approval'] ?? 0, icon: Icons.pending_actions_rounded, color: AppTheme.purple)
                        .animate().fadeIn(duration: 350.ms, delay: 250.ms).scale(begin: const Offset(0.95, 0.95)),
                    KpiCard(label: 'Starting Today', value: stats['startToday'] ?? 0, icon: Icons.play_circle_outline_rounded, color: AppTheme.teal)
                        .animate().fadeIn(duration: 350.ms, delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                    KpiCard(label: 'Snoozed', value: stats['snoozed'] ?? 0, icon: Icons.snooze_rounded, color: AppTheme.gray)
                        .animate().fadeIn(duration: 350.ms, delay: 350.ms).scale(begin: const Offset(0.95, 0.95)),
                  ],
                ),
                const SizedBox(height: 24),

                // Focus Tasks
                GlassCard(
                  title: 'Focus Tasks',
                  subtitle: 'Overdue, due today, and due soon',
                  accentColor: AppTheme.viewAccents['home'],
                  child: focusTasks.isEmpty
                      ? const EmptyState(
                          icon: Icons.check_circle_rounded,
                          title: 'All caught up!',
                          subtitle: 'No urgent tasks at the moment',
                          iconColor: AppTheme.success,
                        )
                      : Column(
                          children: focusTasks.map((task) => _TaskRow(
                            task: task,
                            clientName: app.getClientName(task.clientId),
                          )).toList(),
                        ),
                ).animate().fadeIn(duration: 450.ms, delay: 400.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
      highlightColor: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 180, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 8),
            Container(width: 240, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: List.generate(6, (_) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)))),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _TaskRow extends StatelessWidget {
  final TaskModel task;
  final String? clientName;

  const _TaskRow({required this.task, this.clientName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill.forTask(task, compact: true),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.title,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${clientName ?? "No client"}'
                    '${task.dueDateYmd != null && task.dueDateYmd!.isNotEmpty ? " • Due ${AppDateUtils.ymdToDmy(task.dueDateYmd)}" : ""}'
                    '${task.status != null ? " • ${task.status}" : ""}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6D6D72),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black26),
          ],
        ),
      ),
    );
  }
}
