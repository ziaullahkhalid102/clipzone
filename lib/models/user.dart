class User {
  final String id;
  final String email;
  final String name;
  final String? picture;
  final String? username;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int videosCount;
  final int totalLikes;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    this.username,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.videosCount = 0,
    this.totalLikes = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      picture: json['picture'],
      username: json['username'],
      bio: json['bio'],
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      videosCount: json['videosCount'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': picture,
      'username': username,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'videosCount': videosCount,
      'totalLikes': totalLikes,
    };
  }
}
