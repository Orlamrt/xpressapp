import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/link_tutor_controller.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';

class LinkTutorScreen extends GetView<LinkTutorController> {
  const LinkTutorScreen({super.key});

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
              Colors.white10,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Enlazar tutor',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comparte este código con tu tutor para enlazar su cuenta contigo.',
                    textAlign: TextAlign.start,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return _buildLoadingCard(colorScheme);
                    }

                    final error = controller.errorMessage.value;
                    if (error.isNotEmpty) {
                      return _ErrorState(
                        message: error,
                        onRetry: controller.refreshQr,
                        colorScheme: colorScheme,
                      );
                    }

                    final qrData = controller.qrBytes.value;
                    if (qrData == null) {
                      return _ErrorState(
                        message: 'No se pudo cargar tu código QR.',
                        onRetry: controller.refreshQr,
                        colorScheme: colorScheme,
                      );
                    }

                    return _QrContent(
                      qrBytes: qrData,
                      onRefresh: controller.refreshQr,
                      colorScheme: colorScheme,
                      theme: theme,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: _cardDecoration(colorScheme),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: colorScheme.primary.withOpacity(0.35),
        width: 1.4,
      ),
    );
  }
}

class _QrContent extends StatelessWidget {
  const _QrContent({
    required this.qrBytes,
    required this.onRefresh,
    required this.colorScheme,
    required this.theme,
  });

  final Uint8List qrBytes;
  final Future<void> Function() onRefresh;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.35),
          width: 1.4,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                qrBytes,
                width: 220,
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pide a tu tutor que escanee este código desde su aplicación para completar el enlace.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRefresh,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: colorScheme.onPrimary,
            ),
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            label: const Text('Actualizar código'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.colorScheme,
  });

  final String message;
  final Future<void> Function() onRetry;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
