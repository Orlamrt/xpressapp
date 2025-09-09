import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpresatecch/Components/grid_view_images_component.dart';
import 'package:xpresatecch/Components/white_box_text_component.dart';
import 'package:xpresatecch/Controllers/controller.dart';
import 'package:xpresatecch/Models/image_model.dart';

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
  late List<ImageModel> portadaImagenes =
      ImageModel.getEspecificListModel(widget.imagenes, 'portada', widget.color);
  late final imagenes = ImageModel.getListModel(widget.imagenes, widget.color);

  @override
  void initState() {
    super.initState();
    obtenerImagenes();
    cambiarNombrePortadas();
  }

  obtenerImagenes() {
    if (portadaImagenes.isEmpty) return;
    modeloImagenes = agregarLista(portadaImagenes[0]);
    modeloImagenes.removeWhere((e) => e.nameOfImage == 'portada');
  }

  cambiarNombrePortadas() {
    if (portadaImagenes.isEmpty) return;
    for (ImageModel portada in portadaImagenes) {
      portada.nameOfImage = ImageModel.getFolderName(portada.imagePath);
    }
  }

  List<ImageModel> agregarLista(ImageModel portada) {
    List<ImageModel> imagenesModel = [];
    final parts = portada.imagePath.split('/')..removeLast();
    final ruta = parts.join('/') + '/';
    imagenesModel =
        ImageModel.getEspecificListModel(widget.imagenes, ruta, widget.color);
    imagenesModel.removeWhere((e) => e.imagePath == portada.imagePath);
    return imagenesModel;
  }

  Future<void> onTap(int index) async {
    final controller = Get.find<ControllerTeach>();
    final portada = portadaImagenes[index];
    await controller.tellPhrase(portada.nameOfImage!);
    final model = agregarLista(portada);
    setState(() {
      modeloImagenes = model;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Dimensiones explícitas para el contenido del diálogo
    final maxW = media.size.width > 600 ? 1200.0 : media.size.width * 0.95;
    final maxH = media.size.height * 0.8; // aprox 80% de alto de pantalla

    return AlertDialog(
      // Opcional: quita padding extra para aprovechar ancho
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      title: WhiteBoxTextComponent(
        text: widget.title,
        style: Theme.of(context).textTheme.displayMedium,
      ),
      // ⚠️ Sin FittedBox. Damos tamaño fijo al contenido:
      content: SizedBox(
        width: maxW,
        height: maxH,
        child: portadaImagenes.isNotEmpty
            ? Row(
                children: [
                  // Columna izquierda (portadas)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GridViewImagesComponent(
                        imagenes: portadaImagenes,
                        onTap: onTap, // mantiene tu selección
                      ),
                    ),
                  ),
                  // Separador vertical
                  Container(
                    width: 3,
                    height: double.infinity,
                    color: widget.color,
                  ),
                  // Columna derecha (contenido de la portada seleccionada)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GridViewImagesComponent(
                        imagenes: modeloImagenes,
                      ),
                    ),
                  ),
                ],
              )
            : GridViewImagesComponent(imagenes: imagenes),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_forward_rounded, color: widget.color),
        ),
      ],
    );
  }
}
