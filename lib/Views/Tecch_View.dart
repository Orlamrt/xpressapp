import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Components/mosaico_component.dart';
import 'package:xpresatecch/Components/selected_image_list_component.dart';
import 'package:xpresatecch/Constants/colors.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'package:xpresatecch/Controllers/mp3_controller.dart';
import 'package:xpresatecch/Models/image_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TecchView extends StatefulWidget {
  const TecchView({super.key});

  @override
  State<TecchView> createState() => _TecchView();
}

class _TecchView extends State<TecchView> {
  final pallete = Pallete();
  final scrollController = ScrollController();
  final controller = Get.find<ControllerTeach>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Evitar el retroceso
        return false;
      },
      child: Obx(
        () => Scaffold(
                floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _buildModalContent(context);
                },
              );
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.interpreter_mode),
          ),
          backgroundColor: const Color(0xFFF2DCD8),
          appBar: AppBar(
            title: const Text('Teacch'),
            backgroundColor: const Color(0xFFF2DCD8),
            titleTextStyle: const TextStyle(
              fontSize: 32,
              color: Color(0xDDD96C94),
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            automaticallyImplyLeading: false,
            actions: [
              if (controller.imagenes.isNotEmpty)
                if (controller.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        // Obtener el rol del usuario desde SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        final userRole = prefs.getString('userRole');

                        List<String> partesCadena = [];
                        String cadena = '';
                        
                        for (ImageModel imagen in controller.imagenes) {
                          partesCadena.add(imagen.nameOfImage!.toLowerCase());
                        }
                        
                        cadena = partesCadena.join(' ');
                        cadena = ImageModel.capitalize(cadena);
                        String data = await controller.enviarSolicitud(cadena);

                        // Solo registrar la sesión si el usuario es un paciente
                        if (userRole == 'Paciente') {
                          if (data != 'Error') {
                            // REGISTRAR SESIÓN EXITOSA
                            controller.recordSession(controller.imagenes, true, cadena);
                          } else {
                            // REGISTRAR SESIÓN FALLIDA
                            controller.recordSession(controller.imagenes, false, cadena);
                          }
                        }

                        // Limpiar imágenes después de procesar
                        controller.imagenes.clear();
                      },
                    ),
                  ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Imágenes seleccionadas en la parte superior
                  if (controller.imagenes.isNotEmpty)
                    SizedBox(
                      height:
                          200, // ajusta la altura según el tamaño que quieras
                      child: SelectedImageListComponent(),
                    ),

                  // Espacio entre la lista de imágenes y el mosaico
                  if (controller.imagenes.isNotEmpty)
                    const SizedBox(height: 10),

                  // Mosaico de tarjetas
                  Expanded(
                    flex: 1, // Puedes ajustar el flex para el espacio que ocupa
                    child: MosaicoComponent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildModalContent(BuildContext context) {
       final audioController = Get.find<AudioController>();
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: Obx(
            () => Column(
          children: [
            const Text(
              'Escoge a tu asistentte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioListTile(
              title: const Text('Isamar'),
              value: 'isamar',
              groupValue: controller.selectedAssistant.value,
              onChanged: (value) {
                
                controller.selectedAssistant.value = value.toString();
                    audioController.playAudio(
                    subDirectory: 'audio',
                    fileName: 'isamarAssistantGreetings.mp3'
                  );
                print(value.toString()); // <-- Move this line before Navigator.pop
                Navigator.pop(context);

              },
            ),
            RadioListTile(

              title: const Text('Emmanuel'),
              value: 'emmanuel',

              groupValue: controller.selectedAssistant.value,

              onChanged: (value) {
                controller.selectedAssistant.value = value.toString();
            audioController.playAudio(
                    subDirectory: 'audio',
                    fileName: 'emmanuelAssistantGreetings.mp3'
                  );
                print(value.toString()); // <-- Move this line before Navigator.pop
                Navigator.pop(context);
              },
            ),
                 RadioListTile<String>(
        // Change title
        title: const Text('Laura'),
        // Change value
        value: 'laura',
        groupValue: controller.selectedAssistant.value,
        onChanged: (value) {
          if (value == null) return;
          // Change selected value
          controller.selectedAssistant.value = value;
          // Change greeting audio file (make sure this file exists)
          audioController.playAudio(
              subDirectory: 'audio',
              fileName: 'lauraAssistantGreetings.mp3'
          );
          Navigator.pop(context);
        },
      ),
      RadioListTile<String>(
        // Change title
        title: const Text('Alex'),
        // Change value
        value: 'alex',
        groupValue: controller.selectedAssistant.value,
        onChanged: (value) {
          if (value == null) return;
          // Change selected value
          controller.selectedAssistant.value = value;
          // Change greeting audio file (make sure this file exists)
          audioController.playAudio(
              subDirectory: 'audio',
              fileName: 'alexAssistantGreetings.mp3'
          );
          Navigator.pop(context);
        },
      ),
          ],
        ),
      ),
    );
  }

  
}
