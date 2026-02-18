import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/constants.dart';

class ApiResponse {
  final bool ok;
  final dynamic data;
  final String? error;
  final int statusCode;

  ApiResponse({required this.ok, this.data, this.error, required this.statusCode});

  T? get<T>(String key) {
    if (data is Map) {
      return data[key] as T?;
    }
    return null;
  }
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
      ).timeout(const Duration(seconds: 30));

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'raw': response.body};
      }

      final bool isOk = (data is Map && data['ok'] == true) || response.statusCode == 200;
      return ApiResponse(
        ok: isOk,
        data: data,
        error: data is Map ? data['error']?.toString() : null,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(ok: false, error: e.toString(), statusCode: 0);
    }
  }

  Future<ApiResponse> uploadFile(String endpoint, Uint8List fileBytes, String fileName, Map<String, String> fields) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(ok: false, error: 'Not signed in', statusCode: 401);
      }

      final request = http.MultipartRequest('POST', Uri.parse('\$_baseUrl\$endpoint'));
      request.headers['Authorization'] = 'Bearer \$token';
      fields.forEach((key, value) => request.fields[key] = value);
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {'raw': response.body};
      }

      final bool isOk = (data is Map && data['ok'] == true) || response.statusCode == 200;
      return ApiResponse(ok: isOk, data: data, error: data is Map ? data['error']?.toString() : null, statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse(ok: false, error: e.toString(), statusCode: 0);
    }
  }

  // ==================== AUTH ====================
  Future<ApiResponse> initSelf({String? displayName}) => post('/users_initself', {'displayName': displayName ?? ''});

  // ==================== TASKS ====================
  Future<ApiResponse> createTask(Map<String, dynamic> taskData) => post('/tasks_createone', taskData);

  Future<ApiResponse> updateTaskStatus({
    required String taskId,
    required String newStatus,
    String? statusNote,
    String? delayReason,
    String? delayNotes,
  }) => post('/tasks_updatestatus', {
    'taskId': taskId,
    'newStatus': newStatus,
    'statusNote': statusNote,
    'delayReason': delayReason,
    'delayNotes': delayNotes,
  });

  Future<ApiResponse> updateTask(Map<String, dynamic> taskData) => post('/tasks_updatetask', taskData);

  Future<ApiResponse> deleteTask(String taskId, {bool applyToSeries = false}) => post('/tasks_delete', {
    'taskId': taskId,
    'applyToSeries': applyToSeries,
  });

  Future<ApiResponse> addComment(String taskId, String text) => post('/tasks_addcomment', {
    'taskId': taskId,
    'text': text,
  });

  Future<ApiResponse> bulkUpdate({
    required List<String> taskIds,
    required String op,
    Map<String, dynamic>? payload,
  }) => post('/tasks_bulkUpdate', {
    'taskIds': taskIds,
    'op': op,
    ...?payload,
  });

  // ==================== SERIES ====================
  Future<ApiResponse> rebuildSeries({required String seriesId, required int addCount}) => post('/series_rebuild', {
    'seriesId': seriesId,
    'addCount': addCount,
  });

  Future<ApiResponse> reassignSeries({required String seriesId, required String assignedToEmail}) => post('/series_reassign', {
    'seriesId': seriesId,
    'assignedToEmail': assignedToEmail,
  });

  // ==================== CLIENTS ====================
  Future<ApiResponse> createClient(Map<String, dynamic> clientData) => post('/clients_create', clientData);
  Future<ApiResponse> updateClient(Map<String, dynamic> clientData) => post('/clients_update', clientData);

  // ==================== EXPORTS ====================
  Future<ApiResponse> exportFirmRangeXlsx({required String fromDmy, required String toDmy, bool includeAudit = true}) => post('/exports_firmRangeWithHistoryXlsx', {
    'fromDmy': fromDmy,
    'toDmy': toDmy,
    'includeAudit': includeAudit,
  });

  Future<ApiResponse> exportClientHistoryXlsx({required String clientId, required String fromYmd, required String toYmd}) => post('/exports_clientHistoryXlsx', {
    'clientId': clientId,
    'fromYmd': fromYmd,
    'toYmd': toYmd,
  });

  Future<ApiResponse> exportTaskHistoryXlsx(String taskId) => post('/exports_taskHistoryXlsx', {'taskId': taskId});

  Future<ApiResponse> quickExport(String mode) => post('/exports_quickXlsx', {'mode': mode});

  Future<ApiResponse> exportImportTemplate() => post('/exports_myClientsTemplateXlsx', {});

  Future<ApiResponse> exportTasksUpdateTemplate() => post('/exports_tasksUpdateTemplateXlsx', {});

  Future<ApiResponse> exportTasksForUpdate({int limit = 600}) => post('/exports_tasksExportForUpdateXlsx', {'limitTasks': limit});

  // ==================== REPORTS ====================
  Future<ApiResponse> reportFirmRangePdf({required String fromDmy, required String toDmy}) => post('/reports_firmRangePdf', {
    'fromDmy': fromDmy,
    'toDmy': toDmy,
  });

  Future<ApiResponse> reportClientHistoryPdf({required String clientId, required String fromYmd, required String toYmd}) => post('/reports_clientHistoryPdf', {
    'clientId': clientId,
    'fromYmd': fromYmd,
    'toYmd': toYmd,
  });

  Future<ApiResponse> reportTaskHistoryPdf(String taskId) => post('/reports_taskHistoryPdf', {'taskId': taskId});

  Future<ApiResponse> reportDailyDigestPdf() => post('/reports_dailyDigestPdf', {});

  Future<ApiResponse> reportMonthlyPdf(String monthYmd) => post('/reports_monthlyPdf', {'monthYmd': monthYmd});

  // ==================== SETTINGS ====================
  Future<ApiResponse> getSettings() => post('/settings_get', {});
  Future<ApiResponse> updateSettings(Map<String, dynamic> settings) => post('/settings_update', settings);
  Future<ApiResponse> getCalendarSettings() => post('/settings_calendar_get', {});
  Future<ApiResponse> updateCalendarSettings(Map<String, dynamic> settings) => post('/settings_calendar_update', settings);
  Future<ApiResponse> setWorkerImportPassword(String password) => post('/settings_workerImportPassword_set', {'password': password});

  // ==================== USERS ====================
  Future<ApiResponse> listUsers() => post('/users_list', {});
  Future<ApiResponse> setUserRole({required String uid, required String role, bool active = true}) => post('/users_setrole', {
    'uid': uid,
    'role': role,
    'active': active,
  });
  Future<ApiResponse> setUserManager({required String uid, required String managerEmail}) => post('/users_setmanager', {
    'uid': uid,
    'managerEmail': managerEmail,
  });
  Future<ApiResponse> setUserDisplayName({required String uid, required String displayName}) => post('/users_setdisplayname', {
    'uid': uid,
    'displayName': displayName,
  });
  Future<ApiResponse> migrateRoles({bool dryRun = true, int limit = 800}) => post('/roles_migrate_worker_to_associate', {
    'dryRun': dryRun,
    'limit': limit,
  });
}
