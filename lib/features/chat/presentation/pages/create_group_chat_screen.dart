import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/chat/domain/repositories/chat_repository.dart';
import 'package:picverse/features/search/presentation/bloc/search_bloc.dart';
import 'package:picverse/features/search/presentation/bloc/search_event.dart';
import 'package:picverse/features/search/presentation/bloc/search_state.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  bool _isCreating = false;

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup(BuildContext context, SearchState state) async {
    final currentUserId = context.read<AuthService>().currentUser?.uid ?? '';
    if (_groupNameController.text.trim().isEmpty || _selectedUserIds.length < 2) {
      return;
    }
    final router = GoRouter.of(context);
    setState(() => _isCreating = true);
    try {
      final roomId = await context.read<ChatRepository>().createGroupRoom(
            creatorId: currentUserId,
            groupName: _groupNameController.text.trim(),
            participantIds: _selectedUserIds.toList(),
          );
      if (!mounted) return;
      router.go('/chats/$roomId');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthService>().currentUser?.uid ?? '';
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.text('createGroupChat')),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          final results = state.results
              .where((user) => user.userId != currentUserId)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: l10n.text('groupName'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: l10n.text('searchPeople'),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  context.read<SearchBloc>().add(SearchQueryChanged(query: query));
                },
              ),
              const SizedBox(height: 16),
              if (_selectedUserIds.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedUserIds.map((id) {
                    final user = results.where((u) => u.userId == id).firstOrNull;
                    return Chip(
                      label: Text(user?.username ?? id),
                      onDeleted: () {
                        setState(() => _selectedUserIds.remove(id));
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              if (state.status == SearchStatus.loading)
                const Center(child: CircularProgressIndicator())
              else if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      state.query.isEmpty
                          ? l10n.text('searchForPeopleToAdd')
                          : l10n.text('noUsersFound'),
                      style: TextStyle(color: AppColors.grey500),
                    ),
                  ),
                )
              else
                ...results.map((user) {
                  final selected = _selectedUserIds.contains(user.userId);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.grey200,
                        backgroundImage: user.profileImage.isNotEmpty
                            ? CachedNetworkImageProvider(user.profileImage)
                            : null,
                        child: user.profileImage.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(user.username),
                      subtitle: Text(user.bio),
                      trailing: Icon(
                        selected ? Icons.check_circle : Icons.add_circle_outline,
                        color: selected ? AppColors.primaryPurple : AppColors.grey400,
                      ),
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedUserIds.remove(user.userId);
                          } else {
                            _selectedUserIds.add(user.userId);
                          }
                        });
                      },
                    ),
                  );
                }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isCreating || _selectedUserIds.length < 2
                    ? null
                    : () => _createGroup(context, state),
                child: _isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(l10n.text('createGroup')),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
