// models/chat_model.dart
class ChatModel {
  final String id;
  final String therapistName;
  final String lastMessage;
  final DateTime timestamp;

  ChatModel({
    required this.id,
    required this.therapistName,
    required this.lastMessage,
    required this.timestamp,
  });
}
