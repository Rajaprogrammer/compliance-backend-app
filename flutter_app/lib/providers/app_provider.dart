import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/client_model.dart';
import '../utils/date_utils.dart';

class AppProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _themeKey = 'cos_theme_mode';
  static const String _sidebarKey = 'cos_sidebar_collapsed';

  List<TaskModel> _tasks = [];
  List<ClientModel> _clients = [];
  Map<String, ClientModel> _clientsById = {};
  ThemeMode _themeMode = ThemeMode.system;
  int _selectedNavIndex = 0;
  bool _sidebarCollapsed = false;
  bool _isInitialized = false;

  List<TaskModel> get tasks => _tasks;
  List<ClientModel> get clients => _clients;
  Map<String, ClientModel> get clientsById => _clientsById;
  ThemeMode get themeMode => _themeMode;
  int get selectedNavIndex => _selectedNavIndex;
  bool get sidebarCollapsed => _sidebarCollapsed;
  bool get isInitialized => _isInitialized;

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final themeModeStr = prefs.getString(_themeKey);
      if (themeModeStr == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeModeStr == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }

      _sidebarCollapsed = prefs.getBool(_sidebarKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: \$e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String value = 'system';
      if (mode == ThemeMode.light) value = 'light';
      if (mode == ThemeMode.dark) value = 'dark';
      await prefs.setString(_themeKey, value);
    } catch (e) {
      debugPrint('Error saving theme: \$e');
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  Future<void> setSidebarCollapsed(bool collapsed) async {
    _sidebarCollapsed = collapsed;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sidebarKey, collapsed);
    } catch (e) {
      debugPrint('Error saving sidebar state: \$e');
    }
  }

  void toggleSidebar() {
    setSidebarCollapsed(!_sidebarCollapsed);
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  Stream<List<TaskModel>> tasksStream({bool isPartnerOrManager = false}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    Query query;
    if (isPartnerOrManager) {
      query = _firestore.collection('tasks').limit(2500);
    } else {
      query = _firestore.collection('tasks').where('assignedToUid', isEqualTo: user.uid).limit(2500);
    }

    return query.snapshots().map((snapshot) {
      _tasks = snapshot.docs.map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
      notifyListeners();
      return _tasks;
    });
  }

  Stream<List<ClientModel>> clientsStream() {
    return _firestore.collection('clients').orderBy('name').limit(1200).snapshots().map((snapshot) {
      _clients = snapshot.docs.map((doc) => ClientModel.fromJson(doc.data(), doc.id)).toList();
      _clientsById = {for (var c in _clients) c.id: c};
      notifyListeners();
      return _clients;
    });
  }

  String? getClientName(String? clientId) {
    if (clientId == null) return null;
    return _clientsById[clientId]?.name;
  }

  ClientModel? getClient(String? clientId) {
    if (clientId == null) return null;
    return _clientsById[clientId];
  }

  TaskModel? getTask(String taskId) {
    return _tasks.firstWhere((t) => t.id == taskId, orElse: () => throw Exception('Task not found'));
  }

  // Stats computation
  Map<String, int> computeStats() {
    final today = AppDateUtils.todayYmd();
    int startToday = 0, dueToday = 0, due7 = 0, overdue = 0, approval = 0, snoozed = 0;

    for (final task in _tasks) {
      // Snoozed
      if (task.snoozedUntilYmd != null && task.snoozedUntilYmd!.isNotEmpty) {
        if (task.status != 'COMPLETED' && task.snoozedUntilYmd!.compareTo(today) > 0) {
          snoozed++;
        }
      }

      if (task.status == 'APPROVAL_PENDING') approval++;
      if (task.status != 'COMPLETED' && task.startDateYmd == today) startToday++;

      if (task.dueDateYmd == null || task.dueDateYmd!.isEmpty) continue;
      final dd = AppDateUtils.diffDays(today, task.dueDateYmd!);

      if (task.status != 'COMPLETED') {
        if (dd < 0) overdue++;
        if (dd == 0) dueToday++;
        if (dd >= 0 && dd <= 7) due7++;
      }
    }

    return {
      'startToday': startToday,
      'dueToday': dueToday,
      'due7': due7,
      'overdue': overdue,
      'approval': approval,
      'snoozed': snoozed,
      'total': _tasks.length,
    };
  }

  List<TaskModel> getFocusTasks({int limit = 25}) {
    final today = AppDateUtils.todayYmd();
    final focus = <TaskModel>[];

    for (final task in _tasks) {
      if (task.status == 'COMPLETED') continue;
      if (task.dueDateYmd == null || task.dueDateYmd!.isEmpty) continue;

      final dd = AppDateUtils.diffDays(today, task.dueDateYmd!);
      if (dd <= 3) focus.add(task);
    }

    focus.sort((a, b) => (a.dueDateYmd ?? '').compareTo(b.dueDateYmd ?? ''));
    return focus.take(limit).toList();
  }
}
