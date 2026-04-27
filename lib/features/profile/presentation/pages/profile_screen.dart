import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/local/language_cubit.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/core/theme/theme_cubit.dart';
import 'package:picverse/core/widgets/shimmer_loading.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_event.dart';
import 'package:picverse/features/profile/presentation/bloc/profile_state.dart';
import 'package:picverse/features/profile/presentation/widgets/posts_grid.dart';
import 'package:picverse/features/profile/presentation/widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(
      ProfileLoadRequested(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = context.read<AuthService>().currentUser?.uid ?? '';
    final isOwnProfile = currentUid == widget.userId;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return Text(state.user?.username ?? '');
          },
        ),
        actions: isOwnProfile
            ? [
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state.user?.role == 'admin') {
                      return IconButton(
                        icon: const Icon(Icons.admin_panel_settings),
                        onPressed: () => context.push('/admin'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _showLogoutSheet(context),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.push('/chats/open/${widget.userId}'),
                ),
              ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.user == null) {
            return const ProfileHeaderSkeleton();
          }

          if (state.status == ProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? l10n.text('errorLoadingProfile')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileBloc>().add(
                      ProfileLoadRequested(userId: widget.userId),
                    ),
                    child: Text(l10n.text('retry')),
                  ),
                ],
              ),
            );
          }

          if (state.user == null) return const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ProfileHeader(
                  user: state.user!,
                  isOwnProfile: isOwnProfile,
                  isFollowing: state.isFollowing,
                  onFollowTap: () => context.read<ProfileBloc>().add(
                    ProfileFollowToggled(targetUserId: widget.userId),
                  ),
                  onEditTap: () => context.push('/edit-profile'),
                  onFollowersTap: () =>
                      context.push('/followers/${widget.userId}?tab=followers'),
                  onFollowingTap: () =>
                      context.push('/followers/${widget.userId}?tab=following'),
                ),
              ),
              const SliverToBoxAdapter(child: Divider(height: 1)),
              PostsGrid(
                posts: state.posts,
                onPostTap: (post) => context.push('/comments/${post.postId}'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<ThemeCubit, ThemeMode>(
              bloc: context.read<ThemeCubit>(),
              builder: (ctx, mode) {
                final icon = switch (mode) {
                  ThemeMode.light => Icons.light_mode,
                  ThemeMode.dark => Icons.dark_mode,
                  ThemeMode.system => Icons.brightness_auto,
                };
                final label = switch (mode) {
                  ThemeMode.light => l10n.text('lightMode'),
                  ThemeMode.dark => l10n.text('darkMode'),
                  ThemeMode.system => l10n.text('systemDefault'),
                };
                return ListTile(
                  leading: Icon(icon, color: AppColors.primaryPurple),
                  title: Text(label),
                  subtitle: Text(l10n.text('tapChangeTheme')),
                  onTap: () => context.read<ThemeCubit>().toggleTheme(),
                );
              },
            ),
            const Divider(height: 1),
            BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, color: AppColors.primaryPurple),
                      title: Text(l10n.text('selectLanguage')),
                    ),
                    for (final option in const [
                      Locale('en'),
                      Locale('om'),
                      Locale('am'),
                    ])
                      ListTile(
                        title: Text(
                          switch (option.languageCode) {
                            'en' => l10n.text('english'),
                            'om' => l10n.text('afaanOromo'),
                            _ => l10n.text('amharic'),
                          },
                        ),
                        trailing: locale.languageCode == option.languageCode
                            ? const Icon(Icons.check, color: AppColors.primaryPurple)
                            : null,
                        onTap: () => context.read<LanguageCubit>().setLanguage(option),
                      ),
                  ],
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                l10n.text('logOut'),
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthService>().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
