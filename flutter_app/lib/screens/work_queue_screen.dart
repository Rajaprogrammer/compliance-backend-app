import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../models/task_model.dart';
import '../widgets/status_pill.dart';
import '../widgets/category_pill.dart';
import '../config/theme.dart';
import '../utils/date_utils.dart';

class WorkQueueScreen extends StatefulWidget {
  const WorkQueueScreen({super.key});

  @override
  State<WorkQueueScreen> createState() => _WorkQueueScreenState();
}

class _WorkQueueScreenState extends State<WorkQueueScreen> {
  String _search = '';
  String _statusFilter = '';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<TaskModel>>(
      stream: app.tasksStream(isPartnerOrManager: auth.canSeeAllTasks),
      builder: (context, snapshot) {
        final tasks = _filterTasks(snapshot.data ?? [], app);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Work Queue', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('\${tasks.length} tasks', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF8E8E93))),
              const SizedBox(height: 20),

              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(hintText: 'Search tasks...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
              ),
              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'All', isSelected: _statusFilter.isEmpty, onTap: () => setState(() => _statusFilter = '')),
                    _FilterChip(label: 'Pending', isSelected: _statusFilter == 'PENDING', onTap: () => setState(() => _statusFilter = 'PENDING')),
                    _FilterChip(label: 'In Progress', isSelected: _statusFilter == 'IN_PROGRESS', onTap: () => setState(() => _statusFilter = 'IN_PROGRESS')),
                    _FilterChip(label: 'Completed', isSelected: _statusFilter == 'COMPLETED', onTap: () => setState(() => _statusFilter = 'COMPLETED')),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (tasks.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(children: [Icon(Icons.inbox_rounded, size: 64, color: const Color(0xFF8E8E93)), const SizedBox(height: 16), Text('No tasks found', style: GoogleFonts.inter(fontWeight: FontWeight.w700))])))
              else
                ...tasks.take(50).map((task) => _TaskCard(task: task, clientName: app.getClientName(task.clientId))),
            ],
          ),
        );
      },
    );
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks, AppProvider app) {
    return tasks.where((task) {
      if (_statusFilter.isNotEmpty && task.status != _statusFilter) return false;
      if (_search.isNotEmpty) {
        final hay = '\${task.title} \${app.getClientName(task.clientId) ?? ""}'.toLowerCase();
        if (!hay.contains(_search.toLowerCase())) return false;
      }
      return true;
    }).toList()..sort((a, b) => (a.dueDateYmd ?? '').compareTo(b.dueDateYmd ?? ''));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: isSelected ? AppTheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppTheme.primary : const Color(0xFF8E8E93).withOpacity(0.3))),
          child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF8E8E93))),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final String? clientName;
  const _TaskCard({required this.task, this.clientName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [StatusPill.forTask(task), const SizedBox(width: 8), CategoryPill(category: task.category ?? 'OTHER'), const Spacer(), Text(task.dueDateYmd != null ? AppDateUtils.ymdToDmy(task.dueDateYmd!) : '', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8E8E93)))]),
          const SizedBox(height: 12),
          Text(task.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(clientName ?? 'No client', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF8E8E93))),
        ],
      ),
    );
  }
}
