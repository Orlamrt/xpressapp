// models/progress_model.dart
class ProgressStats {
  final int totalSessions;
  final int totalImagesUsed;
  final int successfulCommunications;
  final Map<String, int> categoryUsage;
  final Map<String, int> mostUsedImages;
  final DateTime lastSession;
  final List<SessionRecord> sessionHistory;

  ProgressStats({
    required this.totalSessions,
    required this.totalImagesUsed,
    required this.successfulCommunications,
    required this.categoryUsage,
    required this.mostUsedImages,
    required this.lastSession,
    required this.sessionHistory,
  });

  double get successRate {
    if (totalSessions == 0) return 0.0;
    return successfulCommunications / totalSessions;
  }

  String get mostUsedCategory {
    if (categoryUsage.isEmpty) return 'Ninguna';
    var sorted = categoryUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  // Obtener top 5 imágenes más usadas
  List<MapEntry<String, int>> get topImages {
    var sorted = mostUsedImages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  // Obtener top 5 categorías más usadas
  List<MapEntry<String, int>> get topCategories {
    var sorted = categoryUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }
}

class SessionRecord {
  final DateTime date;
  final int imagesUsed;
  final bool wasSuccessful;
  final String phraseGenerated;

  SessionRecord({
    required this.date,
    required this.imagesUsed,
    required this.wasSuccessful,
    required this.phraseGenerated,
  });
}
