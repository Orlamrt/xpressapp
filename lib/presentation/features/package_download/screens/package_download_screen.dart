import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../settings/widgets/download_status_card.dart';
import '../controllers/audio_package_controller.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';

class PackageDownloadScreen extends StatefulWidget {
  const PackageDownloadScreen({super.key});

  @override
  State<PackageDownloadScreen> createState() => _PackageDownloadScreenState();
}

class _PackageDownloadScreenState extends State<PackageDownloadScreen> {
  late final AudioPackageController _controller;
  late final bool _navigateOnSuccess;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AudioPackageController>();
    final arguments = Get.arguments;
    final bool fromSettings =
        arguments is Map && (arguments['fromSettings'] as bool? ?? false);
    _navigateOnSuccess = !fromSettings;
    _controller.refreshStatus();
  }

  Future<void> _handleDownload() async {
    await _controller.downloadPackage(navigateOnSuccess: _navigateOnSuccess);
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
                final bool isChecking = _controller.isChecking.value;
                final bool isDownloading = _controller.isDownloading.value;
                final bool downloaded = _controller.hasDownloaded.value;
                final bool failed = _controller.downloadFailed.value;
                final int total = _controller.totalFiles.value;
                final int completed = _controller.currentFile.value;
                final double? progress = total == 0
                    ? null
                    : (_controller.downloadProgress.value.isNaN
                        ? null
                        : _controller.downloadProgress.value);

                final List<Widget> additionalChildren = [];

                if (!downloaded && _controller.availableAssistants.length > 1) {
                  additionalChildren.add(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona un asistente:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _controller.availableAssistants.map((assistant) {
                            final isSelected =
                                _controller.selectedAssistant.value == assistant;
                            return ChoiceChip(
                              label: Text(assistant),
                              selected: isSelected,
                              onSelected: (!isDownloading && !downloaded)
                                  ? (selected) {
                                      if (selected) {
                                        _controller.selectedAssistant.value =
                                            assistant;
                                      }
                                    }
                                  : null,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }

                if (isDownloading) {
                  additionalChildren.addAll([
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 12),
                    Text(
                      total == 0
                          ? 'Preparando descarga...'
                          : '$completed de $total archivos de audio',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ]);

                  final String currentWord = _controller.currentWord.value;
                  if (currentWord.isNotEmpty) {
                    additionalChildren.add(
                      Text(
                        currentWord,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                } else if (failed && _controller.errorMessage.isNotEmpty) {
                  additionalChildren.add(
                    Text(
                      _controller.errorMessage.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  );
                }

                final IconData bannerIcon;
                final Color bannerIconColor;
                final Color bannerBackgroundColor;
                final String bannerMessage;

                if (downloaded) {
                  bannerIcon = Icons.check_circle;
                  bannerIconColor = colorScheme.primary;
                  bannerBackgroundColor = colorScheme.primary.withOpacity(0.1);
                  bannerMessage =
                      'Los paquetes de audio ya están descargados en este dispositivo.';
                } else if (failed) {
                  bannerIcon = Icons.error_outline;
                  bannerIconColor = colorScheme.error;
                  bannerBackgroundColor = colorScheme.error.withOpacity(0.1);
                  bannerMessage =
                      'Ocurrió un error al descargar los paquetes de audio. Intenta nuevamente.';
                } else if (isChecking) {
                  bannerIcon = Icons.info_outline;
                  bannerIconColor = colorScheme.primary;
                  bannerBackgroundColor = colorScheme.primary.withOpacity(0.08);
                  bannerMessage = 'Verificando paquetes disponibles...';
                  additionalChildren.insert(
                    0,
                    const Center(child: CircularProgressIndicator()),
                  );
                } else {
                  bannerIcon = Icons.cloud_download_outlined;
                  bannerIconColor = colorScheme.primary;
                  bannerBackgroundColor = colorScheme.primary.withOpacity(0.08);
                  bannerMessage = 'Aún no has descargado los paquetes de audio.';
                }

                final String buttonLabel;
                if (downloaded) {
                  buttonLabel = 'Audios ya descargados';
                } else if (isDownloading) {
                  buttonLabel = 'Descargando paquetes de audio...';
                } else if (isChecking) {
                  buttonLabel = 'Verificando estado...';
                } else {
                  buttonLabel = 'Descargar paquetes de audio';
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Descargar paquetes de audio',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para mejorar tu experiencia, puedes descargar los paquetes de audio desde el servidor a tu almacenamiento local. Solo es necesario hacerlo una vez.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DownloadStatusCard(
                      bannerIcon: bannerIcon,
                      bannerIconColor: bannerIconColor,
                      bannerBackgroundColor: bannerBackgroundColor,
                      bannerMessage: bannerMessage,
                      buttonLabel: buttonLabel,
                      buttonIcon: downloaded ? Icons.check : Icons.download,
                      buttonEnabled:
                          !isDownloading && !downloaded && !isChecking,
                      onPressed: (!isDownloading && !downloaded && !isChecking)
                          ? _handleDownload
                          : null,
                      additionalChildren: additionalChildren,
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
