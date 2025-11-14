import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/core/config/routes.dart';
import 'package:xpressatec/data/models/terapeuta_marketplace.dart';

import '../controllers/communication_therapist_controller.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';

class CommunicationTherapistMarketplaceScreen
    extends GetView<CommunicationTherapistController> {
  const CommunicationTherapistMarketplaceScreen({super.key});

  @override
  CommunicationTherapistController get controller =>
      Get.find<CommunicationTherapistController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color backgroundTint = colorScheme.primary.withOpacity(0.06);

    return Scaffold(
      backgroundColor: backgroundTint,
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Terapeutas en comunicación',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explora especialistas en comunicación y lenguaje.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              _SearchField(
                controller: controller.searchCtrl,
                onChanged: controller.onSearchChanged,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final terapeutas = controller.terapeutas;

                  if (terapeutas.isEmpty) {
                    return _EmptyResultsMessage(
                      query: controller.searchQuery.value,
                      colorScheme: colorScheme,
                    );
                  }

                  return ListView.separated(
                    itemCount: terapeutas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final TerapeutaMarketplace terapeuta = terapeutas[index];
                      return _TherapistListTile(
                        terapeuta: terapeuta,
                        colorScheme: colorScheme,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
    required this.controller,
  });

  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, ciudad o especialidad',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _TherapistListTile extends StatelessWidget {
  const _TherapistListTile({
    required this.terapeuta,
    required this.colorScheme,
  });

  final TerapeutaMarketplace terapeuta;
  final ColorScheme colorScheme;

  String _sectorLabel(String code) {
    switch (code) {
      case 'PR':
        return 'Privado';
      case 'PU':
        return 'Público';
      case 'AM':
        return 'Ambos';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String especialidad =
        (terapeuta.especialidad?.trim().isNotEmpty ?? false)
            ? terapeuta.especialidad!.trim()
            : 'Sin especialidad';
    final Map<String, dynamic> contacto = terapeuta.contacto;

    final List<_ContactChipData> contactChips = [];
    void addChip(IconData icon, String label, String? value) {
      if (value == null) return;
      final String trimmed = value.trim();
      if (trimmed.isEmpty) return;
      contactChips.add(_ContactChipData(icon: icon, label: label, value: trimmed));
    }

    addChip(Icons.phone, 'Teléfono', contacto['Telefono'] as String?);
    addChip(Icons.smartphone, 'Celular', contacto['Celular'] as String?);
    addChip(Icons.email_outlined, 'Correo', contacto['Correo'] as String?);
    addChip(Icons.alternate_email, 'Red social', contacto['RedSocial'] as String?);
    addChip(Icons.whatsapp, 'WhatsApp', contacto['WhatsApp'] as String?);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Get.toNamed(
          Routes.therapistDetail,
          arguments: terapeuta,
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          terapeuta.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          especialidad,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _sectorLabel(terapeuta.tipoSector),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          terapeuta.tipoSector,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.badge_outlined, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Cédula: ${terapeuta.cedulaProfesional}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.mail_outline, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      terapeuta.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              if (contactChips.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: contactChips
                      .map(
                        (chip) => _ContactChip(
                          data: chip,
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        onTap: () {
          Get.toNamed(
            Routes.therapistDetail,
            arguments: terapeuta,
          );
        },
      ),
    );
  }
}

class _EmptyResultsMessage extends StatelessWidget {
  const _EmptyResultsMessage({
    required this.query,
    required this.colorScheme,
  });

  final String query;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'No encontramos terapeutas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty
                ? 'Intenta buscar por especialidad o ciudad.'
                : 'No hay resultados para "$query". Prueba con otro término.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
