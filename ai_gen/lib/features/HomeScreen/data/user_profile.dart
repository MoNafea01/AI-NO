class UserProfile {
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String bio;
  final String? image;

  UserProfile( {
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.bio,
    this.image,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      bio: json['profile']['bio'] ?? '',
      image: json['profile']['image'],
    );
  }
}
