// controllers/sound_controller.dart
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SoundController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  RxBool isSoundEnabled = true.obs;
  RxString selectedVoice = "".obs;
  RxDouble speechRate = 0.5.obs;
  RxDouble pitch = 1.0.obs;
  RxList<Map<String, dynamic>> availableVoices = <Map<String, dynamic>>[].obs;

  // Definir tipos de voces personalizadas
  final List<Map<String, dynamic>> customVoices = [
    {"name": "Voz Masculina Normal", "pitch": 1.0, "rate": 0.5},
    {"name": "Voz Masculina Grave", "pitch": 0.8, "rate": 0.45},
    {"name": "Voz Femenina Normal", "pitch": 1.2, "rate": 0.5},
    {"name": "Voz Femenina Suave", "pitch": 1.4, "rate": 0.55},
  ];

  @override
  void onInit() {
    super.onInit();
    _initTTS();
  }

  Future<void> _initTTS() async {
    try {
      await flutterTts.setLanguage("es-ES");
      await flutterTts.setSpeechRate(speechRate.value);
      await flutterTts.setPitch(pitch.value);

      // Configurar voces personalizadas
      availableVoices.value = customVoices;

      if (availableVoices.isNotEmpty) {
        selectedVoice.value = availableVoices[0]["name"];
        await _applyVoiceSettings(availableVoices[0]);
      }
    } catch (e) {
      print('Error al inicializar TTS: $e');
    }
  }

  Future<void> setRate(double value) async {
    try {
      speechRate.value = value;
      await flutterTts.setSpeechRate(value);
    } catch (e) {
      print('Error al ajustar velocidad: $e');
    }
  }

  Future<void> _applyVoiceSettings(Map<String, dynamic> voiceSettings) async {
    try {
      await flutterTts.setPitch(voiceSettings["pitch"]);
      await flutterTts.setSpeechRate(voiceSettings["rate"]);
      pitch.value = voiceSettings["pitch"];
      speechRate.value = voiceSettings["rate"];
    } catch (e) {
      print('Error al aplicar configuración de voz: $e');
    }
  }

  Future<void> setVoice(String voiceName) async {
    try {
      final selectedVoiceSettings = customVoices.firstWhere(
        (voice) => voice["name"] == voiceName,
        orElse: () => customVoices[0],
      );

      selectedVoice.value = voiceName;
      await _applyVoiceSettings(selectedVoiceSettings);
    } catch (e) {
      print('Error al cambiar voz: $e');
    }
  }

  Future<void> speak(String text) async {
    if (isSoundEnabled.value) {
      try {
        await flutterTts.speak(text);
      } catch (e) {
        print('Error al reproducir texto: $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      await flutterTts.stop();
    } catch (e) {
      print('Error al detener reproducción: $e');
    }
  }

  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    if (!isSoundEnabled.value) {
      stop();
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
