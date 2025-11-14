import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

class ChatMessage {
  final String from;
  final String to;
  final String text;
  final DateTime timestamp;
  final bool isSelf;

  ChatMessage({
    required this.from,
    required this.to,
    required this.text,
    required this.timestamp,
    required this.isSelf,
  });
}

class ChatController extends GetxController {
  static const _chatUrl = 'wss://xpressatec.online/ws/chat';

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isConnecting = false.obs;
  final RxBool isConnected = false.obs;
  final RxString connectionError = ''.obs;
  final RxString currentRecipientEmail = ''.obs;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController recipientEmailController = TextEditingController();

  late final AuthController _authController;
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Worker? _emailWorker;

  String _userEmail = '';
  bool _manuallyClosed = false;

  String get userEmail => _userEmail;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();

    _emailWorker = ever<String>(_authController.userEmail, (value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty && trimmed != _userEmail) {
        _initializeConnection();
      }
    });

    _initializeConnection();
  }

  @override
  void onClose() {
    _manuallyClosed = true;
    _emailWorker?.dispose();
    _closeChannel();
    messageController.dispose();
    recipientEmailController.dispose();
    super.onClose();
  }

  void _initializeConnection() {
    if (isConnecting.value) {
      return;
    }

    final emailFromState = _authController.userEmail.value.trim();
    final fallbackEmail = _authController.currentUser.value?.email ?? '';
    final email = emailFromState.isNotEmpty ? emailFromState : fallbackEmail.trim();

    if (email.isEmpty) {
      connectionError.value = 'No se pudo obtener el correo del usuario.';
      isConnected.value = false;
      return;
    }

    _userEmail = email;
    _manuallyClosed = false;
    connectionError.value = '';
    isConnecting.value = true;

    _closeChannel();

    final uri = Uri.parse('$_chatUrl?email=${Uri.encodeComponent(email)}');

    try {
      _channel = WebSocketChannel.connect(uri);
      _listenToChannel();
      isConnected.value = true;
    } catch (e) {
      isConnected.value = false;
      connectionError.value = e.toString();
      Get.snackbar(
        'Error de conexión',
        'No se pudo conectar al chat. Intenta nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConnecting.value = false;
    }
  }

  void reconnect() {
    _initializeConnection();
  }

  void _listenToChannel() {
    _channelSubscription?.cancel();

    if (_channel == null) {
      return;
    }

    _channelSubscription = _channel!.stream.listen(
      _handleSocketMessage,
      onDone: _handleSocketClosed,
      onError: _handleSocketError,
      cancelOnError: true,
    );
  }

  void _handleSocketMessage(dynamic data) {
    if (data == null) {
      return;
    }

    Map<String, dynamic>? payload;

    try {
      if (data is String) {
        payload = jsonDecode(data) as Map<String, dynamic>;
      } else if (data is List<int>) {
        payload = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      }
    } catch (_) {
      return;
    }

    if (payload == null) {
      return;
    }

    final type = (payload['type'] ?? 'message').toString();

    switch (type) {
      case 'connected':
        isConnected.value = true;
        connectionError.value = '';
        break;
      case 'message':
        final text = payload['message']?.toString() ?? '';
        if (text.isEmpty) {
          return;
        }

        final from = payload['from']?.toString() ?? '';
        final to = payload['to']?.toString() ?? '';
        final isSelf = payload['isSelf'] is bool
            ? payload['isSelf'] as bool
            : from.toLowerCase() == _userEmail.toLowerCase();
        final timestamp = _parseTimestamp(payload['timestamp']);

        final chatMessage = ChatMessage(
          from: from,
          to: to,
          text: text,
          timestamp: timestamp,
          isSelf: isSelf,
        );

        _addMessage(chatMessage);
        break;
      case 'error':
      case 'info':
        final infoMessage = payload['message']?.toString();
        if (infoMessage != null && infoMessage.isNotEmpty) {
          Get.snackbar(
            type == 'error' ? 'Error' : 'Información',
            infoMessage,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        break;
      default:
        break;
    }
  }

  void _handleSocketClosed() {
    isConnected.value = false;
    if (_manuallyClosed) {
      return;
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!_manuallyClosed) {
        _initializeConnection();
      }
    });
  }

  void _handleSocketError(Object error) {
    connectionError.value = error.toString();
    isConnected.value = false;

    if (!_manuallyClosed) {
      Get.snackbar(
        'Error de conexión',
        'Se perdió la conexión con el chat. Reintentando...',
        snackPosition: SnackPosition.BOTTOM,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!_manuallyClosed) {
          _initializeConnection();
        }
      });
    }
  }

  void setRecipientEmail(String email) {
    final trimmed = email.trim();

    if (trimmed.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingresa un correo para el destinatario.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(trimmed)) {
      Get.snackbar(
        'Error',
        'Ingresa un correo válido.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    currentRecipientEmail.value = trimmed;
    recipientEmailController.text = trimmed;
  }

  Future<void> sendMessage() async {
    final to = currentRecipientEmail.value.trim();
    final text = messageController.text.trim();

    if (to.isEmpty) {
      Get.snackbar(
        'Destinatario requerido',
        'Selecciona o ingresa el correo del destinatario antes de enviar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(to)) {
      Get.snackbar(
        'Error',
        'El correo del destinatario no es válido.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (text.isEmpty) {
      return;
    }

    final channel = _channel;
    if (channel == null || !isConnected.value) {
      Get.snackbar(
        'Sin conexión',
        'No hay conexión activa con el chat. Intenta reconectar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final payload = {
      'to': to,
      'message': text,
    };

    try {
      channel.sink.add(jsonEncode(payload));
      messageController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar el mensaje. Inténtalo nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<ChatMessage> get visibleMessages {
    final recipient = currentRecipientEmail.value.trim().toLowerCase();

    if (recipient.isEmpty) {
      return List<ChatMessage>.from(messages);
    }

    final me = _userEmail.toLowerCase();

    return messages.where((message) {
      final from = message.from.toLowerCase();
      final to = message.to.toLowerCase();
      final involvesRecipient = from == recipient || to == recipient;
      final involvesMe = from == me || to == me;
      return involvesRecipient && involvesMe;
    }).toList();
  }

  DateTime _parseTimestamp(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return parsed.toLocal();
      }
    }

    return DateTime.now();
  }

  void _addMessage(ChatMessage message) {
    messages.add(message);
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _closeChannel() {
    _channelSubscription?.cancel();
    _channelSubscription = null;

    _channel?.sink.close();
    _channel = null;

    isConnected.value = false;
  }
}
