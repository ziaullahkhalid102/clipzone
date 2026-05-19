import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cg_token', token);
    _api.setToken(token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cg_token');
    if (token != null) {
      _api.setToken(token);
    }
    return token;
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cg_api_key', apiKey);
    _api.setApiKey(apiKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('cg_api_key');
    if (apiKey != null) {
      _api.setApiKey(apiKey);
    }
    return apiKey;
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _api.get('${ApiConfig.authApi}/me');
      if (response['user'] != null) {
        return User.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String getLoginUrl() {
    return '${ApiConfig.baseUrl}/api/auth/google';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cg_token');
    await prefs.remove('cg_api_key');
    _api.clearAuth();
  }
}
