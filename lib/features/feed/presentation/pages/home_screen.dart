import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/widgets/offline_banner.dart';
import 'package:picverse/core/widgets/shimmer_loading.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_event.dart';
import 'package:picverse/features/feed/presentation/bloc/feed_state.dart';
import 'package:picverse/features/post/data/models/post_model.dart';
import 'package:picverse/features/post/presentation/widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  FeedFilter _filter = FeedFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<FeedBloc>().add(FeedLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<FeedBloc>().add(FeedLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('/chats'),
          ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.text('filterBy'),
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FeedFilterChip(
                      label: l10n.text('all'),
                      selected: _filter == FeedFilter.all,
                      onSelected: () => setState(() => _filter = FeedFilter.all),
                    ),
                    _FeedFilterChip(
                      label: l10n.text('withCaption'),
                      selected: _filter == FeedFilter.withCaption,
                      onSelected: () =>
                          setState(() => _filter = FeedFilter.withCaption),
                    ),
                    _FeedFilterChip(
                      label: l10n.text('withImage'),
                      selected: _filter == FeedFilter.withImage,
                      onSelected: () =>
                          setState(() => _filter = FeedFilter.withImage),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<FeedBloc>().add(FeedRefreshRequested());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _filteredPosts(state).length +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      final posts = _filteredPosts(state);
                      if (index >= posts.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: state.hasReachedEnd
                                ? const SizedBox.shrink()
                                : const CircularProgressIndicator(),
                          ),
                        );
                      }
                      final post = posts[index];
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

  List<PostModel> _filteredPosts(FeedState state) {
    switch (_filter) {
      case FeedFilter.all:
        return state.posts;
      case FeedFilter.withCaption:
        return state.posts.where((post) => post.caption.trim().isNotEmpty).toList();
      case FeedFilter.withImage:
        return state.posts.where((post) => post.imageUrl.trim().isNotEmpty).toList();
    }
  }
}

enum FeedFilter { all, withCaption, withImage }

class _FeedFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FeedFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primaryPurple.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryPurple : AppColors.grey600,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? AppColors.primaryPurple : AppColors.grey200,
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
