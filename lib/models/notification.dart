class AppNotification {
  final String id;
  final String type; // 'like', 'comment', 'follow', 'mention'
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPicture;
  final String? videoId;
  final String? videoCaption;
  final String? commentText;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPicture,
    this.videoId,
    this.videoCaption,
    this.commentText,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? 'like',
      fromUserId: json['fromUserId'] ?? '',
      fromUserName: json['fromUserName'] ?? '',
      fromUserPicture: json['fromUserPicture'],
      videoId: json['videoId'],
      videoCaption: json['videoCaption'],
      commentText: json['commentText'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get message {
    switch (type) {
      case 'like':
        return 'liked your video';
      case 'comment':
        return 'commented: ${commentText ?? ""}';
      case 'follow':
        return 'started following you';
      case 'mention':
        return 'mentioned you in a comment';
      default:
        return 'interacted with your content';
    }
  }
}
