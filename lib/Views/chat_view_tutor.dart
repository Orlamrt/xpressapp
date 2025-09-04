import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});

  final ControllerTeach controller = Get.find<ControllerTeach>();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat con el Terapeuta',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF2DCD8),
      body: Column(
        children: [
          // Área de mensajes (vacía)
          Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Ejemplo de mensaje (remover en implementación real)
                _buildMessageBubble(
                  context: context,
                  isMe: true,
                  text: "Ejemplo de mensaje enviado",
                ),
                _buildMessageBubble(
                  context: context,
                  isMe: false,
                  text: "Ejemplo de mensaje recibido",
                ),
              ],
            ),
          ),

          // Campo de entrada (sin lógica)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Campo de texto
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2DCD8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(color: Color(0xDDD96C94)),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Botón de enviar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xDDD96C94),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xDDD96C94).withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Lógica de envío se implementará aquí

                      final messageText = messageController.text.trim();
                      if (messageText.isEmpty) return;

                      // Enviar mensaje como tutor
                      controller.sendMessage(messageText, 'tutor');
                      // 🔔 Notificación al terapeuta
                      controller.notificationService.showNewMessageNotification(
                        'Tutor',
                        messageText,
                      );

                      messageController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para mostrar burbujas de ejemplo (remover en implementación real)
  Widget _buildMessageBubble({
    required BuildContext context,
    required bool isMe,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xDDD96C94) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isMe ? Colors.white : const Color(0xDDD96C94),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
