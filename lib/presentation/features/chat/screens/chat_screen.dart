import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xpressatec/presentation/features/chat/controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  Worker? _messagesWorker;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ChatController>();
    _messagesWorker = ever<List<ChatMessage>>(controller.messages, (_) {
      _scrollToBottom();
    });
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
    final controller = Get.find<ChatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat en tiempo real'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _RecipientSelector(controller: controller),
            _ConnectionStatusBanner(controller: controller),
            Expanded(
              child: Obx(() {
                final visibleMessages = controller.visibleMessages;

                if (controller.isConnecting.value && visibleMessages.isEmpty) {
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
            _MessageInput(controller: controller),
          ],
        ),
      ),
    );
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
