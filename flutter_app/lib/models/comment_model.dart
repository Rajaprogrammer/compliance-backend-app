import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String text;
  final String authorEmail;
  final String? authorName;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.text,
    required this.authorEmail,
    this.authorName,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime created = DateTime.now();
    if (json['createdAt'] is Timestamp) {
      created = (json['createdAt'] as Timestamp).toDate();
    }
    return CommentModel(
      id: id,
      text: json['text'] ?? '',
      authorEmail: json['authorEmail'] ?? '',
      authorName: json['authorName'],
      createdAt: created,
    );
  }
}
