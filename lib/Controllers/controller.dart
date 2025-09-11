import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:xpresatecch/Models/image_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpresatecch/Views/principal_view_Paciente.dart';
import 'package:xpresatecch/Views/principal_viewTerapeuta.dart';
import 'package:xpresatecch/Views/principal_viewTutor.dart';
import 'package:xpresatecch/Views/star_session.dart';
import 'package:xpresatecch/Constants/mock_user.dart';
import 'package:xpresatecch/Constants/chat.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:xpresatecch/Models/progress_model.dart';

class ControllerTeach extends GetxController {
  var imagenes = <ImageModel>[].obs;
  final flutterTts = FlutterTts();
  var isLoading = false.obs;
  var isAuthenticated = true.obs;
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






// VOICE MODEL






  //Eleven labs api key and voice id's
  final String elevenLabsApiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? 'API_KEY_NOT_FOUND';
  final String geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  final String isamarVoiceId = 'iyvXhCAqzDxKnq3FDjZl';

  final String emmanuelVoiceId = 'qvN99qHpu3uqmqBD6pEt';

  final String lauraVoiceId='zl1Ut8dvwcVSuQSB9XkG';

  final String alexVoiceId='6DsgX00trsI64jl83WWS';
  final AudioPlayer _audioPlayer = AudioPlayer();
  var selectedAssistant = 'emmanuel'.obs;

  // Agregar la variable observable para estadísticas
  var progressStats = ProgressStats(
    totalSessions: 0,
    totalImagesUsed: 0,
    successfulCommunications: 0,
    categoryUsage: {},
    mostUsedImages: {},
    lastSession: DateTime.now(),
    sessionHistory: [],
  ).obs;

  @override
  void onInit() {
    super.onInit();
    _loadAuthStatus();
    loadProgressStats(); // Cargar estadísticas al iniciar
  }



  String _sanitizeTextForFilename(String text) {
    String lowercased = text.toLowerCase();

    // Manual replacement for common Spanish diacritics
    String withoutDiacritics = lowercased
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u');

    // Remove all non-alphanumeric characters using a regular expression
    RegExp invalidChars = RegExp(r'[^a-z0-9]');
    String sanitized = withoutDiacritics.replaceAll(invalidChars, '');

    return sanitized;
  }

  /// Constructs the full local file path for a given text and assistant.
  ///
  /// Path structure: <app_docs>/audio/<assistant_name>/<sanitized_text>.mp3
  Future<String> _getAudioFilePath(String text, String assistantName) async {
    final sanitizedName = _sanitizeTextForFilename(text);
    final directory = await getApplicationDocumentsDirectory();
    // Use path.join for a platform-safe way to build the path
    return path.join(directory.path, 'audio', assistantName, '$sanitizedName.mp3');
  }



 Future<String?> tellPhrase11labs(String text) async {
    // --- LÍNEA DE DEPURACIÓN AÑADIDA ---
    // Esto te dirá exactamente qué asistente está seleccionado CUANDO la función se ejecuta.
    print("--- Iniciando tellPhrase11labs ---");
    print("Asistente seleccionado: ${selectedAssistant.value}");

    // 1. Determinar la ruta completa donde el archivo de audio debe estar cacheado.
    final String filePath = await _getAudioFilePath(text, selectedAssistant.value);
    final File audioFile = File(filePath);
    
    // --- LÍNEA DE DEPURACIÓN AÑADIDA ---
    print("Buscando archivo en la ruta: $filePath");


    // 2. Comprobar si el archivo ya existe en la caché.
    if (await audioFile.exists()) {
      print('Cache hit para "$text". Reproduciendo desde almacenamiento local.');
      // Reproducir directamente desde el archivo local
      await _audioPlayer.play(DeviceFileSource(filePath));
      return filePath;
    }

    // 3. El archivo no está en caché: Llamar a la API para generar el audio.
    print('Cache miss para "$text". Llamando a la API de ElevenLabs...');
    String voiceId;
    switch (selectedAssistant.value) {
      case 'isamar':
        voiceId = isamarVoiceId;
        break;
      case 'laura':
        voiceId = lauraVoiceId;
        break;
      case 'alex':
        voiceId = alexVoiceId;
        break;
      case 'emmanuel':
        voiceId = emmanuelVoiceId;
        break;
      default: // Maneja cualquier otro valor inesperado
        print('Advertencia: Asistente desconocido seleccionado. Usando a Emmanuel por defecto.');
        voiceId = emmanuelVoiceId;
        break;
    }
    final String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceId?output_format=mp3_44100_96';

    final Map<String, String> headers = {
      'Accept': 'audio/mpeg',
      'Content-Type': 'application/json',
      'xi-api-key': elevenLabsApiKey,
    };
    final Map<String, dynamic> body = {
      'text': text, // Usar el texto ORIGINAL para la llamada a la API
      'model_id': 'eleven_multilingual_v2',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // 4. Guardar el nuevo archivo de audio en la caché.
        // Asegurarse de que el directorio exista antes de escribir el archivo.
        await audioFile.parent.create(recursive: true);
        await audioFile.writeAsBytes(response.bodyBytes);

        // 5. Reproducir el audio recién descargado.
        await _audioPlayer.play(DeviceFileSource(filePath));
        print('Audio guardado y reproducido desde: $filePath');
        return filePath;
      } else {
        print('Error al obtener audio de la API: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Ocurrió una excepción durante la llamada a la API: $e');
      return null;
    }
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

  // Método para enviar la secuencia de pictogramas a la API Flask
  // Future<String> enviarSolicitud(String sentence) async {
  //   // URL de tu nueva API Flask
  //   String apiUrl = 'http://72.60.25.229:5000/generate_sentence';

  //   Map<String, String> headers = {'Content-Type': 'application/json'};

  //   // El backend espera 'sequence' con la oración sin procesar
  //   String requestBody = jsonEncode({'sequence': sentence});

  //   try {
  //     isLoading.value = true;

  //     var response = await http
  //         .post(Uri.parse(apiUrl), headers: headers, body: requestBody)
  //         .timeout(const Duration(seconds: 120));

  //     isLoading.value = false;

  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> data = jsonDecode(response.body);

  //       // Mostrar la oración generada por LLaMA
  //       mostrarPopup(data['generated_sentence']);
  //       return 'Ok';
  //     } else {
  //       mostrarPopup('El internet es inestable, vuelva a intentar más tarde');
  //       return 'Error';
  //     }
  //   } catch (error) {
  //     isLoading.value = false;
  //     mostrarPopup(
  //         'Hubo un error inesperado, por favor vuelva a intentar más tarde');
  //     return 'Error';
  //   }
  // }


    Future<String> enviarSolicitud(String sentence) async {

   
    const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

    Map<String, String> headers = {
      'x-goog-api-key': geminiApiKey,
      'Content-Type': 'application/json',
    };

    // Define la instrucción del sistema y el contenido de la solicitud
    // El 'system_instruction' es la forma en que Gemini entiende el "comportamiento"
    String requestBody = jsonEncode({
      "system_instruction": {
        "parts": [
          {
            "text": "[ROL Y OBJETIVO]\nActúas como el núcleo de un sistema de Comunicación Aumentativa y Alternativa (CAA) diseñado para un usuario que se comunica a través de pictogramas. Tu objetivo principal es ser la voz del usuario, traduciendo secuencias de palabras clave en una única oración en español que sea gramaticalmente correcta, contextualmente apropiada y humanizada. Debes interpretar la intención detrás de los pictogramas, no solo traducirlos literalmente, todos los sujetos son familiares del usuario (usa mi abuelo, mi hermano, etc) a excepcion de maestro y terapeuta (usa el maestro, el terapeuta).\n\n[REGLAS FUNDAMENTALES]\n1.  **Interpretación del Sujeto y la Intención:** Esta es tu regla más importante.\n    * **Primera Persona (YO):** Si la secuencia empieza con \"yo\" o la intención es claramente personal, formula una necesidad, deseo, sentimiento o acción del usuario. Aquí es apropiado usar un tono más personal y, si el contexto lo sugiere, amable.\n    * **Instrucción Recibida (OTRO + YO):** Si la secuencia empieza con otro sujeto (ej. \"mamá\", \"maestro\") pero también incluye \"yo\", interpreta la frase como una acción, petición o estado que ese sujeto dirige hacia el usuario. Infiere verbos como \"quiere que\", \"me dijo que\", \"necesita que\".\n    * **Observación de Terceros (OTROS):** Si la secuencia describe a otras personas y no incluye a \"yo\", interprétala como una observación objetiva de una situación. El tono debe ser más neutro y descriptivo.\n\n2.  **Inferencia Lógica:** Con secuencias cortas o implícitas, infiere la intención más probable y común. Debes completar la idea para que sea funcional.\n    * Ej: ['yo', 'agua'] no es \"yo agua\", sino \"Quiero un vaso de agua\" o \"Tengo sed\".\n\n3.  **Coherencia y Naturalidad:** Añade todos los elementos gramaticales necesarios (artículos, preposiciones, conjunciones, verbos auxiliares) para construir una oración fluida y que suene humana. Evita las estructuras robóticas o excesivamente literales.\n\n4.  **Tiempo y Conjugación:** Conjuga los verbos de forma gramaticalmente correcta en **tiempo presente**, a menos que una palabra clave indique explícitamente un tiempo diferente (ej. \"ayer\", \"mañana\", \"lunes\", \"después\").\n\n5.  **Conservación del Significado:** Respeta la intensidad y el significado específico de cada palabra clave. \"Furioso\" es más intenso que \"enojado\"; \"necesitar\" es más fuerte que \"querer\".\n\n[FORMATO DE SALIDA]\nDevuelve únicamente la oración final completa, sin comillas, etiquetas ni explicaciones adicionales.\n\n[EJEMPLOS PRÁCTICOS]\n\nInput: [\"yo\", \"sentir\", \"triste\", \"hoy\"]\nOutput: \"Hoy me siento triste.\"\n\nInput: [\"jugar\", \"amigo\", \"casa\", \"mañana\"]\nOutput: \"Mañana quiero jugar con mi amigo en mi casa.\"\n\nInput: [\"mamá\", \"decir\", \"limpiar\", \"cuarto\", \"yo\"]\nOutput: \"Mamá me dijo que limpie mi cuarto.\"\n\nInput: [\"abuela\", \"cocinar\", \"espaguetis\", \"nosotros\"]\nOutput: \"La abuela está cocinando espaguetis para nosotros.\"\n\nInput: [\"yo\", \"frío\"]\nOutput: \"Tengo frío.\"\n\nInput: [\"terapeuta\", \"llegar\", \"ayer\"]\nOutput: \"El terapeuta llegó ayer.\""
          }
        ]
      },
      "contents": [
        {
          "parts": [
            {
              "text": sentence // La variable 'sentence' se inserta aquí
            }
          ]
        }
      ]
    });

    try {
      isLoading.value = true;

      var response = await http
          .post(Uri.parse(apiUrl), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      isLoading.value = false;

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        // Navega en la estructura JSON para obtener la respuesta
        // El camino es: 'candidates' -> primer elemento -> 'content' -> 'parts' -> primer elemento -> 'text'
        String generatedSentence = data['candidates'][0]['content']['parts'][0]['text'];

        mostrarPopup(generatedSentence);
        return 'Ok';
      } else {
        mostrarPopup('El internet es inestable. Código de error: ${response.statusCode}');
        return 'Error';
      }
    } catch (error) {
      isLoading.value = false;
      mostrarPopup('Hubo un error inesperado, por favor vuelva a intentar más tarde. Error: $error');
      return 'Error';
    }
  }


  // Método para mostrar un popup con la frase generada
  // MODIFICADO: Ahora la función principal maneja la lógica de la UI.
  void mostrarPopup(String fraseGenerada) async {
    // 1. Llama a la API para generar y guardar el audio. La función ahora devuelve la ruta del archivo.
    final String? audioPath = await tellPhrase11labs(fraseGenerada);

    // 2. Verifica si se obtuvo una ruta de archivo válida.
    if (audioPath == null) {
      // Manejar el error, por ejemplo, mostrando un SnackBar.
      Get.snackbar('Error', 'No se pudo generar el audio.');
      return;
    }

    // 3. Muestra el popup con los botones de acción.
    Get.defaultDialog(
      title: 'Frase generada',
      content: Text(fraseGenerada),
      // barrierDismissible: false, // Opcional: para evitar que se cierre al tocar fuera
      actions: <Widget>[
        // NUEVO: Botón para repetir el audio.
        TextButton(
          onPressed: () async {
            // Usa la ruta guardada para reproducir el audio de nuevo, sin llamar a la API.
            await _audioPlayer.play(DeviceFileSource(audioPath));
          },
          child: const Icon(Icons.replay_rounded), // Icono de repetir
        ),
        ElevatedButton(
          onPressed: () async {
            // Detiene el audio antes de cerrar el popup.
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
        Uri.parse('http://72.60.25.229:8080/register'),
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
        Uri.parse('http://72.60.25.229:8080/login'),
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
        // Persistir estado de autenticación también en SharedPreferences
        await _saveAuthStatus(true);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', (data['nombre'] ?? '').toString());
        await prefs.setString('userEmail', email);
        await prefs.setString('userRole', (data['rol'] ?? '').toString());

        // Solo guardar el UUID si el rol es 'Paciente'.
        // Intentamos con varias posibles claves que podría devolver el backend.
        if ((data['rol'] ?? '') == 'Paciente') {
          final dynamic possibleUuid = data['uuid'] ??
              data['patient_uuid'] ??
              data['patientUuid'] ??
              data['uuidPaciente'] ??
              data['uuid_paciente'];

          if (possibleUuid != null && possibleUuid.toString().isNotEmpty) {
            await prefs.setString('patient_uuid', possibleUuid.toString());
            // Log para diagnóstico en caso de dudas
            // ignore: avoid_print
            print('patient_uuid guardado: ' + possibleUuid.toString());
          } else {
            // ignore: avoid_print
            print(
                'Advertencia: No se recibió UUID en la respuesta para Paciente.');
          }
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

  // Registro de usuario en JSON con manejo de errores
  Future<bool> registerUserV2(
    String nombre,
    String email,
    String password,
    String rol, {
    String? license,
    required String fechaNacimiento,
  }) async {
    final Map<String, dynamic> body = {
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
      'fecha_nacimiento': fechaNacimiento,
    };

    if (rol == 'Terapeuta' && license != null && license.isNotEmpty) {
      body['cedula'] = license;
    }

    try {
      final response = await http.post(
        Uri.parse('http://72.60.25.229:8080/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return true;
        } else {
          Get.snackbar(
            'Error',
            responseData['message']?.toString() ?? 'Error en el registro',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else {
        Get.snackbar(
          'Error',
          'Fallo en la solicitud (' + response.statusCode.toString() + ')',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'Error al registrar usuario: ' + error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
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
      Uri.parse('http://72.60.25.229:8080/get-patient-qr'),
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

  // Método para registrar una nueva sesión
  void recordSession(
      List<ImageModel> imagesUsed, bool wasSuccessful, String phraseGenerated) {
    final now = DateTime.now();

    progressStats.update((stats) {
      if (stats == null) return;

      final updatedSessions = stats.totalSessions + 1;
      final updatedImages = stats.totalImagesUsed + imagesUsed.length;
      final updatedSuccess = wasSuccessful
          ? stats.successfulCommunications + 1
          : stats.successfulCommunications;

      // Crear nuevo registro de sesión
      final newHistory = [
        SessionRecord(
          date: now,
          imagesUsed: imagesUsed.length,
          wasSuccessful: wasSuccessful,
          phraseGenerated: phraseGenerated,
        ),
        ...stats.sessionHistory
      ];

      // Limitar historial a 100 sesiones
      if (newHistory.length > 100) {
        newHistory.removeRange(100, newHistory.length);
      }

      // Actualizar uso de categorías e imágenes
      final updatedCategoryUsage = Map<String, int>.from(stats.categoryUsage);
      final updatedMostUsedImages = Map<String, int>.from(stats.mostUsedImages);

      for (var image in imagesUsed) {
        final category = image.imagePath.split('/').reversed.skip(1).first;
        updatedCategoryUsage[category] =
            (updatedCategoryUsage[category] ?? 0) + 1;

        final imageName = image.nameOfImage ?? 'Sin nombre';
        updatedMostUsedImages[imageName] =
            (updatedMostUsedImages[imageName] ?? 0) + 1;
      }

      // Actualizar estadísticas
      progressStats.value = ProgressStats(
        totalSessions: updatedSessions,
        totalImagesUsed: updatedImages,
        successfulCommunications: updatedSuccess,
        categoryUsage: updatedCategoryUsage,
        mostUsedImages: updatedMostUsedImages,
        lastSession: now,
        sessionHistory: newHistory,
      );
    });

    _saveProgressStats();
  }

  // Método para guardar estadísticas
  Future<void> _saveProgressStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = progressStats.value;

      final Map<String, dynamic> sessionHistoryJson = {
        'sessions': stats.sessionHistory
            .map((e) => {
                  'date': e.date.toIso8601String(),
                  'imagesUsed': e.imagesUsed,
                  'wasSuccessful': e.wasSuccessful,
                  'phraseGenerated': e.phraseGenerated,
                })
            .toList(),
      };

      await prefs.setInt('totalSessions', stats.totalSessions);
      await prefs.setInt('totalImagesUsed', stats.totalImagesUsed);
      await prefs.setInt(
          'successfulCommunications', stats.successfulCommunications);
      await prefs.setString('lastSession', stats.lastSession.toIso8601String());
      await prefs.setString('categoryUsage', jsonEncode(stats.categoryUsage));
      await prefs.setString('mostUsedImages', jsonEncode(stats.mostUsedImages));
      await prefs.setString('sessionHistory', jsonEncode(sessionHistoryJson));
    } catch (e) {
      print('Error al guardar estadísticas: $e');
    }
  }

  // Método para cargar estadísticas
  Future<void> loadProgressStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final totalSessions = prefs.getInt('totalSessions') ?? 0;
      final totalImagesUsed = prefs.getInt('totalImagesUsed') ?? 0;
      final successfulCommunications =
          prefs.getInt('successfulCommunications') ?? 0;
      final lastSession = DateTime.tryParse(
          prefs.getString('lastSession') ?? DateTime.now().toIso8601String());

      final Map<String, int> categoryUsage = Map<String, int>.from(
          jsonDecode(prefs.getString('categoryUsage') ?? '{}'));

      final Map<String, int> mostUsedImages = Map<String, int>.from(
          jsonDecode(prefs.getString('mostUsedImages') ?? '{}'));

      final sessionHistoryJson =
          jsonDecode(prefs.getString('sessionHistory') ?? '{"sessions":[]}');
      final List<SessionRecord> sessionHistory =
          (sessionHistoryJson['sessions'] as List)
              .map<SessionRecord>((e) => SessionRecord(
                    date: DateTime.parse(e['date']),
                    imagesUsed: e['imagesUsed'],
                    wasSuccessful: e['wasSuccessful'],
                    phraseGenerated: e['phraseGenerated'],
                  ))
              .toList();

      progressStats.value = ProgressStats(
        totalSessions: totalSessions,
        totalImagesUsed: totalImagesUsed,
        successfulCommunications: successfulCommunications,
        categoryUsage: categoryUsage,
        mostUsedImages: mostUsedImages,
        lastSession: lastSession ?? DateTime.now(),
        sessionHistory: sessionHistory,
      );
    } catch (e) {
      print('Error al cargar estadísticas: $e');
      // En caso de error, inicializar con valores por defecto
      progressStats.value = ProgressStats(
        totalSessions: 0,
        totalImagesUsed: 0,
        successfulCommunications: 0,
        categoryUsage: {},
        mostUsedImages: {},
        lastSession: DateTime.now(),
        sessionHistory: [],
      );
    }
  }

  // Agregar este método público
  Future<void> saveProgressStats() async {
    await _saveProgressStats();
  }
}
