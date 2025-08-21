import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Components/grid_view_images_component.dart';
import 'package:xpressapp/Components/white_box_text_component.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Models/image_model.dart';

class AlertImagesComponent extends StatefulWidget {
  final Color color;
  final String title;
  final List<String> imagenes;

  const AlertImagesComponent({
    super.key,
    required this.imagenes,
    required this.color,
    required this.title,
  });

  @override
  State<AlertImagesComponent> createState() => _AlertImagesComponentState();
}

class _AlertImagesComponentState extends State<AlertImagesComponent> {
  List<ImageModel> modeloImagenes = [];
  late List<ImageModel> portadaImagenes = ImageModel.getEspecificListModel(
    widget.imagenes,
    'portada',
    widget.color,
  );
  late final imagenes = ImageModel.getListModel(widget.imagenes, widget.color);

  @override
  void initState() {
    super.initState();
    obtenerImagenes();
    cambiarNombrePortadas();
  }

  obtenerImagenes() {
    if (portadaImagenes.isEmpty) return;
    print(portadaImagenes.first.imagePath);
    modeloImagenes = agregarLista(portadaImagenes[0]);
    modeloImagenes.removeWhere((element) => element.nameOfImage == 'portada');
  }

  cambiarNombrePortadas() {
    if (portadaImagenes.isEmpty) return;
    for (ImageModel portada in portadaImagenes) {
      portada.nameOfImage = ImageModel.getFolderName(portada.imagePath);
    }
  }

  List<ImageModel> agregarLista(ImageModel portada) {
    List<ImageModel> imagenesModel = [];
    List<String> parts = portada.imagePath.split('/');
    parts.removeLast();
    String ruta = '';
    for (int i = 0; i < parts.length; i++) {
      ruta += '${parts[i]}/';
    }
    print(ruta);
    imagenesModel = ImageModel.getEspecificListModel(
      widget.imagenes,
      ruta,
      widget.color,
    );
    imagenesModel.removeWhere(
      (element) => element.imagePath == portada.imagePath,
    );
    for (var i = 0; i < imagenesModel.length; i++) {
      print(imagenesModel[i].imagePath);
    }
    return imagenesModel;
  }

  onTap(int index) async {
    final controller = Get.find<ControllerTeach>();
    final portada = portadaImagenes[index];
    await controller.tellPhrase(portada.nameOfImage!);
    final model = agregarLista(portada);
    for (var element in model) {
      print(element.nameOfImage);
    }
    setState(() {
      modeloImagenes = model;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: WhiteBoxTextComponent(
        text: widget.title,
        style: Theme.of(context).textTheme.displayMedium,
      ),
      content: FittedBox(
        fit: BoxFit.contain,
        child: portadaImagenes.isNotEmpty
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width > 600
                      ? 1200
                      : MediaQuery.of(context).size.width,
                  maxHeight: 700, // Limitar la altura máxima
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      // Permitir que ocupe el espacio disponible
                      child: GridViewImagesComponent(
                        imagenes: portadaImagenes,
                        onTap: onTap, // Aquí se pasa solo el onTap
                      ),
                    ),
                    Container(height: 670, width: 3, color: widget.color),
                    Expanded(
                      // Permitir que ocupe el espacio disponible
                      child: GridViewImagesComponent(imagenes: modeloImagenes),
                    ),
                  ],
                ),
              )
            : GridViewImagesComponent(imagenes: imagenes),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_forward_rounded, color: widget.color),
        ),
      ],
    );
  }
}
