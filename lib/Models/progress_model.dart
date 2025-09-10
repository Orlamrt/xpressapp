// Define la clase principal que almacena todas las estadísticas de progreso
class ProgressStats {
  // Campos de solo lectura (final) que almacenan los datos estadísticos
  final int totalSessions; // Número total de sesiones realizadas
  final int totalImagesUsed; // Cantidad total de imágenes utilizadas
  final int successfulCommunications; // Número de comunicaciones exitosas
  final Map<String, int>
      categoryUsage; // Mapeo de categorías y su frecuencia de uso
  final Map<String, int>
      mostUsedImages; // Mapeo de imágenes y su frecuencia de uso
  final DateTime lastSession; // Fecha y hora de la última sesión
  final List<SessionRecord>
      sessionHistory; // Historial detallado de todas las sesiones

  // Constructor que requiere todos los campos para garantizar integridad de datos
  ProgressStats({
    required this.totalSessions,
    required this.totalImagesUsed,
    required this.successfulCommunications,
    required this.categoryUsage,
    required this.mostUsedImages,
    required this.lastSession,
    required this.sessionHistory,
  });

  // GETTER: Calcula la tasa de éxito como porcentaje de sesiones exitosas
  double get successRate {
    if (totalSessions == 0) return 0.0; // Evita división por cero
    return successfulCommunications / totalSessions; // Fórmula: éxitos/total
  }

  // GETTER: Encuentra la categoría más utilizada
  String get mostUsedCategory {
    if (categoryUsage.isEmpty) return 'Ninguna'; // Caso para mapa vacío

    // Convierte las entradas del mapa a lista y las ordena descendentemente
    var sorted = categoryUsage.entries.toList()
      ..sort(
          (a, b) => b.value.compareTo(a.value)); // Ordena por valor (cantidad)

    return sorted.first.key; // Retorna la clave (nombre) de la primera entrada
  }

  // GETTER: Obtiene las 5 imágenes más utilizadas
  List<MapEntry<String, int>> get topImages {
    // Convierte a lista y ordena descendentemente por frecuencia
    var sorted = mostUsedImages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).toList(); // Toma solo los primeros 5 elementos
  }

  // GETTER: Obtiene las 5 categorías más utilizadas
  List<MapEntry<String, int>> get topCategories {
    // Convierte a lista y ordena descendentemente por frecuencia
    var sorted = categoryUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).toList(); // Toma solo los primeros 5 elementos
  }
}

// Clase que representa un registro individual de una sesión
class SessionRecord {
  final DateTime date; // Cuándo ocurrió la sesión
  final int imagesUsed; // Cuántas imágenes se usaron
  final bool wasSuccessful; // Si la comunicación fue exitosa
  final String phraseGenerated; // La frase que se generó

  // Constructor que requiere todos los campos para integridad de datos
  SessionRecord({
    required this.date,
    required this.imagesUsed,
    required this.wasSuccessful,
    required this.phraseGenerated,
  });
}
