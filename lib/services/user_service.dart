import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  Future<User?> getProfile(String userId) async {
    try {
      final response = await _api.get(
        '${ApiConfig.profilesApi}/$userId',
      );
      if (response['user'] != null) {
        return User.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _api.get(
        '${ApiConfig.profilesApi}/$userId',
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? username,
    String? bio,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (username != null) body['username'] = username;
      if (bio != null) body['bio'] = bio;
      await _api.put('${ApiConfig.profilesApi}/me', body: body);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      final response = await _api.post(
        '${ApiConfig.profilesApi}/$userId/follow',
      );
      return response['following'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      await _api.delete('${ApiConfig.profilesApi}/$userId/follow');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _api.get(
        '${ApiConfig.searchApi}/users?q=$query',
      );
      final List<dynamic> users = response['users'] ?? [];
      return users.map((u) => User.fromJson(u)).toList();
    } catch (e) {
      return [];
    }
  }
}
