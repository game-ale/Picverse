import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/core/utils/date_formatter.dart';
import 'package:picverse/core/widgets/animated_like_button.dart';
import 'package:picverse/features/admin/domain/repositories/admin_repository.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_event.dart';
import 'package:picverse/features/post/data/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    this.isLiked = false,
    this.onTap,
    this.onProfileTap,
    this.onCommentTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (!widget.isLiked) {
      context.read<FeedBloc>().add(
        FeedPostLikeToggled(postId: widget.post.postId, isLiked: false),
      );
    }
    setState(() => _showHeart = true);
    _heartController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: isDark ? AppColors.grey900 : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: GestureDetector(
              onTap: widget.onProfileTap,
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar_${widget.post.userId}',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.grey200,
                      backgroundImage: widget.post.userProfileImage.isNotEmpty
                          ? CachedNetworkImageProvider(widget.post.userProfileImage)
                          : null,
                      child: widget.post.userProfileImage.isEmpty
                          ? Icon(Icons.person, size: 20, color: AppColors.grey400)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPostOptions(context),
                    child: Icon(
                      Icons.more_horiz,
                      color: isDark ? Colors.white70 : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image with double-tap heart overlay
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onDoubleTap: _onDoubleTap,
                onTap: widget.onTap,
                child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: isDark ? AppColors.cardDark : AppColors.grey100,
                    ),
                  ),
                  errorWidget: (_, __, ___) => AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: isDark ? AppColors.cardDark : AppColors.grey100,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
              if (_showHeart)
                ScaleTransition(
                  scale: _heartScale,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 80,
                    shadows: [
                      Shadow(blurRadius: 20, color: Colors.black54),
                    ],
                  ),
                ),
            ],
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                AnimatedLikeButton(
                  isLiked: widget.isLiked,
                  onTap: () {
                    context.read<FeedBloc>().add(
                      FeedPostLikeToggled(
                        postId: widget.post.postId,
                        isLiked: widget.isLiked,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  onTap: widget.onCommentTap,
                ),
                const SizedBox(width: 14),
                _ActionButton(icon: Icons.send_outlined, onTap: () {}),
                const Spacer(),
                _ActionButton(icon: Icons.bookmark_border, onTap: () {}),
              ],
            ),
          ),

          // Like count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${widget.post.likesCount} likes',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),

          // Caption
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                  children: [
                    TextSpan(
                      text: '${widget.post.username} ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
            ),

          // Comment count
          if (widget.post.commentsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: GestureDetector(
                onTap: widget.onCommentTap,
                child: Text(
                  'View all ${widget.post.commentsCount} comments',
                  style: TextStyle(color: AppColors.grey500, fontSize: 13),
                ),
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: Text(
              DateFormatter.timeAgo(widget.post.createdAt),
              style: TextStyle(color: AppColors.grey500, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.orange),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showReportReasons(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportReasons(BuildContext context) {
    final reasons = [
      ('Spam', 'spam'),
      ('Harassment', 'harassment'),
      ('Violence', 'violence'),
      ('Fake Account', 'fakeAccount'),
      ('Other', 'other'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Why are you reporting this post?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
              for (final (label, value) in reasons)
                ListTile(
                  title: Text(label),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final adminRepo = context.read<AdminRepository>();
                    final uid = context.read<AuthService>().currentUser?.uid ?? '';
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await adminRepo.createReport(
                        postId: widget.post.postId,
                        reportedBy: uid,
                        reason: value,
                      );
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Report submitted')),
                      );
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Failed to submit report')),
                      );
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 26),
    );
  }
}
