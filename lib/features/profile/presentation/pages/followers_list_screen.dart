import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/auth/data/models/user_model.dart';
import 'package:picverse/core/services/firestore_service.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(_followers, _loadingFollowers),
          _buildUserList(_following, _loadingFollowing),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, bool loading) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (users.isEmpty) {
      return Center(
        child: Text('No users', style: TextStyle(color: AppColors.grey500)),
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
