import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Components/mosaico_component.dart';
import 'package:xpresatecch/Components/selected_image_list_component.dart';
import 'package:xpresatecch/Constants/Colors.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'package:xpresatecch/Models/image_model.dart';

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
                        List<String> partesCadena = [];
                        String cadena = '';
                        for (ImageModel imagen in controller.imagenes) {
                          partesCadena.add(imagen.nameOfImage!.toLowerCase());
                        }
                        cadena = partesCadena.join(' ');
                        cadena = ImageModel.capitalize(cadena);
                        String data = await controller.enviarSolicitud(cadena);
                        if (data != 'Error') {
                          controller.imagenes.clear();
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
}
