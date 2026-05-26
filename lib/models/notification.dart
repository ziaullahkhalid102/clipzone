class AppNotification {
  final String id;
  final String type;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPicture;
  final String? videoId;
  final String? videoCaption;
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
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserPicture: fromUserPicture,
      videoId: videoId,
      videoCaption: videoCaption,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      fromUserId: json['fromUserId'] ?? '',
      fromUserName: json['fromUserName'] ?? '',
      fromUserPicture: json['fromUserPicture'],
      videoId: json['videoId'],
      videoCaption: json['videoCaption'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
