import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'package:xpresatecch/Models/chat_model.dart';
import 'package:xpresatecch/Views/chat_view_tutor.dart';
class AllChatsView extends StatelessWidget {
  final ControllerTeach controller = Get.find<ControllerTeach>();

  @override
  Widget build(BuildContext context) {
    // Lista simulada de chats
    final List<ChatModel> chats = [
      ChatModel(
        id: '1',
        therapistName: 'Dr. Ana López',
        lastMessage: 'Hola, ¿cómo estás?',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      ChatModel(
        id: '2',
        therapistName: 'Lic. Carlos Pérez',
        lastMessage: 'Claro,puede venir a revisar el consultorio',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
      ChatModel(
        id: '3',
        therapistName: 'Dra. María García',
        lastMessage: '¿En que le puedo ayudar?',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => AllChatsView());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todos los Chats'),
          backgroundColor: const Color(0xFFF2DCD8),
          titleTextStyle: const TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
           automaticallyImplyLeading: false
        ), 
         backgroundColor: const Color(0xFFF2DCD8),
        body: ListView.builder(
          
          padding: const EdgeInsets.all(8.0),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(chat.therapistName),
                subtitle: Text(chat.lastMessage),
                trailing: Text(
                  '${chat.timestamp.hour}:${chat.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  // Navegar a la vista del chat con el terapeuta seleccionado
                  Get.to(() => ChatView());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
