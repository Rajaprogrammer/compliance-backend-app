class TaskModel {
  final String id;
  final String? clientId;
  final String? clientName;
  final String title;
  final String? type;
  final String? category;
  final String? priority;
  final String? status;
  final String? statusNote;
  final String? startDateYmd;
  final String? dueDateYmd;
  final String? snoozedUntilYmd;
  final String? assignedToEmail;
  final String? assignedToUid;
  final String? seriesId;
  final bool clientStartMailSent;
  final String? calendarHtmlLink;

  TaskModel({
    required this.id,
    this.clientId,
    this.clientName,
    required this.title,
    this.type,
    this.category,
    this.priority,
    this.status,
    this.statusNote,
    this.startDateYmd,
    this.dueDateYmd,
    this.snoozedUntilYmd,
    this.assignedToEmail,
    this.assignedToUid,
    this.seriesId,
    this.clientStartMailSent = false,
    this.calendarHtmlLink,
  });

  bool get isCompleted => status == 'COMPLETED';

  String get normalizedCategory {
    final u = (category ?? '').toUpperCase().replaceAll(' ', '_');
    if (u == 'INCOME_TAX' || u == 'INCOME_TAX_RETURN') return 'INCOME_TAX';
    if (['GST', 'TDS', 'ROC', 'ACCOUNTING', 'AUDIT'].contains(u)) return u;
    return 'OTHER';
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      clientId: json['clientId'],
      clientName: json['clientName'],
      title: json['title'] ?? '',
      type: json['type'],
      category: json['category'],
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'PENDING',
      statusNote: json['statusNote'],
      startDateYmd: json['startDateYmd'],
      dueDateYmd: json['dueDateYmd'],
      snoozedUntilYmd: json['snoozedUntilYmd'],
      assignedToEmail: json['assignedToEmail'],
      assignedToUid: json['assignedToUid'],
      seriesId: json['seriesId'],
      clientStartMailSent: json['clientStartMailSent'] ?? false,
      calendarHtmlLink: json['calendarHtmlLink'],
    );
  }
}
