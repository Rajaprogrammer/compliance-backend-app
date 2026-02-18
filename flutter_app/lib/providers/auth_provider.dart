import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _api = ApiService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  bool get isPartner => _userModel?.isPartner ?? false;
  bool get isManager => _userModel?.isManager ?? false;
  bool get isAssociate => _userModel?.isAssociate ?? true;
  bool get canSeeAllTasks => _userModel?.canSeeAllTasks ?? false;
  bool get canEditDetails => _userModel?.canEditDetails ?? false;
  bool get canAccessClients => _userModel?.canAccessClients ?? false;
  bool get canAccessOps => _userModel?.canAccessOps ?? false;
  String get role => _userModel?.role ?? 'ASSOCIATE';
  String get email => _userModel?.email ?? _firebaseUser?.email ?? '';
  String get displayName => _userModel?.displayName ?? '';
  String get uid => _firebaseUser?.uid ?? '';

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      _userModel = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _api.initSelf();
      await _loadUserProfile(user.uid);
    } catch (e) {
      debugPrint('Error initializing user: \$e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromJson({
          ...doc.data()!,
          'uid': uid,
          'email': _firebaseUser?.email ?? '',
        });
      } else {
        _userModel = UserModel(
          uid: uid,
          email: _firebaseUser?.email ?? '',
          displayName: _firebaseUser?.email?.split('@')[0] ?? '',
          role: 'ASSOCIATE',
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: \$e');
      _userModel = UserModel(
        uid: uid,
        email: _firebaseUser?.email ?? '',
        displayName: _firebaseUser?.email?.split('@')[0] ?? '',
        role: 'ASSOCIATE',
      );
    }
  }

  Future<void> refreshProfile() async {
    if (_firebaseUser != null) {
      await _loadUserProfile(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Sign in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await _api.initSelf(displayName: email.split('@')[0]);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Sign up failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
