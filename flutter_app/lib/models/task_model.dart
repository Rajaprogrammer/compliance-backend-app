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
  final String? delayReason;
  final String? delayNotes;
  final String? startDateYmd;
  final String? dueDateYmd;
  final String? snoozedUntilYmd;
  final String? assignedToEmail;
  final String? assignedToUid;
  final String? seriesId;
  final int? triggerDaysBefore;
  final bool sendClientStartMail;
  final bool sendClientCompletionMail;
  final bool clientStartMailSent;
  final String? clientStartGmailThreadId;
  final String? calendarHtmlLink;
  final List<String>? clientToEmails;
  final List<String>? clientCcEmails;
  final List<String>? clientBccEmails;
  final String? clientStartSubject;
  final String? clientStartBody;
  final String? clientCompletionSubject;
  final String? clientCompletionBody;
  final bool ccAssigneeOnClientStart;
  final bool ccManagerOnClientStart;
  final bool ccAssigneeOnCompletion;
  final bool ccManagerOnCompletion;
  final List<Map<String, dynamic>> attachments;

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
    this.delayReason,
    this.delayNotes,
    this.startDateYmd,
    this.dueDateYmd,
    this.snoozedUntilYmd,
    this.assignedToEmail,
    this.assignedToUid,
    this.seriesId,
    this.triggerDaysBefore,
    this.sendClientStartMail = true,
    this.sendClientCompletionMail = true,
    this.clientStartMailSent = false,
    this.clientStartGmailThreadId,
    this.calendarHtmlLink,
    this.clientToEmails,
    this.clientCcEmails,
    this.clientBccEmails,
    this.clientStartSubject,
    this.clientStartBody,
    this.clientCompletionSubject,
    this.clientCompletionBody,
    this.ccAssigneeOnClientStart = false,
    this.ccManagerOnClientStart = false,
    this.ccAssigneeOnCompletion = false,
    this.ccManagerOnCompletion = false,
    this.attachments = const [],
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get hasSeries => seriesId != null && seriesId!.isNotEmpty;

  String get normalizedCategory {
    final u = (category ?? '').toUpperCase().replaceAll(' ', '_');
    if (u == 'INCOME_TAX' || u == 'INCOME_TAX_RETURN' || u == 'INCOME') return 'INCOME_TAX';
    if (['GST', 'TDS', 'ROC', 'ACCOUNTING', 'AUDIT'].contains(u)) return u;
    return 'OTHER';
  }

  String get normalizedPriority => (priority ?? 'MEDIUM').toUpperCase();

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
      delayReason: json['delayReason'],
      delayNotes: json['delayNotes'],
      startDateYmd: json['startDateYmd'],
      dueDateYmd: json['dueDateYmd'],
      snoozedUntilYmd: json['snoozedUntilYmd'],
      assignedToEmail: json['assignedToEmail'],
      assignedToUid: json['assignedToUid'],
      seriesId: json['seriesId'],
      triggerDaysBefore: json['triggerDaysBefore'],
      sendClientStartMail: json['sendClientStartMail'] ?? true,
      sendClientCompletionMail: json['sendClientCompletionMail'] ?? true,
      clientStartMailSent: json['clientStartMailSent'] ?? false,
      clientStartGmailThreadId: json['clientStartGmailThreadId'],
      calendarHtmlLink: json['calendarHtmlLink'],
      clientToEmails: json['clientToEmails'] != null ? List<String>.from(json['clientToEmails']) : null,
      clientCcEmails: json['clientCcEmails'] != null ? List<String>.from(json['clientCcEmails']) : null,
      clientBccEmails: json['clientBccEmails'] != null ? List<String>.from(json['clientBccEmails']) : null,
      clientStartSubject: json['clientStartSubject'],
      clientStartBody: json['clientStartBody'],
      clientCompletionSubject: json['clientCompletionSubject'],
      clientCompletionBody: json['clientCompletionBody'],
      ccAssigneeOnClientStart: json['ccAssigneeOnClientStart'] ?? false,
      ccManagerOnClientStart: json['ccManagerOnClientStart'] ?? false,
      ccAssigneeOnCompletion: json['ccAssigneeOnCompletion'] ?? false,
      ccManagerOnCompletion: json['ccManagerOnCompletion'] ?? false,
      attachments: json['attachments'] != null ? List<Map<String, dynamic>>.from(json['attachments']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'clientName': clientName,
    'title': title,
    'type': type,
    'category': category,
    'priority': priority,
    'status': status,
    'statusNote': statusNote,
    'delayReason': delayReason,
    'delayNotes': delayNotes,
    'startDateYmd': startDateYmd,
    'dueDateYmd': dueDateYmd,
    'snoozedUntilYmd': snoozedUntilYmd,
    'assignedToEmail': assignedToEmail,
    'assignedToUid': assignedToUid,
    'seriesId': seriesId,
    'triggerDaysBefore': triggerDaysBefore,
    'sendClientStartMail': sendClientStartMail,
    'sendClientCompletionMail': sendClientCompletionMail,
  };
}
