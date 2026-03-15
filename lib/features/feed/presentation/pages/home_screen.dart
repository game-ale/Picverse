import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/widgets/offline_banner.dart';
import 'package:picverse/core/widgets/shimmer_loading.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_event.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_state.dart';
import 'package:picverse/features/post/presentation/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(FeedLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Picverse',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: isDark ? Colors.white : AppColors.grey900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => context.go('/notifications'),
          ),
        ],
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          if (state.status == FeedStatus.loading) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, __) => const PostCardSkeleton(),
            );
          }

          if (state.status == FeedStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Something went wrong'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FeedBloc>().add(FeedLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.status == FeedStatus.empty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Follow people or create your first post!',
                    style: TextStyle(color: AppColors.grey500),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (state.isOffline) const OfflineBanner(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<FeedBloc>().add(FeedRefreshRequested());
                  },
                  child: ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      final isLiked = state.likedPostIds.contains(post.postId);
                      return _StaggeredFadeSlide(
                        index: index,
                        child: PostCard(
                          post: post,
                          isLiked: isLiked,
                          onProfileTap: () =>
                              context.push('/profile/${post.userId}'),
                          onCommentTap: () =>
                              context.push('/comments/${post.postId}'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Animates each feed item with a staggered fade + upward slide.
class _StaggeredFadeSlide extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredFadeSlide({required this.index, required this.child});

  @override
  State<_StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<_StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger delay capped at 5 items to avoid long waits on large feeds.
    final delay = Duration(milliseconds: 60 * widget.index.clamp(0, 5));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
