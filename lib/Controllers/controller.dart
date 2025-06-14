import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xpressapp/Models/image_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpressapp/Views/principal_view.dart';
import 'package:xpressapp/Views/principal_viewTerapeuta.dart';
import 'package:xpressapp/Views/principal_viewTutor.dart';
import 'package:xpressapp/Views/star_session.dart';
import 'package:xpressapp/Constants/mock_user.dart';
import 'package:xpressapp/Constants/chat.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ControllerTeach extends GetxController {
  var imagenes = <ImageModel>[].obs;
  final flutterTts = FlutterTts();
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var userNameController = ''.obs;
  var idUserController = ''.obs;
  var birthDateController =
      ''.obs; // Añadido para manejar la fecha de nacimiento
  // Lista observable de mensajes
  var messages = <Message>[].obs;
  // Listas para pacientes, tutores y asignaciones
  var patients = <MockUser>[].obs;
  var tutors = <MockUser>[].obs;
  var assignments = <Map<String, String>>[].obs; // Lista de asignaciones
  var qrImageUrl = ''.obs;
  @override
  void onInit() {
    super.onInit();
    _loadAuthStatus();
  }

  Future<void> _loadAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated.value = prefs.getBool('isAuthenticated') ?? false;
  }

  Future<void> _saveAuthStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAuthenticated', status);
  }

  Future<void> savePatientUUID(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patient_uuid', uuid);
  }

  Future<String?> getPatientUUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patient_uuid');
  }

  // Método para asignar un tutor a un paciente
  void assignTutorToPatient(String tutorEmail, String patientEmail) {
    final tutor = tutors.firstWhere((tutor) => tutor.email == tutorEmail,
        orElse: () => MockUser(name: '', email: '', password: '', role: ''));
    final patient = patients.firstWhere(
        (patient) => patient.email == patientEmail,
        orElse: () => MockUser(name: '', email: '', password: '', role: ''));

    if (tutor.email.isEmpty || patient.email.isEmpty) {
      Get.snackbar('Error', 'Tutor o paciente no encontrado',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Verificar si ya existe una asignación
    final exists = assignments
        .any((assignment) => assignment['patientEmail'] == patientEmail);

    if (exists) {
      Get.snackbar('Error', 'El paciente ya tiene un tutor asignado',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Guardar la asignación
    assignments.add({'tutorEmail': tutorEmail, 'patientEmail': patientEmail});
    _saveAssignmentToPreferences(tutorEmail, patientEmail);
    Get.snackbar('Éxito', 'Tutor asignado correctamente',
        snackPosition: SnackPosition.BOTTOM);
  }

  // Guardar la asignación en SharedPreferences (puede usarse para pruebas locales)
  Future<void> _saveAssignmentToPreferences(
      String tutorEmail, String patientEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('assignedTutor_$patientEmail', tutorEmail);
  }

  // Método para obtener la lista de imágenes de assets
  Future<List<String>> obtenerListaImagenes(String colorCarpeta) async {
    List<String> archivosLocales = [];
    List<String> archivosAssets = [];

    try {
      // 1. Directorio local de la app
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String localDirPath = '${appDocDir.path}/imagenes/$colorCarpeta';
      final Directory localDir = Directory(localDirPath);

      // 2. Verificar si hay archivos locales
      if (await localDir.exists()) {
        final archivos = localDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) =>
                file.path.endsWith('.png') || file.path.endsWith('.jpg'))
            .toList();

        if (archivos.isNotEmpty) {
          archivosLocales = archivos.map((f) => f.path).toList();
          return archivosLocales;
        }
      }

      // 3. Si no hay archivos locales, usar los assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      archivosAssets = manifestMap.keys
          .where((path) => path.contains('assets/imagenes/$colorCarpeta/'))
          .toList();

      return archivosAssets;
    } catch (e) {
      print('Error al obtener lista de imágenes: $e');
      return [];
    }
  }

// Método para copiar las imágenes desde los assets al almacenamiento local
  Future<void> copiarImagenesAssetsAlLocal() async {
    try {
      // Obtener directorio local de la app
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String destinoBase = '${appDocDir.path}/imagenes';

      // Leer el AssetManifest.json
      final String manifestContent =
          await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filtrar solo los paths que están en assets/imagenes/
      final List<String> assetPaths = manifestMap.keys
          .where((path) => path.startsWith('assets/imagenes/'))
          .toList();

      // Recorrer cada imagen y copiarla al destino
      for (String assetPath in assetPaths) {
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List();

        // Obtener ruta relativa para mantener estructura de carpetas
        final String relativePath =
            assetPath.replaceFirst('assets/imagenes/', '');
        final String localPath = '$destinoBase/$relativePath';

        // Verificar si la imagen ya existe en el almacenamiento local
        final File localFile = File(localPath);
        if (await localFile.exists()) {
          continue; // Si la imagen ya existe, no hacer nada
        }

        await localFile.parent
            .create(recursive: true); // Crear carpetas si no existen
        await localFile.writeAsBytes(bytes, flush: true); // Guardar imagen

        print(
            'Imagen copiada a: $localPath'); // Registra que la imagen fue copiada
      }
    } catch (e) {
      print('Error al copiar imágenes: $e');
    }
  }

  // Método para enviar solicitud al servidor
  Future<String> enviarSolicitud(String sentence) async {
    String apiUrl = 'http://69.62.69.122:8080/conjugar';
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String requestBody = jsonEncode({'sentence': sentence});

    try {
      isLoading.value = true;
      var response = await http
          .post(Uri.parse(apiUrl), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));
      isLoading.value = false;

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        mostrarPopup(data['frase']);
        return 'Ok';
      } else {
        mostrarPopup('El internet es inestable, vuelva a intentar más tarde');
        return 'Error';
      }
    } catch (error) {
      isLoading.value = false;
      mostrarPopup(
          'Hubo un error inesperado, por favor vuelva a intentar más tarde');
      return 'Error';
    }
  }

  // Método para mostrar un popup con la frase generada
  void mostrarPopup(String fraseGenerada) async {
    await tellPhrase(fraseGenerada);

    Get.defaultDialog(
      title: 'Frase generada',
      content: Text(fraseGenerada),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            await stopPhrase();
            Get.back();
          },
          child: const Icon(Icons.arrow_forward_rounded),
        )
      ],
    );
  }

  // Método para leer en voz la frase generada
  Future<void> tellPhrase(String text) async {
    await flutterTts.setLanguage('es-ES');
    await flutterTts.setSpeechRate(0.6);
    await flutterTts.speak(text);
  }

  // Método para detener la reproducción de texto
  Future<void> stopPhrase() async {
    await flutterTts.stop();
  }

  // Método para insertar un código
  /*Future<void> insertCode(String code) async {
    final response = await http.post(
      Uri.parse('http://89.116.51.234/xpressateach/xpressateach/insert_code.php'),
      body: {'codigo': code},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        print('Registro exitoso: ${responseData['message']}');
      } else {
        print('Error en el registro: ${responseData['message']}');
      }
    } else {
      throw Exception('Fallo en la solicitud');
    }
  }
  */

  Future<void> registerUser(
    String nombre,
    String email,
    String password,
    String rol, {
    String? license,
    required String fechaNacimiento,
  }) async {
    // Construir el cuerpo de la solicitud
    final body = {
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
      'fecha_nacimiento': fechaNacimiento,
    };

    // Añadir cédula solo si el rol es Terapeuta
    if (rol == 'Terapeuta' && license != null && license.isNotEmpty) {
      body['cedula'] = license;
    }

    try {
      // Realizar la solicitud POST al endpoint de registro en Flask
      final response = await http.post(
        Uri.parse('http://69.62.69.122:8080/register'),
        body: body,
      );

      // Comprobar el estado de la respuesta
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          print('Registro exitoso: ${responseData['message']}');
        } else {
          print('Error en el registro: ${responseData['message']}');
        }
      } else {
        throw Exception('Fallo en la solicitud');
      }
    } catch (error) {
      // Manejo de excepciones
      print('Error al registrar usuario: $error');
    }
  }

  // Método para iniciar sesión y manejar la respuesta del servidor
  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://69.62.69.122:8080/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        isAuthenticated.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['nombre']);
        await prefs.setString('userEmail', email);
        await prefs.setString('userRole', data['rol']);

        // Solo guardar el UUID si el rol es 'Paciente'
        if (data['rol'] == 'Paciente') {
          await prefs.setString('patient_uuid', data['uuid']);
        }

        await navigateByRole();
        return true;
      } else {
        isAuthenticated.value = false;
        Get.snackbar(
          'Error',
          'Email o contraseña incorrectos',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      isAuthenticated.value = false;
      Get.snackbar(
        'Error',
        'Error de conexión, por favor intenta más tarde.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      isAuthenticated.value = false;
      await _saveAuthStatus(false);
      Get.snackbar(
        'Éxito',
        'Has cerrado sesión correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Redirige al usuario a la vista de inicio
      Get.offAll(() => const PrincipalInicio());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Hubo un problema al cerrar sesión',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Método para agregar una tarea (Evita duplicación)
  var tasks = <Map<String, String>>[].obs;

  void addTask(String name, String description) {
    tasks.add({'task_name': name, 'task_description': description});
  }

  // Método para obtener tareas (Evita duplicación)
  Future<void> fetchTasks() async {
    if (tasks.isEmpty) {
      await Future.delayed(const Duration(seconds: 2));
      tasks.addAll([
        {
          'task_name': 'Tarea 1',
          'task_description': 'Descripción de la tarea 1'
        },
        {
          'task_name': 'Tarea 2',
          'task_description': 'Descripción de la tarea 2'
        },
      ]);
    }
  }

  // Método para navegar según el rol del usuario
  Future<void> navigateByRole() async {
    final prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('userRole');

    switch (role) {
      case 'Tutor':
        Get.off(() => const PrincipalViewTutor()); // Navega a la vista de Admin
        break;
      case 'Terapeuta':
        Get.off(() =>
            const PrincipalViewTerapeuta()); // Navega a la vista de Terapeuta
        break;
      case 'Paciente':
        Get.off(() =>
            const PrincipalViewPaciente()); // Navega a la vista de Paciente
        break;
      default:
        Get.snackbar(
          'Error',
          'Rol no reconocido',
          snackPosition: SnackPosition.BOTTOM,
        );
    }
  }

  // Método para obtener el paciente asignado a un tutor específico
  Future<String?> getAssignedPatient(String tutorEmail) async {
    // Encuentra la asignación que corresponde al tutor
    final assignment = assignments.firstWhere(
      (assignment) => assignment['tutorEmail'] == tutorEmail,
      orElse: () => {},
    );

    if (assignment.isEmpty) {
      return null; // No hay paciente asignado
    }

    final patientEmail = assignment['patientEmail'];
    if (patientEmail == null) {
      return null;
    }

    // Busca el paciente en la lista de pacientes
    final patient = patients.firstWhere(
      (patient) => patient.email == patientEmail,
      orElse: () => MockUser(name: '', email: '', password: '', role: ''),
    );

    return patient.name.isNotEmpty
        ? patient.name
        : null; // Retorna el nombre del paciente
  }

  void sendMessage(String text, String sender) {
    if (text.isNotEmpty) {
      messages.add(
        Message(
          text: text,
          sender: sender,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void uploadTherapistInformation(
      String name, String specialization, String bio) {
    // Ejemplo básico:
    print('Nombre: $name');
    print('Especialización: $specialization');
    print('Biografía: $bio');
  }

  Future<Uint8List?> fetchQrCodeImage() async {
    // Asegúrate de que getPatientUUID() esté definido y retorne el UUID correcto
    final patientUuid =
        await getPatientUUID(); // Usa await si es un método asíncrono
    if (patientUuid == null) return null;

    // Asegúrate de cambiar 'your-server-url' a la URL de tu servidor real
    final response = await http.post(
      Uri.parse(
          'http://69.62.69.122:8080/get-patient-qr'), // Cambia esta URL por la de tu servidor
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uuid': patientUuid}),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // Retorna los bytes de la imagen directamente
    } else {
      // Maneja el caso donde no se obtuvo la imagen
      return null;
    }
  }
}
