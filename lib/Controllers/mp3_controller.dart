// archivo: lib/controllers/audio_controller.dart

import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';



class AudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Plays an audio file from the assets folder.
  ///
  /// The [subDirectory] should be the path within `assets/audio/`.
  /// The [fileName] should be the name of the audio file, including its extension (e.g., 'my_audio.mp3').
  Future<void> playAudio({required String subDirectory, required String fileName}) async {
    final String assetPath = '$subDirectory/$fileName';

    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Ocurrió un error al reproducir el audio: $e');
    }
  }


  // GetX llama a este método automáticamente cuando el controlador ya no es necesario.
  @override
  void onClose() {
    print("Cerrando AudioController y liberando recursos...");
    _audioPlayer.dispose();
    super.onClose();
  }
}