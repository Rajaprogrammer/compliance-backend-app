import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../models/task_model.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';
import '../widgets/kpi_card.dart';
import '../config/theme.dart';
import '../utils/date_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<TaskModel>>(
      stream: app.tasksStream(isPartnerOrManager: auth.canSeeAllTasks),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildLoadingState(isDark);

        final tasks = snapshot.data!;
        final stats = _computeStats(tasks);

        return RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
                const SizedBox(height: 4),
                Text("Here's your compliance overview", style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF8E8E93))).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                const SizedBox(height: 28),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.4,
                  children: [
                    KpiCard(label: 'Due Today', value: stats.dueToday, icon: Icons.today_rounded, color: AppTheme.danger, isAlert: true).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
                    KpiCard(label: 'This Week', value: stats.due7, icon: Icons.date_range_rounded, color: AppTheme.warning).animate().fadeIn(duration: 400.ms, delay: 150.ms).scale(begin: const Offset(0.9, 0.9)),
                    KpiCard(label: 'Overdue', value: stats.overdue, icon: Icons.warning_rounded, color: AppTheme.pink, isAlert: true).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                    KpiCard(label: 'Pending Approval', value: stats.approval, icon: Icons.pending_actions_rounded, color: AppTheme.purple).animate().fadeIn(duration: 400.ms, delay: 250.ms).scale(begin: const Offset(0.9, 0.9)),
                  ],
                ),
                const SizedBox(height: 28),

                GlassCard(
                  title: 'Focus Tasks',
                  subtitle: 'Tasks requiring immediate attention',
                  accentColor: AppTheme.primary,
                  child: stats.focusTasks.isEmpty
                      ? _buildEmptyState(isDark)
                      : Column(children: stats.focusTasks.take(8).map((task) => _TaskRow(task: task, clientName: app.getClientName(task.clientId))).toList()),
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 32, color: Colors.white),
            const SizedBox(height: 28),
            GridView.count(shrinkWrap: true, crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.4, children: List.generate(4, (_) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 32)),
          const SizedBox(height: 16),
          Text('All caught up!', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('No urgent tasks at the moment', style: GoogleFonts.inter(color: const Color(0xFF8E8E93))),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  _Stats _computeStats(List<TaskModel> tasks) {
    final today = AppDateUtils.todayYmd();
    int dueToday = 0, due7 = 0, overdue = 0, approval = 0;
    List<TaskModel> focusTasks = [];

    for (final task in tasks) {
      if (task.status == 'APPROVAL_PENDING') approval++;
      if (task.dueDateYmd == null) continue;
      final dd = AppDateUtils.diffDays(today, task.dueDateYmd!);
      if (task.status != 'COMPLETED') {
        if (dd < 0) overdue++;
        if (dd == 0) dueToday++;
        if (dd >= 0 && dd <= 7) due7++;
        if (dd <= 3) focusTasks.add(task);
      }
    }

    focusTasks.sort((a, b) => (a.dueDateYmd ?? '').compareTo(b.dueDateYmd ?? ''));
    return _Stats(dueToday: dueToday, due7: due7, overdue: overdue, approval: approval, focusTasks: focusTasks);
  }
}

class _Stats {
  final int dueToday, due7, overdue, approval;
  final List<TaskModel> focusTasks;
  _Stats({required this.dueToday, required this.due7, required this.overdue, required this.approval, required this.focusTasks});
}

class _TaskRow extends StatelessWidget {
  final TaskModel task;
  final String? clientName;
  const _TaskRow({required this.task, this.clientName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.03))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [StatusPill.forTask(task), const SizedBox(width: 8), Expanded(child: Text(task.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                const SizedBox(height: 8),
                Text('\${clientName ?? "No client"} • \${task.dueDateYmd != null ? AppDateUtils.ymdToDmy(task.dueDateYmd!) : "No due date"}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E93))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF8E8E93)),
        ],
      ),
    );
  }
}
