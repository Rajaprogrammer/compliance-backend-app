import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/theme.dart';
import '../../models/task_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/task_detail_screen.dart';
import '../../utils/date_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_pill.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _ymdFromDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, List<TaskModel>> _byDue(List<TaskModel> tasks) {
    final map = <String, List<TaskModel>>{};
    for (final t in tasks) {
      final y = t.dueDateYmd;
      if (y == null || y.isEmpty) continue;
      map.putIfAbsent(y, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final app = context.watch<AppProvider>();

    return StreamBuilder<List<TaskModel>>(
      stream: app.tasksStream(isPartnerOrManager: auth.canSeeAllTasks),
      builder: (context, snap) {
        final tasks = snap.data ?? [];
        final map = _byDue(tasks);

        final selectedYmd = _selectedDay != null ? _ymdFromDate(_selectedDay!) : AppDateUtils.todayYmd();
        final dayTasks = (map[selectedYmd] ?? []).toList()
          ..sort((a, b) => (a.status ?? '').compareTo(b.status ?? ''));

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                title: 'Timeline',
                subtitle: 'Tap a date to see due tasks (Month view)',
                accentColor: AppTheme.viewAccents['calendar'],
                child: Column(
                  children: [
                    TableCalendar<TaskModel>(
                      firstDay: DateTime.now().subtract(const Duration(days: 365 * 5)),
                      lastDay: DateTime.now().add(const Duration(days: 365 * 10)),
                      focusedDay: _focusedDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (d) => _selectedDay != null && AppDateUtils.isSameDay(d, _selectedDay!),
                      onDaySelected: (selected, focused) => setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      }),
                      onPageChanged: (focused) => setState(() => _focusedDay = focused),
                      eventLoader: (day) => map[_ymdFromDate(day)] ?? const [],
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16),
                        leftChevronIcon: const Icon(Icons.chevron_left_rounded),
                        rightChevronIcon: const Icon(Icons.chevron_right_rounded),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppTheme.orange,
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Due on ${AppDateUtils.ymdToDmy(selectedYmd)} • ${dayTasks.length} tasks',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (dayTasks.isEmpty)
                      const EmptyState(
                        icon: Icons.event_available_rounded,
                        title: 'No tasks due',
                        subtitle: 'Pick another date or use Work Queue filters.',
                      )
                    else
                      Column(
                        children: dayTasks.take(80).map((t) {
                          final clientName = app.getClientName(t.clientId);
                          return ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            tileColor: Theme.of(context).cardColor,
                            title: Text(t.title, style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                            subtitle: Text(
                              '${clientName ?? "No client"} • ${t.status ?? ""}',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                            leading: StatusPill.forTask(t, compact: true),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: t.id)),
                              );
                            },
                          );
                        }).toList(),
                      )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
