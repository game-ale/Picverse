import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/features/search/presentation/bloc/search_bloc.dart';
import 'package:picverse/features/search/presentation/bloc/search_event.dart';
import 'package:picverse/features/search/presentation/bloc/search_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputDark : AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(color: AppColors.grey500, fontSize: 15),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.grey500,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 15),
            onChanged: (query) {
              context.read<SearchBloc>().add(SearchQueryChanged(query: query));
            },
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state.status == SearchStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SearchStatus.initial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(
                    'Search for users',
                    style: TextStyle(color: AppColors.grey500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (state.results.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: TextStyle(color: AppColors.grey500, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final user = state.results[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
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
                    ? Text(
                        user.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () => context.push('/profile/${user.userId}'),
              );
            },
          );
        },
      ),
    );
  }
}
