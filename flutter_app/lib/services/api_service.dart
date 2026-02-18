import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/constants.dart';

class ApiResponse {
  final bool ok;
  final dynamic data;
  final String? error;
  final int statusCode;

  ApiResponse({required this.ok, this.data, this.error, required this.statusCode});
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.backendBaseUrl;

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(ok: false, error: 'Not signed in', statusCode: 401);
      }

      final response = await http.post(
        Uri.parse('\$_baseUrl\$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$token',
        },
        body: jsonEncode(body),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'raw': response.body};
      }

      final bool isOk = data is Map && data['ok'] == true || response.statusCode == 200;
      return ApiResponse(
        ok: isOk,
        data: data,
        error: data is Map ? data['error'] : null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(ok: false, error: e.toString(), statusCode: 0);
    }
  }

  Future<ApiResponse> initSelf({String? displayName}) async {
    return post('/users_initself', {'displayName': displayName ?? ''});
  }

  Future<ApiResponse> updateTaskStatus({
    required String taskId,
    required String newStatus,
    String? statusNote,
  }) async {
    return post('/tasks_updatestatus', {
      'taskId': taskId,
      'newStatus': newStatus,
      'statusNote': statusNote,
    });
  }

  Future<ApiResponse> createTask(Map<String, dynamic> taskData) async {
    return post('/tasks_createone', taskData);
  }

  Future<ApiResponse> bulkUpdate({
    required List<String> taskIds,
    required String op,
    Map<String, dynamic>? payload,
  }) async {
    return post('/tasks_bulkUpdate', {
      'taskIds': taskIds,
      'op': op,
      ...?payload,
    });
  }
}
