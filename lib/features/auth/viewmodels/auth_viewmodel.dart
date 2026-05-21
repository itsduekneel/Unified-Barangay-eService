import 'package:flutter/material.dart';
import '../../../repositories/auth_repository.dart';
import '../../../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AuthViewModel(this._repository) {
    _init();
  }

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _init() async {
    _user = await _repository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _repository.signIn(email, password);
      return _user != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
