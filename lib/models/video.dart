class Video {
  final String id;
  final String userId;
  final String userName;
  final String? userPicture;
  final String driveFileId;
  final String caption;
  final List<String> hashtags;
  final String? thumbnailUrl;
  final String videoUrl;
  final int duration;
  final int views;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final DateTime createdAt;

  Video({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPicture,
    required this.driveFileId,
    required this.caption,
    this.hashtags = const [],
    this.thumbnailUrl,
    required this.videoUrl,
    this.duration = 0,
    this.views = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPicture: json['userPicture'],
      driveFileId: json['driveFileId'] ?? '',
      caption: json['caption'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'] ?? '',
      duration: json['duration'] ?? 0,
      views: json['views'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
