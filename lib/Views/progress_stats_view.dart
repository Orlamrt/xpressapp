// views/progress_stats_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';

class ProgressStatsView extends StatelessWidget {
  final ControllerTeach controller = Get.find<ControllerTeach>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Progreso'),
        backgroundColor: const Color(0xFFF2DCD8),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF2DCD8),
      body: Obx(() {
        final stats = controller.progressStats.value;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // RESUMEN GENERAL
              _buildStatCard(
                title: '📊 Resumen General',
                children: [
                  _buildStatItem('Sesiones totales', '${stats.totalSessions}'),
                  _buildStatItem(
                    'Imágenes utilizadas',
                    '${stats.totalImagesUsed}',
                  ),
                  _buildStatItem(
                    'Comunicaciones exitosas',
                    '${stats.successfulCommunications}',
                  ),
                  _buildStatItem(
                    'Tasa de éxito',
                    '${(stats.successRate * 100).toStringAsFixed(1)}%',
                  ),
                  _buildStatItem(
                    'Última sesión',
                    _formatDate(stats.lastSession),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // GRÁFICO DE BARRAS HORIZONTAL (Hecho manualmente)
              if (stats.topCategories.isNotEmpty)
                _buildStatCard(
                  title: '📈 Categorías Más Usadas',
                  child: Column(
                    children: stats.topCategories
                        .map(
                          (category) => _buildBarChartItem(
                            category.key,
                            category.value,
                            stats.categoryUsage.values.reduce(
                              (a, b) => a > b ? a : b,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  children: [],
                ),

              const SizedBox(height: 20),

              // IMÁGENES MÁS UTILIZADAS
              if (stats.topImages.isNotEmpty)
                _buildStatCard(
                  title: '⭐ Imágenes Más Utilizadas',
                  children: [
                    ...stats.topImages.map(
                      (image) =>
                          _buildStatItem(image.key, '${image.value} usos'),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // HISTORIAL DE SESIONES RECIENTES
              _buildStatCard(
                title: '🕐 Historial Reciente',
                child: Column(
                  children: stats.sessionHistory
                      .take(5)
                      .map(
                        (session) => ListTile(
                          leading: Icon(
                            session.wasSuccessful
                                ? Icons.check_circle
                                : Icons.error,
                            color: session.wasSuccessful
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(
                            session.phraseGenerated,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${session.imagesUsed} imágenes - ${_formatDate(session.date)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
                children: [],
              ),

              const SizedBox(height: 20),

              // BOTÓN PARA LIMPIAR ESTADÍSTICAS
              ElevatedButton(
                onPressed: _showResetConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reiniciar Estadísticas'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({
    required String title,
    List<Widget> children = const [],
    Widget? child,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xDDD96C94),
              ),
            ),
            const SizedBox(height: 10),
            if (child != null) child else Column(children: children),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBarChartItem(String label, int value, int maxValue) {
    final percentage = maxValue > 0 ? value / maxValue : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xDDD96C94),
                  ),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  '$value',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showResetConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reiniciar Estadísticas'),
        content: const Text(
          '¿Estás seguro de que quieres borrar todas las estadísticas? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Implementar lógica para reiniciar estadísticas
              Get.back();
              Get.snackbar('Éxito', 'Estadísticas reiniciadas');
            },
            child: const Text('Reiniciar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
