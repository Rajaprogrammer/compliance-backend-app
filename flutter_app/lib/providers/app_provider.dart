import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../models/client_model.dart';

class AppProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TaskModel> _tasks = [];
  List<ClientModel> _clients = [];
  Map<String, ClientModel> _clientsById = {};
  ThemeMode _themeMode = ThemeMode.system;
  int _selectedNavIndex = 0;

  List<TaskModel> get tasks => _tasks;
  List<ClientModel> get clients => _clients;
  Map<String, ClientModel> get clientsById => _clientsById;
  ThemeMode get themeMode => _themeMode;
  int get selectedNavIndex => _selectedNavIndex;

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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
}
