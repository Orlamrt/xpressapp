import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Components/mosaico_component.dart';
import 'package:xpressapp/Components/selected_image_list_component.dart';
import 'package:xpressapp/Constants/colors.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Models/image_model.dart';
import 'package:xpressapp/Views/voice_settings_view.dart'; // Nuevo import
import 'package:xpressapp/Views/progress_stats_view.dart'; // Nuevo import

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final pallete = Pallete();
  final scrollController = ScrollController();
  final controller = Get.find<ControllerTeach>();

  @override
  void initState() {
    super.initState();
    // Cargar estadísticas al iniciar
    controller.loadProgressStats();
  }

  double get _progressValue {
    if (controller.imagenes.isEmpty) return 0.0;
    return controller.imagenes.length / 10.0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Evitar el retroceso
        return false;
      },
      child: Obx(
        () => Scaffold(
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
              // BOTÓN DE ESTADÍSTICAS - NUEVO
              IconButton(
                icon: const Icon(
                  Icons.bar_chart,
                  color: Color(0xDDD96C94),
                  size: 28,
                ),
                onPressed: () => Get.to(() => ProgressStatsView()),
              ),

              //se agrego un boton para la configuracion de voz
              IconButton(
                icon: const Icon(
                  Icons.settings_voice,
                  color: Color(0xDDD96C94),
                  size: 28,
                ),
                onPressed: () => Get.to(() => VoiceSettingsView()),
              ),

              // Aqui termina el cambio
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
                        List<String> partesCadena = [];
                        String cadena = '';
                        for (ImageModel imagen in controller.imagenes) {
                          partesCadena.add(imagen.nameOfImage!.toLowerCase());
                        }
                        cadena = partesCadena.join(' ');
                        cadena = ImageModel.capitalize(cadena);
                        String data = await controller.enviarSolicitud(cadena);

                        if (data != 'Error') {
                          // REGISTRAR SESIÓN EXITOSA - NUEVO
                          controller.recordSuccessfulSession(
                            controller.imagenes,
                          );
                          controller.imagenes.clear();
                        } else {
                          // REGISTRAR SESIÓN FALLIDA - NUEVO
                          controller.recordFailedSession();
                        }
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
                    Expanded(
                      flex:
                          2, // Puedes ajustar el flex para el espacio que ocupa
                      child: SelectedImageListComponent(),
                    ),

                  // Espacio entre la lista de imágenes y el mosaico
                  if (controller.imagenes.isNotEmpty)
                    const SizedBox(height: 20),

                  // Mosaico de tarjetas
                  Expanded(
                    flex: 3, // Puedes ajustar el flex para el espacio que ocupa
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
}
