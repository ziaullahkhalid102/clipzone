import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  AuthProvider(this._authService) {
    _init();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    final token = await _authService.getToken();
    if (token != null) {
      _user = await _authService.getCurrentUser();
      _isLoggedIn = _user != null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> handleLoginCallback(String token) async {
    await _authService.saveToken(token);
    _user = await _authService.getCurrentUser();
    _isLoggedIn = _user != null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  String getLoginUrl() => _authService.getLoginUrl();
}
