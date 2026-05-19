import 'dart:io';
import 'package:flutter/material.dart';
import '../models/video.dart';
import '../models/comment.dart';
import '../services/video_service.dart';

class FeedProvider extends ChangeNotifier {
  final VideoService _videoService;
  List<Video> _feedVideos = [];
  List<Video> _trendingVideos = [];
  bool _isLoading = false;
  bool _isUploading = false;
  int _currentPage = 1;

  FeedProvider(this._videoService);

  List<Video> get feedVideos => _feedVideos;
  List<Video> get trendingVideos => _trendingVideos;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  Future<void> loadFeed({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _feedVideos = [];
    }

    _isLoading = true;
    notifyListeners();

    final videos = await _videoService.getFeed(page: _currentPage);
    if (refresh) {
      _feedVideos = videos;
    } else {
      _feedVideos.addAll(videos);
    }
    _currentPage++;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTrending() async {
    _trendingVideos = await _videoService.getTrending();
    notifyListeners();
  }

  Future<Video?> uploadVideo(
    File file, {
    required String caption,
    List<String> hashtags = const [],
  }) async {
    _isUploading = true;
    notifyListeners();

    try {
      final video = await _videoService.uploadVideo(
        file,
        caption: caption,
        hashtags: hashtags,
      );
      if (video != null) {
        _feedVideos.insert(0, video);
      }
      return video;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> likeVideo(String videoId) async {
    final liked = await _videoService.likeVideo(videoId);
    final index = _feedVideos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      notifyListeners();
    }
    return liked;
  }

  Future<void> recordView(String videoId) async {
    await _videoService.recordView(videoId);
  }

  Future<List<Comment>> getComments(String videoId) async {
    return await _videoService.getComments(videoId);
  }

  Future<Comment?> addComment(String videoId, String text) async {
    return await _videoService.addComment(videoId, text);
  }

  Future<List<Video>> searchVideos(String query) async {
    return await _videoService.searchVideos(query);
  }
}
