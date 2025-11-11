import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xpressatec/presentation/features/customization/controllers/customization_controller.dart';
import 'package:xpressatec/presentation/features/settings/widgets/download_status_card.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';

class DownloadPictogramsScreen extends StatefulWidget {
  const DownloadPictogramsScreen({super.key});

  @override
  State<DownloadPictogramsScreen> createState() =>
      _DownloadPictogramsScreenState();
}

class _DownloadPictogramsScreenState extends State<DownloadPictogramsScreen> {
  late final CustomizationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CustomizationController>();
    _controller.refreshDownloadStatus();
  }

  Future<void> _handleDownload() async {
    final status = await _controller.downloadPictogramsIfNeeded(
      showProgressDialog: false,
      showFeedback: false,
    );

    if (!mounted) return;

    switch (status) {
      case PictogramDownloadStatus.alreadyDownloaded:
        Get.snackbar(
          'Pictogramas disponibles',
          'Los pictogramas ya están descargados en este dispositivo.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case PictogramDownloadStatus.success:
        Get.snackbar(
          'Descarga exitosa',
          'Pictogramas descargados correctamente.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case PictogramDownloadStatus.failure:
        Get.snackbar(
          'Error',
          'Ocurrió un error al descargar los pictogramas. Intenta nuevamente.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }

    await _controller.refreshDownloadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Obx(() {
                final bool isDownloading = _controller.isDownloading.value;
                final bool downloaded =
                    _controller.assetsReady.value || _controller.hasDownloadedPictograms;
                final bool failed = _controller.downloadFailed.value;
                final int total = _controller.totalCount.value;
                final int completed = _controller.downloadedCount.value;
                final double? progress = total == 0 ? null : completed / total;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Descargar pictogramas',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para personalizar tu experiencia, puedes descargar los pictogramas desde el servidor a tu almacenamiento local. Solo es necesario hacerlo una vez.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DownloadStatusCard(
                      bannerIcon: downloaded
                          ? Icons.check_circle
                          : failed
                              ? Icons.error_outline
                              : Icons.cloud_download_outlined,
                      bannerIconColor: downloaded
                          ? colorScheme.primary
                          : failed
                              ? colorScheme.error
                              : colorScheme.primary,
                      bannerBackgroundColor: downloaded
                          ? colorScheme.primary.withOpacity(0.1)
                          : failed
                              ? colorScheme.error.withOpacity(0.1)
                              : colorScheme.primary.withOpacity(0.08),
                      bannerMessage: downloaded
                          ? 'Los pictogramas ya están descargados en este dispositivo.'
                          : failed
                              ? 'Ocurrió un error al descargar los pictogramas. Intenta nuevamente.'
                              : 'Descarga los pictogramas para usarlos sin conexión.',
                      buttonLabel: downloaded
                          ? 'Pictogramas ya descargados'
                          : isDownloading
                              ? 'Descargando pictogramas...'
                              : 'Descargar pictogramas',
                      buttonIcon: downloaded ? Icons.check : Icons.download,
                      buttonEnabled: !isDownloading && !downloaded,
                      onPressed: (!isDownloading && !downloaded)
                          ? _handleDownload
                          : null,
                      additionalChildren: [
                        if (isDownloading) ...[
                          LinearProgressIndicator(value: progress),
                          const SizedBox(height: 12),
                          Text(
                            total == 0
                                ? 'Preparando descarga...'
                                : '$completed de $total pictogramas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

}
