import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xpressatec/presentation/features/chat/controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    this.conversation,
    this.showRecipientSelector = true,
  }) : super(key: key);

  final ChatConversation? conversation;
  final bool showRecipientSelector;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  Worker? _messagesWorker;
  late final ChatController _controller;
  ChatConversation? _initialConversation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ChatController>();
    _initialConversation = widget.conversation ?? _extractConversationFromArguments();
    _messagesWorker = ever<List<ChatMessage>>(_controller.messages, (_) {
      _scrollToBottom();
    });

    if (_initialConversation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.openConversation(_initialConversation!);
      });
    }
  }

  @override
  void dispose() {
    _messagesWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Obx(() {
          final name = _controller.currentRecipientName.value;
          final role = _controller.currentRecipientRole.value;
          if (name.isEmpty && role.isEmpty) {
            return Text(
              'Chat en tiempo real',
              style: theme.textTheme.titleLarge,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name.isEmpty ? 'Chat' : name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (role.isNotEmpty)
                Text(
                  role,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
            ],
          );
        }),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.showRecipientSelector)
              _RecipientSelector(controller: _controller)
            else
              _ConversationHeader(controller: _controller),
            _ConnectionStatusBanner(controller: _controller),
            Expanded(
              child: Obx(() {
                final visibleMessages = _controller.visibleMessages;

                if (_controller.isConnecting.value && visibleMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (visibleMessages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hay mensajes todavía. Selecciona un destinatario e inicia la conversación.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: visibleMessages.length,
                  itemBuilder: (context, index) {
                    final message = visibleMessages[index];
                    return _MessageBubble(message: message);
                  },
                );
              }),
            ),
            _MessageInput(controller: _controller),
          ],
        ),
      ),
    );
  }

  ChatConversation? _extractConversationFromArguments() {
    final args = Get.arguments;
    if (args is ChatConversation) {
      return args;
    }
    if (args is Map<String, dynamic>) {
      final value = args['conversation'];
      if (value is ChatConversation) {
        return value;
      }
    }
    return null;
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final email = controller.currentRecipientEmail.value;
      final name = controller.currentRecipientName.value;
      final role = controller.currentRecipientRole.value;

      if (email.isEmpty && name.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.isEmpty ? email : name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (role.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  role,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (email.isNotEmpty && name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _RecipientSelector extends StatelessWidget {
  final ChatController controller;

  const _RecipientSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.recipientEmailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Correo del terapeuta (destinatario)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => controller
                    .setRecipientEmail(controller.recipientEmailController.text),
              ),
            ),
            onSubmitted: controller.setRecipientEmail,
          ),
          const SizedBox(height: 8),
          Obx(() {
            final recipient = controller.currentRecipientEmail.value;
            final text = recipient.isEmpty
                ? 'Ningún destinatario seleccionado'
                : 'Conversación con: $recipient';

            return Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            );
          }),
        ],
      ),
    );
  }
}

class _ConnectionStatusBanner extends StatelessWidget {
  final ChatController controller;

  const _ConnectionStatusBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isConnected.value) {
        return const SizedBox.shrink();
      }

      final isConnecting = controller.isConnecting.value;
      final message = isConnecting
          ? 'Conectando con el chat...'
          : 'Desconectado. Reintentando conexión...';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.orange.withOpacity(0.15),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[800],
                    ),
              ),
            ),
            if (!isConnecting)
              TextButton(
                onPressed: controller.reconnect,
                child: const Text('Reintentar'),
              ),
          ],
        ),
      );
    });
  }
}

class _MessageInput extends StatelessWidget {
  final ChatController controller;

  const _MessageInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: controller.sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final isSelf = message.isSelf;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSelf) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                message.from.isNotEmpty
                    ? message.from.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isSelf)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message.from,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelf
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelf ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeFormat.format(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelf
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSelf) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                message.from.isNotEmpty
                    ? message.from.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
