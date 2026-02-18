import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String id;
  final String? taskId;
  final String action;
  final String? actorEmail;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    this.taskId,
    required this.action,
    this.actorEmail,
    this.details = const {},
    required this.timestamp,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime ts = DateTime.now();
    if (json['timestamp'] is Timestamp) {
      ts = (json['timestamp'] as Timestamp).toDate();
    }
    return AuditLogModel(
      id: id,
      taskId: json['taskId'],
      action: json['action'] ?? '',
      actorEmail: json['actorEmail'],
      details: json['details'] != null ? Map<String, dynamic>.from(json['details']) : {},
      timestamp: ts,
    );
  }
}
