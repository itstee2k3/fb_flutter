class Post {
  final int id;
  final String title;
  final String description;
  final String? image;
  final DateTime dateCreate;
  final PostUser user; // Renaming User to PostUser

  Post({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.dateCreate,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      dateCreate: DateTime.parse(json['dateCreate']),
      user: PostUser.fromJson(json['user']), // Using PostUser here
    );
  }
}

class PostUser {
  final String id;
  final String userName;
  final String? avatar;  // Avatar of the user

  PostUser({
    required this.id,
    required this.userName,
    this.avatar,  // Avatar URL of the user
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'],
      userName: json['userName'],
      avatar: json['avatar'],  // Avatar URL
    );
  }
}
