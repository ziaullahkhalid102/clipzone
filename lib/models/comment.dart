class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userPicture;
  final String videoId;
  final String text;
  final int likesCount;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPicture,
    required this.videoId,
    required this.text,
    this.likesCount = 0,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPicture: json['userPicture'],
      videoId: json['videoId'] ?? '',
      text: json['text'] ?? '',
      likesCount: json['likesCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
