class User {
  final int userId;
  final bool ispassenger;
  final String email;
  final String fullName;
  final String accessToken;
  final String refreshToken;

  User({
    required this.userId,
    required this.ispassenger,
    required this.email,
    required this.fullName,
    required this.accessToken,
    required this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      ispassenger: json['is_passenger'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }
}
