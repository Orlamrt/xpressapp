import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Controllers/controller.dart'; // Asegúrate de que la ruta de importación sea correcta.

class ChatViewTerapeuta extends StatelessWidget {
  final ControllerTeach controller = Get.find<ControllerTeach>();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con el Tutor'),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[controller.messages.length - 1 - index];
                  final isTerapeuta = message.sender == 'terapeuta';
                  return Align(
                    alignment: isTerapeuta ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isTerapeuta ? Colors.purpleAccent : Colors.greenAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Campo de entrada de texto y botón de enviar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Envía el mensaje como terapeuta
                    controller.sendMessage(messageController.text, 'terapeuta');
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
