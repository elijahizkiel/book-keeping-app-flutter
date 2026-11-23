import 'package:flutter/material.dart';
import 'package:bookkeeping_app/app/theme/app_colors.dart';

class AvatarBadge extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final double radius;

  const AvatarBadge({
    super.key,
    required this.initials,
    this.imageUrl,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppColors.primary.withOpacity(0.15),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withOpacity(0.2),
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}
