import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../config/theme.dart';

class Helpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false, bool isSuccess = false, int durationSeconds = 3}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.danger : (isSuccess ? AppTheme.success : null),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : durationSeconds),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static Future<void> downloadBase64File({
    required BuildContext context,
    required String base64Data,
    required String fileName,
    String? mimeType,
  }) async {
    try {
      final bytes = base64Decode(base64Data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('\${dir.path}/\$fileName');
      await file.writeAsBytes(bytes);
      
      await OpenFilex.open(file.path);
      
      if (context.mounted) {
        showSnackBar(context, 'File saved: \$fileName', isSuccess: true);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Download failed: \$e', isError: true);
      }
    }
  }

  static Future<void> copyToClipboard(BuildContext context, String text, {String? successMessage}) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSnackBar(context, successMessage ?? 'Copied to clipboard', isSuccess: true, durationSeconds: 2);
    }
  }

  static List<String> parseEmailList(String? input) {
    if (input == null || input.isEmpty) return [];
    return input
        .split(RegExp(r'[;,:]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.contains('@'))
        .toList();
  }

  static String joinEmails(List<String>? emails) {
    if (emails == null || emails.isEmpty) return '';
    return emails.join('; ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '\${text.substring(0, maxLength)}...';
  }

  static Color getCategoryColor(String? category) {
    final normalized = (category ?? 'OTHER').toUpperCase().replaceAll(' ', '_');
    return AppTheme.categoryColors[normalized] ?? AppTheme.gray;
  }

  static Color getPriorityColor(String? priority) {
    final normalized = (priority ?? 'MEDIUM').toUpperCase();
    return AppTheme.priorityColors[normalized] ?? AppTheme.orange;
  }

  static String replaceTemplateVariables(String template, Map<String, String> variables) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{{\$key}}', value);
    });
    return result;
  }

  static String tokensToRealLines(String s) => s.replaceAll('\\n', '\n');
  static String realLinesToTokens(String s) => s.replaceAll('\n', '\\n');
}
