import 'package:flutter/material.dart';
import '../models/video.dart';
import '../services/user_service.dart';
import '../services/video_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  final VideoService _videoService;

  UserProvider(this._userService, this._videoService);

  Future<bool> updateProfile({
    String? name,
    String? username,
    String? bio,
  }) async {
    try {
      return await _userService.updateProfile(
        name: name,
        username: username,
        bio: bio,
      );
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await _userService.getUserProfile(userId);
  }

  Future<bool> followUser(String userId) async {
    return await _userService.followUser(userId);
  }

  Future<bool> unfollowUser(String userId) async {
    return await _userService.unfollowUser(userId);
  }

  Future<List<Video>> loadMyVideos(String userId) async {
    return await _videoService.getUserVideos(userId);
  }
}
