import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isOwnProfile;
  final bool isFollowing;
  final VoidCallback? onFollowTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfileHeader({
    super.key,
    required this.user,
    this.isOwnProfile = false,
    this.isFollowing = false,
    this.onFollowTap,
    this.onEditTap,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'avatar_${user.userId}',
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.grey200,
                  backgroundImage: user.profileImage.isNotEmpty
                      ? CachedNetworkImageProvider(user.profileImage)
                      : null,
                  child: user.profileImage.isEmpty
                      ? Icon(Icons.person, size: 44, color: AppColors.grey400)
                      : null,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn(label: 'Posts', count: user.postsCount),
                    GestureDetector(
                      onTap: onFollowersTap,
                      child: _StatColumn(
                        label: 'Followers',
                        count: user.followersCount,
                      ),
                    ),
                    GestureDetector(
                      onTap: onFollowingTap,
                      child: _StatColumn(
                        label: 'Following',
                        count: user.followingCount,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Username
          Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),

          // Bio
          if (user.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(user.bio, style: const TextStyle(fontSize: 14)),
            ),

          const SizedBox(height: 14),

          // Action button
          SizedBox(
            width: double.infinity,
            child: isOwnProfile
                ? OutlinedButton(
                    onPressed: onEditTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
                            ? AppColors.cardDarkBorder
                            : AppColors.grey200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  )
                : ElevatedButton(
                    onPressed: onFollowTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? (isDark ? AppColors.cardDark : AppColors.grey100)
                          : AppColors.primaryPurple,
                      foregroundColor: isFollowing
                          ? (isDark ? Colors.white : AppColors.grey900)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isFollowing ? 'Following' : 'Follow'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey500)),
      ],
    );
  }
}
