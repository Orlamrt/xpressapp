import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/sound_controller.dart';

class VoiceSettingsView extends StatelessWidget {
  final SoundController soundController = Get.find<SoundController>();

  VoiceSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Voz'),
        backgroundColor: const Color(0xFFF2DCD8),
        titleTextStyle: const TextStyle(
          fontSize: 32,
          color: Color(0xDDD96C94),
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      backgroundColor: const Color(0xFFF2DCD8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Switch para activar/desactivar sonido
              Obx(() => SwitchListTile(
                    title: const Text('Sonido Activado'),
                    value: soundController.isSoundEnabled.value,
                    onChanged: (value) => soundController.toggleSound(),
                    activeColor: const Color(0xDDD96C94),
                  )),

              const SizedBox(height: 20),

              // Selector de voces personalizadas
              const Text(
                'Seleccionar Tipo de Voz:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Obx(() => Column(
                    children: soundController.customVoices.map((voice) {
                      return Card(
                        color: Colors.white,
                        child: RadioListTile<String>(
                          title: Text(voice["name"]!),
                          value: voice["name"]!,
                          groupValue: soundController.selectedVoice.value,
                          onChanged: (value) async {
                            if (value != null) {
                              await soundController.setVoice(value);
                              // Probar la voz automáticamente
                              await soundController.speak("Esta es una prueba de ${value}");
                            }
                          },
                          activeColor: const Color(0xDDD96C94),
                        ),
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 20),

              // Control de velocidad
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Velocidad de la voz:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Obx(() => Slider(
                            value: soundController.speechRate.value,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            label: soundController.speechRate.value.toStringAsFixed(1),
                            onChanged: (value) async {
                              await soundController.setRate(value);
                              // Probar la velocidad automáticamente
                              await soundController.speak("Probando velocidad");
                            },
                            activeColor: const Color(0xDDD96C94),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Botón de prueba
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => soundController.speak(
                      "Esta es una prueba con la voz ${soundController.selectedVoice.value}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xDDD96C94),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.record_voice_over),
                  label: const Text('Probar configuración actual'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
