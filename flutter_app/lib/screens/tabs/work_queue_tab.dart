import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/task_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/create_task_screen.dart';
import '../../screens/task_detail_screen.dart';
import '../../services/api_service.dart';
import '../../utils/date_utils.dart';
import '../../utils/helpers.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/priority_pill.dart';
import '../../widgets/status_pill.dart';

class WorkQueueTab extends StatefulWidget {
  const WorkQueueTab({super.key});

  @override
  State<WorkQueueTab> createState() => _WorkQueueTabState();
}

class _WorkQueueTabState extends State<WorkQueueTab> {
  final _api = ApiService();

  String _q = '';
  String _mode = 'ACTIVE'; // ACTIVE | ALL | SNOOZED | APPROVAL | COMPLETED
  String _status = '';
  String _category = '';
  String _priority = '';
  String _assigneeEmail = '';
  String _clientId = '';

  final Set<String> _selected = {};
  bool _isBulkBusy = false;

  List<TaskModel> _applyFilters(List<TaskModel> tasks, AppProvider app) {
    final today = AppDateUtils.todayYmd();
    final q = _q.trim().toLowerCase();

    bool isSnoozedNow(TaskModel t) =>
        (t.status != 'COMPLETED') &&
        (t.snoozedUntilYmd != null && t.snoozedUntilYmd!.isNotEmpty) &&
        (t.snoozedUntilYmd!.compareTo(today) > 0);

    final filtered = tasks.where((t) {
      final snoozedNow = isSnoozedNow(t);

      if (_mode == 'ACTIVE') {
        if (t.status == 'COMPLETED') return false;
        if (snoozedNow) return false;
      } else if (_mode == 'SNOOZED') {
        if (!snoozedNow) return false;
      } else if (_mode == 'APPROVAL') {
        if (t.status != 'APPROVAL_PENDING') return false;
      } else if (_mode == 'COMPLETED') {
        if (t.status != 'COMPLETED') return false;
      }

      if (_status.isNotEmpty && (t.status ?? '') != _status) return false;
      if (_category.isNotEmpty && (t.normalizedCategory) != _category) return false;
      if (_priority.isNotEmpty && (t.normalizedPriority) != _priority) return false;

      if (_clientId.isNotEmpty && (t.clientId ?? '') != _clientId) return false;

      if (_assigneeEmail.isNotEmpty) {
        if ((t.assignedToEmail ?? '').toLowerCase().trim() != _assigneeEmail.toLowerCase().trim()) {
          return false;
        }
      }

      if (q.isNotEmpty) {
        final clientName = app.getClientName(t.clientId) ?? '';
        final hay = '${t.title} ${t.type ?? ''} $clientName ${t.assignedToEmail ?? ''}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) => (a.dueDateYmd ?? '').compareTo(b.dueDateYmd ?? ''));
    return filtered;
  }

  Future<void> _bulkUpdate(String op, Map<String, dynamic> payload, {String? success}) async {
    if (_selected.isEmpty) {
      Helpers.showSnackBar(context, 'Select tasks first', isError: true);
      return;
    }
    setState(() => _isBulkBusy = true);
    final res = await _api.bulkUpdate(taskIds: _selected.toList(), op: op, payload: payload);
    setState(() => _isBulkBusy = false);

    if (!mounted) return;
    if (!res.ok) {
      Helpers.showSnackBar(context, res.error ?? 'Bulk operation failed', isError: true);
      return;
    }
    _selected.clear();
    Helpers.showSnackBar(context, success ?? 'Bulk update applied', isSuccess: true);
  }

  Future<void> _promptSnooze() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked == null) return;
    final ymd = AppDateUtils.todayYmd().replaceRange(0, 10,
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    await _bulkUpdate('SNOOZE', {'snoozedUntilYmd': ymd}, success: 'Snoozed ${_selected.length} tasks');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();

    return StreamBuilder<List<TaskModel>>(
      stream: app.tasksStream(isPartnerOrManager: auth.canSeeAllTasks),
      builder: (context, snap) {
        final tasks = _applyFilters(snap.data ?? [], app);

        return LoadingOverlay(
          isLoading: _isBulkBusy,
          message: 'Applying bulk action…',
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassCard(
                  title: 'Work Queue',
                  subtitle: '${tasks.length} shown • ${auth.canSeeAllTasks ? "Team" : "My"} tasks',
                  accentColor: AppTheme.viewAccents['work'],
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selected.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Selected: ${_selected.length}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.primary),
                          ),
                        ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: 'Create task',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateTaskScreen(oneOnly: false)),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _q = v),
                        decoration: InputDecoration(
                          hintText: 'Search tasks, clients, assignees…',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FilterRow(
                        label: 'Mode',
                        value: _mode,
                        items: const {
                          'ACTIVE': 'Active',
                          'ALL': 'All',
                          'SNOOZED': 'Snoozed',
                          'APPROVAL': 'Approval',
                          'COMPLETED': 'Completed',
                        },
                        onChanged: (v) => setState(() => _mode = v),
                      ),
                      const SizedBox(height: 8),
                      _FilterRow(
                        label: 'Status',
                        value: _status,
                        items: const {
                          '': 'All',
                          'PENDING': 'Pending',
                          'IN_PROGRESS': 'In progress',
                          'CLIENT_PENDING': 'Client pending',
                          'APPROVAL_PENDING': 'Approval pending',
                          'COMPLETED': 'Completed',
                        },
                        onChanged: (v) => setState(() => _status = v),
                      ),
                      const SizedBox(height: 8),
                      _FilterRow(
                        label: 'Category',
                        value: _category,
                        items: {
                          '': 'All',
                          for (final c in AppConstants.categories) c: c.replaceAll('_', ' '),
                        },
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      const SizedBox(height: 8),
                      _FilterRow(
                        label: 'Priority',
                        value: _priority,
                        items: const {'': 'All', 'HIGH': 'High', 'MEDIUM': 'Medium', 'LOW': 'Low'},
                        onChanged: (v) => setState(() => _priority = v),
                      ),
                      if (auth.canSeeAllTasks) ...[
                        const SizedBox(height: 10),
                        TextField(
                          onChanged: (v) => setState(() => _assigneeEmail = v),
                          decoration: const InputDecoration(
                            hintText: 'Assignee email (exact match)',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                      ],
                      if (auth.canAccessClients) ...[
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _clientId.isEmpty ? null : _clientId,
                          items: [
                            const DropdownMenuItem(value: '', child: Text('All clients')),
                            ...app.clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                          ],
                          onChanged: (v) => setState(() => _clientId = (v ?? '')),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.people_outline_rounded),
                            hintText: 'Client filter',
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (_selected.isNotEmpty) _buildBulkBar(auth),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (tasks.isEmpty)
                  const EmptyState(
                    icon: Icons.inbox_rounded,
                    title: 'No tasks found',
                    subtitle: 'Try changing filters or search query.',
                  )
                else
                  Column(
                    children: tasks.take(500).map((t) => _TaskTile(
                      task: t,
                      clientName: app.getClientName(t.clientId),
                      selected: _selected.contains(t.id),
                      onToggle: (on) => setState(() {
                        if (on) _selected.add(t.id);
                        else _selected.remove(t.id);
                      }),
                      onOpen: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t.id)),
                        );
                      },
                    )).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulkBar(AuthProvider auth) {
    String? bulkStatus;

    final reassignCtrl = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bulk actions', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: bulkStatus,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Change status…')),
                    DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                    DropdownMenuItem(value: 'IN_PROGRESS', child: Text('IN_PROGRESS')),
                    DropdownMenuItem(value: 'CLIENT_PENDING', child: Text('CLIENT_PENDING')),
                    DropdownMenuItem(value: 'APPROVAL_PENDING', child: Text('APPROVAL_PENDING')),
                    DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                  ],
                  onChanged: (v) => bulkStatus = v,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_outlined)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  if (bulkStatus == null || bulkStatus!.isEmpty) {
                    Helpers.showSnackBar(context, 'Pick a status', isError: true);
                    return;
                  }
                  await _bulkUpdate('STATUS', {'newStatus': bulkStatus}, success: 'Updated status for selected tasks');
                },
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (auth.canSeeAllTasks) ...[
            TextField(
              controller: reassignCtrl,
              decoration: const InputDecoration(
                hintText: 'Reassign to email',
                prefixIcon: Icon(Icons.swap_horiz_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final email = reassignCtrl.text.trim();
                      if (email.isEmpty) {
                        Helpers.showSnackBar(context, 'Enter assignee email', isError: true);
                        return;
                      }
                      await _bulkUpdate('REASSIGN', {'assignedToEmail': email}, success: 'Reassigned selected tasks');
                    },
                    child: const Text('Reassign'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _promptSnooze,
                  icon: const Icon(Icons.snooze_rounded),
                  label: const Text('Snooze'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete selected tasks?'),
                        content: const Text('This cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    await _bulkUpdate('DELETE', {}, success: 'Deleted selected tasks');
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  const _FilterRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 74, child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12))),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.entries.map((e) {
                final selected = e.key == value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onChanged(e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary.withOpacity(0.14) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppTheme.primary.withOpacity(0.25) : Colors.grey.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: selected ? AppTheme.primary : AppTheme.gray,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final String? clientName;
  final bool selected;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  const _TaskTile({
    required this.task,
    required this.clientName,
    required this.selected,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: selected, onChanged: (v) => onToggle(v ?? false)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill.forTask(task, compact: true),
                      const SizedBox(width: 8),
                      CategoryPill(category: task.category ?? 'OTHER', compact: true),
                      const SizedBox(width: 8),
                      PriorityPill(priority: task.priority ?? 'MEDIUM', compact: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(task.title, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    '${clientName ?? "No client"}'
                    '${task.dueDateYmd != null ? " • Due ${AppDateUtils.ymdToDmy(task.dueDateYmd)}" : ""}'
                    '${task.assignedToEmail != null ? " • ${task.assignedToEmail}" : ""}',
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
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : Colors.black26),
          ],
        ),
      ),
    );
  }
}
