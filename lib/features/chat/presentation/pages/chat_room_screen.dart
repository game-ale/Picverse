import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picverse/core/constants/app_colors.dart';
import 'package:picverse/core/local/app_localizations.dart';
import 'package:picverse/core/services/auth_service.dart';
import 'package:picverse/features/chat/domain/repositories/chat_repository.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_room_bloc.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_room_event.dart';
import 'package:picverse/features/chat/presentation/bloc/chat_room_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final String? roomId;
  final String? otherUserId;

  const ChatRoomScreen({
    super.key,
    this.roomId,
    this.otherUserId,
  }) : assert(roomId != null || otherUserId != null);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  Future<String>? _directRoomFuture;

  @override
  void initState() {
    super.initState();
    if (widget.roomId == null) {
      final repository = context.read<ChatRepository>();
      final currentUserId = context.read<AuthService>().currentUser?.uid ?? '';
      _directRoomFuture = repository.getOrCreateDirectRoom(
        currentUserId: currentUserId,
        otherUserId: widget.otherUserId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ChatRepository>();
    final currentUserId = context.read<AuthService>().currentUser?.uid ?? '';

    if (widget.roomId != null) {
      return BlocProvider(
        create: (_) => ChatRoomBloc(repository),
        child: ChatRoomView(
          roomId: widget.roomId!,
          currentUserId: currentUserId,
        ),
      );
    }

    return FutureBuilder<String>(
      future: _directRoomFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(snapshot.error.toString())),
          );
        }

        final resolvedRoomId = snapshot.data!;
        return BlocProvider(
          create: (_) => ChatRoomBloc(repository),
          child: ChatRoomView(
            roomId: resolvedRoomId,
            currentUserId: currentUserId,
          ),
        );
      },
    );
  }
}

class ChatRoomView extends StatefulWidget {
  final String roomId;
  final String currentUserId;

  const ChatRoomView({
    super.key,
    required this.roomId,
    required this.currentUserId,
  });

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final TextEditingController _messageController = TextEditingController();
  bool _markedRead = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatRoomBloc>().add(ChatRoomStarted(widget.roomId));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatRoomBloc>().add(
          ChatRoomSendMessageRequested(
            roomId: widget.roomId,
            senderId: widget.currentUserId,
            text: text,
          ),
        );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ChatRoomBloc, ChatRoomState>(
      listener: (context, state) {
        final room = state.room;
        if (room != null &&
            !_markedRead &&
            room.unreadCountFor(widget.currentUserId) > 0) {
          _markedRead = true;
          context.read<ChatRoomBloc>().add(
                ChatRoomMarkReadRequested(
                  roomId: widget.roomId,
                  userId: widget.currentUserId,
                ),
              );
        }
      },
      builder: (context, state) {
        final room = state.room;
        final title = room?.titleFor(widget.currentUserId) ?? l10n.text('chats');
        final avatarUrl = room?.avatarFor(widget.currentUserId) ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.grey200,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Icon(
                          room?.isGroup == true ? Icons.group : Icons.chat,
                          size: 18,
                          color: AppColors.grey500,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              if (state.status == ChatRoomStatus.error)
                MaterialBanner(
                  content: Text(state.errorMessage ?? l10n.text('couldNotLoadChats')),
                  actions: [
                    TextButton(
                      onPressed: () => context
                          .read<ChatRoomBloc>()
                          .add(ChatRoomStarted(widget.roomId)),
                      child: Text(l10n.text('retry')),
                    ),
                  ],
                ),
              Expanded(
                child: state.messages.isEmpty
                    ? Center(
                        child: Text(
                          l10n.text('startConversation'),
                          style: TextStyle(color: AppColors.grey500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isMine = message.senderId == widget.currentUserId;
                          return _MessageBubble(
                            message: message.text,
                            sender: message.senderUsername,
                            isMine: isMine,
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: l10n.text('writeMessage'),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.inputDark
                                : AppColors.grey100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: state.isSending ? null : _sendMessage,
                        icon: state.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final String sender;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.sender,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppColors.primaryPurple : AppColors.grey200;
    final textColor = isMine ? Colors.white : AppColors.grey900;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Text(
                sender,
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (!isMine) const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
