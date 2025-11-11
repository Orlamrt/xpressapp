import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/statistics/controllers/statistics_controller.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/category_pie_chart_widget.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/overview_cards.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/recent_phrases_list.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/time_range_selector.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/timeline_chart_widget.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/top_words_chart_widget.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();

    Widget buildContent({
      required List<Widget> children,
      bool enableRefresh = false,
    }) {
      final scrollView = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildPageTitle(context)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => controller.refresh(),
                    tooltip: 'Actualizar',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      );

      if (enableRefresh) {
        final refreshable = RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: scrollView,
        );

        return SafeArea(
          bottom: false,
          child: refreshable,
        );
      }

      return SafeArea(
        bottom: false,
        child: scrollView,
      );
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return buildContent(
          children: const [
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando estadísticas...'),
                ],
              ),
            ),
          ],
        );
      }

      if (controller.errorMessage.isNotEmpty) {
        return buildContent(
          children: [
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.errorMessage.value}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      if (controller.allPhrases.isEmpty) {
        return buildContent(
          enableRefresh: true,
          children: [
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Icon(Icons.analytics_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no hay frases guardadas',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Genera y guarda frases para ver tus estadísticas',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return buildContent(
        enableRefresh: true,
        children: [
          TimeRangeSelector(
            selectedRange: controller.selectedTimeRange.value,
            onChanged: (range) => controller.changeTimeRange(range),
          ),
          const SizedBox(height: 16),
          OverviewCards(statistics: controller.statistics.value),
          const SizedBox(height: 24),
          _buildSectionTitle('Actividad'),
          const SizedBox(height: 12),
          TimelineChartWidget(statistics: controller.statistics.value),
          const SizedBox(height: 24),
          _buildSectionTitle('Palabras Más Usadas'),
          const SizedBox(height: 12),
          TopWordsChartWidget(statistics: controller.statistics.value),
          const SizedBox(height: 24),
          _buildSectionTitle('Uso por Categoría'),
          const SizedBox(height: 12),
          CategoryPieChartWidget(statistics: controller.statistics.value),
          const SizedBox(height: 24),
          _buildSectionTitle('Frases Recientes'),
          const SizedBox(height: 12),
          RecentPhrasesList(phrases: controller.filteredPhrases),
        ],
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPageTitle(BuildContext context) {
    return Text(
      'Estadísticas',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
