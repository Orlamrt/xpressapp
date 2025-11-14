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

    final Color backgroundTint = Color.alphaBlend(
      colorScheme.primary.withOpacity(0.04),
      colorScheme.surface,
    );

    return Scaffold(
      backgroundColor: backgroundTint,
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Terapeutas en comunicación',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Explora especialistas en comunicación y lenguaje.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              _SearchField(
                controller: controller.searchCtrl,
                onChanged: controller.onSearchChanged,
              ),
              const SizedBox(height: 24),
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
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 12),
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final TerapeutaMarketplace terapeuta = terapeutas[index];
                      return _TherapistCard(
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surface,
          hintText: 'Buscar por nombre, ciudad o especialidad',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.45),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: colorScheme.primary.withOpacity(0.14),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: colorScheme.primary.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: colorScheme.primary.withOpacity(0.35),
              width: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _TherapistCard extends StatelessWidget {
  const _TherapistCard({
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

  List<_ContactChipData> _buildContactChips(Map<String, dynamic> contacto) {
    final List<_ContactChipData> contactChips = [];

    void addChip(IconData icon, String label, String? value) {
      if (value == null) return;
      final String trimmed = value.trim();
      if (trimmed.isEmpty) return;
      contactChips.add(
        _ContactChipData(icon: icon, label: label, value: trimmed),
      );
    }

    addChip(
        Icons.phone_outlined, 'Teléfono', contacto['Telefono'] as String?);
    addChip(
        Icons.smartphone_outlined, 'Celular', contacto['Celular'] as String?);
    addChip(
        Icons.alternate_email_rounded, 'Red social',
        contacto['RedSocial'] as String?);
    addChip(Icons.telegram, 'WhatsApp', contacto['WhatsApp'] as String?);

    return contactChips;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String especialidad =
        (terapeuta.especialidad?.trim().isNotEmpty ?? false)
            ? terapeuta.especialidad!.trim()
            : 'Sin especialidad';

    final List<_ContactChipData> contactChips =
        _buildContactChips(terapeuta.contacto);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Get.toNamed(
            Routes.therapistDetail,
            arguments: terapeuta,
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.surface,
                colorScheme.primary.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.primary.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarBadge(colorScheme: colorScheme, name: terapeuta.nombre),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            terapeuta.nombre,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            especialidad,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _SectorBadge(
                      label: _sectorLabel(terapeuta.tipoSector),
                      code: terapeuta.tipoSector,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.mail_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        terapeuta.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (contactChips.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _ContactChipsRow(chips: contactChips),
                ],
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Get.toNamed(
                        Routes.therapistDetail,
                        arguments: terapeuta,
                      );
                    },
                    icon: Icon(Icons.chevron_right_rounded,
                        color: colorScheme.primary),
                    label: Text(
                      'Ver perfil',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.colorScheme,
    required this.name,
  });

  final ColorScheme colorScheme;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((e) => e[0]).join().toUpperCase()
        : 'TX';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: Text(
            initials,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ) ??
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
          ),
        ),
      ),
    );
  }
}

class _SectorBadge extends StatelessWidget {
  const _SectorBadge({
    required this.label,
    required this.code,
    required this.colorScheme,
    required this.theme,
  });

  final String label;
  final String code;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            code,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary.withOpacity(0.7),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactChipsRow extends StatelessWidget {
  const _ContactChipsRow({required this.chips});

  final List<_ContactChipData> chips;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: chips.map((chip) => _ContactChip(data: chip)).toList(),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.data});

  final _ContactChipData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.12)),
      ),
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${data.label} · ${data.value}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactChipData {
  const _ContactChipData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.08),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No encontramos terapeutas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
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
      ),
    );
  }
}
