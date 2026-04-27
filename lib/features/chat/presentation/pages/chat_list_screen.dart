import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/chat/domain/repositories/chat_repository.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_list_event.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_list_state.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthService>().currentUser?.uid ?? '';
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => ChatListBloc(context.read<ChatRepository>())
        ..add(ChatListStarted(currentUserId)),
        child: Scaffold(
          appBar: AppBar(
          title: Text(l10n.text('chats')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/chats/create-group'),
          child: const Icon(Icons.group_add),
        ),
        body: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state.status == ChatListStatus.loading ||
                state.status == ChatListStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ChatListStatus.error) {
              return Center(
                child: Text(state.errorMessage ?? l10n.text('couldNotLoadChats')),
              );
            }

            if (state.rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.grey400),
                    const SizedBox(height: 16),
                    Text(
                      l10n.text('noChatsYet'),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.text('startChatHint'),
                      style: TextStyle(color: AppColors.grey500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: state.rooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                final title = room.titleFor(currentUserId);
                final avatarUrl = room.avatarFor(currentUserId);
                final unreadCount = room.unreadCountFor(currentUserId);

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.grey200,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Icon(
                            room.isGroup ? Icons.group : Icons.chat_bubble,
                            color: AppColors.grey500,
                          )
                        : null,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                    subtitle: Text(
                      room.lastMessage?.isNotEmpty == true
                          ? room.lastMessage!
                        : l10n.text('sayHello'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  trailing: unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primaryPurple,
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : room.lastMessageAt != null
                          ? Text(_formatDate(room.lastMessageAt!))
                          : null,
                  onTap: () => context.push('/chats/${room.roomId}'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();
    if (now.difference(local).inDays == 0) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.month}/${local.day}';
  }
}
