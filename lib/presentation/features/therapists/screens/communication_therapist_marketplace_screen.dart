import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/communication_therapist_controller.dart';
import '../models/communication_therapist.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';

class CommunicationTherapistMarketplaceScreen extends GetView<CommunicationTherapistController> {
  const CommunicationTherapistMarketplaceScreen({super.key});

  @override
  CommunicationTherapistController get controller =>
      Get.find<CommunicationTherapistController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
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
                onChanged: controller.filterTherapists,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  final therapists = controller.filteredTherapists;

                  if (therapists.isEmpty) {
                    return _EmptyResultsMessage(
                      query: controller.searchQuery.value,
                      colorScheme: colorScheme,
                    );
                  }

                  return ListView.separated(
                    itemCount: therapists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final therapist = therapists[index];
                      return _TherapistCard(
                        therapist: therapist,
                        colorScheme: colorScheme,
                        onTap: () => _showTherapistDetails(context, therapist),
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

  void _showTherapistDetails(
    BuildContext context,
    CommunicationTherapist therapist,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TherapistAvatar(
                    therapist: therapist,
                    size: 56,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          therapist.nombre,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          therapist.especialidad,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Ubicación',
                value: therapist.ubicacion,
              ),
              _DetailRow(
                icon: Icons.school_outlined,
                label: 'Experiencia',
                value: '${therapist.anosExperiencia} años',
              ),
              _DetailRow(
                icon: Icons.computer_outlined,
                label: 'Modalidad',
                value: therapist.modalidad,
              ),
              _DetailRow(
                icon: Icons.star_rounded,
                label: 'Calificación',
                value: therapist.rating.toStringAsFixed(1),
              ),
              const SizedBox(height: 12),
              Text(
                'Especialidades y enfoques',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: therapist.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Integrar acción para contactar al terapeuta
                    // cuando el backend y el TherapistRepository estén listos.
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Contactar (próximamente)'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, ciudad o especialidad',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({
    required this.therapist,
    required this.colorScheme,
    required this.onTap,
  });

  final CommunicationTherapist therapist;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TherapistAvatar(
                    therapist: therapist,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          therapist.nombre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          therapist.especialidad,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 18, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                therapist.ubicacion,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.school_outlined,
                              label: '${therapist.anosExperiencia} años',
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.computer_outlined,
                              label: therapist.modalidad,
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          color: colorScheme.secondary, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        therapist.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: therapist.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: colorScheme.primary.withOpacity(0.08),
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TherapistAvatar extends StatelessWidget {
  const _TherapistAvatar({
    required this.therapist,
    required this.colorScheme,
    this.size = 64,
  });

  final CommunicationTherapist therapist;
  final ColorScheme colorScheme;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = therapist.nombre
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colorScheme.primary.withOpacity(0.15),
      backgroundImage:
          therapist.fotoUrl != null ? AssetImage(therapist.fotoUrl!) : null,
      child: therapist.fotoUrl == null
          ? Text(
              initials,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            )
          : null,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
