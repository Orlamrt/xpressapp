class Message {
  final String text;
  final String sender; // Puede ser "tutor" o "terapeuta"
  final DateTime timestamp;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}