// lib/core/widgets/profile_avatar.dart
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.profileImageUrl,
    this.radius = 27,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = profileImageUrl != null &&
        profileImageUrl!.isNotEmpty &&
        (profileImageUrl!.startsWith('http://') ||
            profileImageUrl!.startsWith('https://'));

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: hasImage ? NetworkImage(profileImageUrl!) : null,
      child: hasImage
          ? null
          : Icon(
        Icons.person,
        size: radius * 1.2,
        color: Colors.grey[600],
      ),
    );
  }
}
