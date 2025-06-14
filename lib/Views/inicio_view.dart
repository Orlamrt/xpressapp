import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Components/mosaico_component.dart';
import 'package:xpressapp/Components/selected_image_list_component.dart';
import 'package:xpressapp/Constants/colors.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Models/image_model.dart';

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
                    Expanded(
                      flex: 2, // Puedes ajustar el flex para el espacio que ocupa
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
