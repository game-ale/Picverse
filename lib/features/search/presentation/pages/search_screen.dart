import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/search/presentation/bloc/search_bloc.dart';
import 'package:picverse/features/search/presentation/bloc/search_event.dart';
import 'package:picverse/features/search/presentation/bloc/search_state.dart';

enum _SearchFilter { all, hasBio, hasPhoto }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  _SearchFilter _filter = _SearchFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List resultsFor(SearchState state, String currentUserId) {
    final baseResults = state.results.where((user) => user.userId != currentUserId);
    switch (_filter) {
      case _SearchFilter.all:
        return baseResults.toList();
      case _SearchFilter.hasBio:
        return baseResults.where((user) => user.bio.trim().isNotEmpty).toList();
      case _SearchFilter.hasPhoto:
        return baseResults.where((user) => user.profileImage.trim().isNotEmpty).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = context.read<AuthService>().currentUser?.uid ?? '';
    final l10n = AppLocalizations.of(context);

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
              hintText: l10n.text('searchUsers'),
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
                    l10n.text('searchForUsers'),
                    style: TextStyle(color: AppColors.grey500, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final filteredResults = resultsFor(state, currentUserId);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.text('filterBy'),
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
                      label: l10n.text('all'),
                      selected: _filter == _SearchFilter.all,
                      onSelected: () => setState(() => _filter = _SearchFilter.all),
                    ),
                    _FilterChip(
                      label: l10n.text('hasBio'),
                      selected: _filter == _SearchFilter.hasBio,
                      onSelected: () => setState(() => _filter = _SearchFilter.hasBio),
                    ),
                    _FilterChip(
                      label: l10n.text('hasPhoto'),
                      selected: _filter == _SearchFilter.hasPhoto,
                      onSelected: () => setState(() => _filter = _SearchFilter.hasPhoto),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredResults.isEmpty
                    ? Center(
                        child: Text(
                          l10n.text('noUsersFound'),
                          style: TextStyle(color: AppColors.grey500, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredResults.length,
                        itemBuilder: (context, index) {
                          final user = filteredResults[index];
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
                            trailing: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () => context.push('/chats/open/${user.userId}'),
                            ),
                            onTap: () => context.push('/profile/${user.userId}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
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
