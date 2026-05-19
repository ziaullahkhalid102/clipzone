import 'dart:io';
import '../config/api_config.dart';
import '../models/video.dart';
import '../models/comment.dart';
import 'api_service.dart';

class VideoService {
  final ApiService _api;

  VideoService(this._api);

  Future<List<Video>> getFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await _api.get(
        '${ApiConfig.clipsApi}/feed?page=$page&limit=$limit',
      );
      final List<dynamic> videos = response['videos'] ?? [];
      return videos.map((v) => Video.fromJson(v)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Video>> getTrending({int page = 1}) async {
    try {
      final response = await _api.get(
        '${ApiConfig.clipsApi}/trending?page=$page',
      );
      final List<dynamic> videos = response['videos'] ?? [];
      return videos.map((v) => Video.fromJson(v)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Video>> getUserVideos(String userId) async {
    try {
      final response = await _api.get(
        '${ApiConfig.clipsApi}/user/$userId',
      );
      final List<dynamic> videos = response['videos'] ?? [];
      return videos.map((v) => Video.fromJson(v)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Video?> uploadVideo(
    File file, {
    required String caption,
    List<String> hashtags = const [],
  }) async {
    try {
      final response = await _api.uploadFile(
        '${ApiConfig.clipsApi}/upload',
        file,
        fields: {
          'caption': caption,
          'hashtags': hashtags.join(','),
        },
      );
      if (response['video'] != null) {
        return Video.fromJson(response['video']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> likeVideo(String videoId) async {
    try {
      final response = await _api.post(
        '${ApiConfig.clipsApi}/$videoId/like',
      );
      return response['liked'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> recordView(String videoId) async {
    try {
      await _api.post('${ApiConfig.clipsApi}/$videoId/view');
    } catch (_) {}
  }

  Future<List<Comment>> getComments(String videoId, {int page = 1}) async {
    try {
      final response = await _api.get(
        '${ApiConfig.clipsApi}/$videoId/comments?page=$page',
      );
      final List<dynamic> comments = response['comments'] ?? [];
      return comments.map((c) => Comment.fromJson(c)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Comment?> addComment(String videoId, String text) async {
    try {
      final response = await _api.post(
        '${ApiConfig.clipsApi}/$videoId/comments',
        body: {'text': text},
      );
      if (response['comment'] != null) {
        return Comment.fromJson(response['comment']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteVideo(String videoId) async {
    try {
      await _api.delete('${ApiConfig.clipsApi}/$videoId');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Video>> searchVideos(String query) async {
    try {
      final response = await _api.get(
        '${ApiConfig.searchApi}/videos?q=$query',
      );
      final List<dynamic> videos = response['videos'] ?? [];
      return videos.map((v) => Video.fromJson(v)).toList();
    } catch (e) {
      return [];
    }
  }
}
