import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/video.dart';
import '../services/user_service.dart';
import '../services/video_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  final VideoService _videoService;

  User? _viewedProfile;
  List<Video> _userVideos = [];
  bool _isLoading = false;
  bool _isFollowing = false;

  UserProvider(this._userService, this._videoService);

  User? get viewedProfile => _viewedProfile;
  List<Video> get userVideos => _userVideos;
  bool get isLoading => _isLoading;
  bool get isFollowing => _isFollowing;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    _viewedProfile = await _userService.getProfile(userId);
    _userVideos = await _videoService.getUserVideos(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFollow(String userId) async {
    _isFollowing = !_isFollowing;
    notifyListeners();

    final result = await _userService.followUser(userId);
    _isFollowing = result;
    notifyListeners();

    // Refresh profile to get updated counts
    _viewedProfile = await _userService.getProfile(userId);
    notifyListeners();
  }

  Future<User?> updateProfile({
    String? name,
    String? username,
    String? bio,
  }) async {
    return await _userService.updateProfile(
      name: name,
      username: username,
      bio: bio,
    );
  }

  Future<List<User>> searchUsers(String query) async {
    return await _userService.searchUsers(query);
  }

  Future<List<Video>> loadMyVideos(String userId) async {
    _userVideos = await _videoService.getUserVideos(userId);
    notifyListeners();
    return _userVideos;
  }
}
