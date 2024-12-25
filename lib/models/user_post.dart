class User {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String phoneNumber;
  final bool emailConfirmed;
  final bool phoneNumberConfirmed;
  final bool twoFactorEnabled;
  final bool lockoutEnabled;
  final DateTime createdAt;
  final String? avatar;  // Thay đổi ProfileImage thành Avatar
  final String? initials;
  final String? securityStamp;
  final String? concurrencyStamp;

  User({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.emailConfirmed,
    required this.phoneNumberConfirmed,
    required this.twoFactorEnabled,
    required this.lockoutEnabled,
    required this.createdAt,
    this.avatar,  // Dùng Avatar thay cho ProfileImage
    this.initials,
    this.securityStamp,
    this.concurrencyStamp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      emailConfirmed: json['emailConfirmed'] ?? false,
      phoneNumberConfirmed: json['phoneNumberConfirmed'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      lockoutEnabled: json['lockoutEnabled'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      avatar: json['avatar'],  // Thay đổi profileImage thành avatar
      initials: json['initials'],
      securityStamp: json['securityStamp'],
      concurrencyStamp: json['concurrencyStamp'],
    );
  }
}
