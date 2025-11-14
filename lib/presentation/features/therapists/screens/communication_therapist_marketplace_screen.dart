import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, ciudad o especialidad',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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
    final String? telefono = contacto['Telefono'] as String?;
    final String? correo = contacto['Correo'] as String?;
    final String? redSocial = contacto['RedSocial'] as String?;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          terapeuta.nombre,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              especialidad,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sector: ${_sectorLabel(terapeuta.tipoSector)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (telefono != null && telefono.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Teléfono: $telefono',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (correo != null && correo.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Correo: $correo',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (redSocial != null && redSocial.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Red social: $redSocial',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
        trailing: Text(
          terapeuta.tipoSector,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // TODO: Integrar navegación o contacto cuando el detalle esté disponible.
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
