import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';
import 'package:picverse/core/services/firestore_service.dart';

enum ConnectionsFilter { all, withBio, withPhoto }

class FollowersListScreen extends StatefulWidget {
  final String userId;
  final String initialTab;

  const FollowersListScreen({
    super.key,
    required this.userId,
    this.initialTab = 'followers',
  });

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _loadingFollowers = true;
  bool _loadingFollowing = true;
  ConnectionsFilter _filter = ConnectionsFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'following' ? 1 : 0,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final fs = context.read<FirestoreService>();
    final followers = await fs.getFollowers(widget.userId);
    final following = await fs.getFollowing(widget.userId);
    if (mounted) {
      setState(() {
        _followers = followers;
        _following = following;
        _loadingFollowers = false;
        _loadingFollowing = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('connectionsFilter')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.text('followers')),
            Tab(text: l10n.text('following')),
          ],
        ),
      ),
      body: Column(
        children: [
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.text('allPeople'),
                  selected: _filter == ConnectionsFilter.all,
                  onSelected: () => setState(() => _filter = ConnectionsFilter.all),
                ),
                _FilterChip(
                  label: l10n.text('withBio'),
                  selected: _filter == ConnectionsFilter.withBio,
                  onSelected: () =>
                      setState(() => _filter = ConnectionsFilter.withBio),
                ),
                _FilterChip(
                  label: l10n.text('withProfilePhoto'),
                  selected: _filter == ConnectionsFilter.withPhoto,
                  onSelected: () =>
                      setState(() => _filter = ConnectionsFilter.withPhoto),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(_filtered(_followers), _loadingFollowers, l10n),
                _buildUserList(_filtered(_following), _loadingFollowing, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<UserModel> _filtered(List<UserModel> users) {
    switch (_filter) {
      case ConnectionsFilter.all:
        return users;
      case ConnectionsFilter.withBio:
        return users.where((user) => user.bio.trim().isNotEmpty).toList();
      case ConnectionsFilter.withPhoto:
        return users.where((user) => user.profileImage.trim().isNotEmpty).toList();
    }
  }

  Widget _buildUserList(List<UserModel> users, bool loading, AppLocalizations l10n) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (users.isEmpty) {
      return Center(
        child: Text(l10n.text('noUsersFound'), style: TextStyle(color: AppColors.grey500)),
      );
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.grey200,
            backgroundImage: user.profileImage.isNotEmpty
                ? CachedNetworkImageProvider(user.profileImage)
                : null,
            child: user.profileImage.isEmpty
                ? const Icon(Icons.person, color: AppColors.grey400)
                : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: user.bio.isNotEmpty
              ? Text(user.bio, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          onTap: () => context.push('/profile/${user.userId}'),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
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
