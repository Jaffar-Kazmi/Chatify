class ProfileModel {
  final String id;
  final String username;
  final String email;
  final String? profilePic;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePic,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePic: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }
}
