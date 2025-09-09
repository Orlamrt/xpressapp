import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUploadView extends StatefulWidget {
  @override
  _ImageUploadViewState createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<ImageUploadView> {
  final ImagePicker _picker = ImagePicker();
  List<Directory> _subfolders = [];
  List<File> _localImages = [];
  String? _selectedFolder;
  String? _selectedImage;
  int _imageVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadSubfolders();
  }

  Future<void> _loadSubfolders() async {
    final localDirectory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory('${localDirectory.path}/imagenes');

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    final subfolders =
        imagesDirectory.listSync().whereType<Directory>().toList();

    setState(() {
      _subfolders = subfolders;
      if (_subfolders.isNotEmpty) {
        _selectedFolder ??= _subfolders.first.path;
        _loadImagesFromFolder(_selectedFolder!);
      }
    });
  }

  Future<void> _loadImagesFromFolder(String folderPath) async {
    final folder = Directory(folderPath);
    final images = folder.listSync().whereType<File>().toList();

    setState(() {
      _localImages = images.cast<File>();
      _selectedFolder = folderPath;
      _selectedImage = null;
    });
  }

  Future<void> _addNewImage() async {
    if (_selectedFolder == null) return;

    try {
      final XFile? newImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (newImage == null || !mounted) return;

      final newPath = path.join(
        _selectedFolder!,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await File(newImage.path).copy(newPath);
      _loadImagesFromFolder(_selectedFolder!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Imagen agregada exitosamente!'),
          backgroundColor: const Color(0xDDD96C94),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  Future<void> _replaceSelectedImage() async {
    if (_selectedImage == null) return;

    try {
      final XFile? newImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (newImage == null || !mounted) return;

      final File oldImage = File(_selectedImage!);
      if (await oldImage.exists()) await oldImage.delete();

      await File(newImage.path).copy(_selectedImage!);

      // Limpiar caché de la imagen
      final fileImage = FileImage(File(_selectedImage!));
      imageCache.evict(fileImage);

      setState(() {
        _imageVersion++;
        _localImages = Directory(_selectedFolder!)
            .listSync()
            .whereType<File>()
            .cast<File>()
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Imagen agregada exitosamente!'),
          backgroundColor: const Color(0xDDD96C94),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestor de Imágenes',
          style: TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF2DCD8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xDDD96C94)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: _selectedFolder,
                  hint: const Text('Selecciona una subcarpeta',
                      style: TextStyle(color: Color(0xDDD96C94))),
                  isExpanded: true,
                  dropdownColor: const Color(0xFFF2DCD8),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color(0xDDD96C94)),
                  items: _subfolders.map((folder) {
                    return DropdownMenuItem<String>(
                      value: folder.path,
                      child: Row(
                        children: [
                          const Icon(Icons.folder, color: Color(0xDDD96C94)),
                          const SizedBox(width: 10),
                          Text(path.basename(folder.path),
                              style: const TextStyle(color: Color(0xDDD96C94))),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      value != null ? _loadImagesFromFolder(value) : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _localImages.isEmpty
                  ? Center(
                      child: Text('No hay imágenes en esta carpeta',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xDDD96C94).withOpacity(0.6))),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _localImages.length,
                      itemBuilder: (context, index) {
                        final file = _localImages[index];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedImage = file.path),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedImage == file.path
                                    ? const Color(0xDDD96C94)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    key: ValueKey(
                                        '${file.path}_${file.lastModifiedSync()}'),
                                    cacheWidth:
                                        (MediaQuery.of(context).size.width ~/ 3)
                                            .toInt(),
                                  ),
                                ),
                                if (_selectedImage == file.path)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                if (_selectedImage == file.path)
                                  const Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Icon(Icons.check_circle,
                                        color: Color(0xDDD96C94), size: 24),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.add_a_photo,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: const Text('Agregar nueva imagen'),
                    onPressed: _addNewImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xDDD96C94),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 8,
                    ),
                  ),
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.swap_horizontal_circle,
                        size: 24,
                        color: Colors.white,
                      ),
                      label: const Text('Reemplazar imagen'),
                      onPressed: _replaceSelectedImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xDDD96C94),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
