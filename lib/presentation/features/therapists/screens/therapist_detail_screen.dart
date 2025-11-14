import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/data/models/terapeuta_marketplace.dart';

import '../../../shared/widgets/xpressatec_header_appbar.dart';

class TherapistDetailScreen extends StatelessWidget {
  const TherapistDetailScreen({super.key});

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

  List<_ContactInfo> _buildContactInfo(Map<String, dynamic> contacto) {
    final List<_ContactInfo> contactInfo = [];

    void addIfValid(String label, IconData icon, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        contactInfo.add(
          _ContactInfo(label: label, value: value.trim(), icon: icon),
        );
      }
    }

    addIfValid('Teléfono', Icons.phone_outlined, contacto['Telefono'] as String?);
    addIfValid('Celular', Icons.smartphone_outlined, contacto['Celular'] as String?);
    addIfValid('Red social', Icons.alternate_email_rounded,
        contacto['RedSocial'] as String?);
    addIfValid('WhatsApp', Icons.telegram, contacto['WhatsApp'] as String?);

    return contactInfo;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final TerapeutaMarketplace? terapeuta =
        arguments is TerapeutaMarketplace ? arguments : null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color backgroundTint = Color.alphaBlend(
      colorScheme.primary.withOpacity(0.04),
      colorScheme.surface,
    );

    if (terapeuta == null) {
      return Scaffold(
        backgroundColor: backgroundTint,
        appBar: const XpressatecHeaderAppBar(showBack: true),
        body: Center(
          child: Text(
            'No se pudo cargar la información del terapeuta.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final String especialidad =
        (terapeuta.especialidad?.trim().isNotEmpty ?? false)
            ? terapeuta.especialidad!.trim()
            : 'Sin especialidad';
    final String sectorLabel = _sectorLabel(terapeuta.tipoSector);
    final List<_ContactInfo> contactItems = [
      _ContactInfo(
        label: 'Correo principal',
        value: terapeuta.email,
        icon: Icons.mail_outline,
      ),
      ..._buildContactInfo(terapeuta.contacto),
    ];

    return Scaffold(
      backgroundColor: backgroundTint,
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileOverviewCard(
                terapeuta: terapeuta,
                especialidad: especialidad,
                sectorLabel: sectorLabel,
              ),
              const SizedBox(height: 28),
              _ContactSectionCard(contactItems: contactItems),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOverviewCard extends StatelessWidget {
  const _ProfileOverviewCard({
    required this.terapeuta,
    required this.especialidad,
    required this.sectorLabel,
  });

  final TerapeutaMarketplace terapeuta;
  final String especialidad;
  final String sectorLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initials = terapeuta.nombre.trim().isNotEmpty
        ? terapeuta.nombre
            .trim()
            .split(' ')
            .where((element) => element.isNotEmpty)
            .take(2)
            .map((e) => e[0])
            .join()
            .toUpperCase()
        : 'TX';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.primary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 36,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradientAvatar(initials: initials),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terapeuta.nombre,
                      style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ) ??
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      especialidad,
                      style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ) ??
                          TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),
              ),
              _DetailSectorBadge(
                label: sectorLabel,
                code: terapeuta.tipoSector,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Cédula profesional',
            value: terapeuta.cedulaProfesional,
          ),
        ],
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
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
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.12),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Center(
          child: Text(
            initials,
            style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ) ??
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
          ),
        ),
      ),
    );
  }
}

class _DetailSectorBadge extends StatelessWidget {
  const _DetailSectorBadge({
    required this.label,
    required this.code,
  });

  final String label;
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                ) ??
                TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
          ),
          Text(
            code,
            style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary.withOpacity(0.7),
                  letterSpacing: 1.1,
                ) ??
                TextStyle(
                  color: colorScheme.primary.withOpacity(0.7),
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class _ContactSectionCard extends StatelessWidget {
  const _ContactSectionCard({required this.contactItems});

  final List<_ContactInfo> contactItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: contactItems.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos de contacto',
                    style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ) ??
                        TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay información de contacto adicional disponible.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ) ??
                        TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 16,
                        ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos de contacto',
                    style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ) ??
                        TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(contactItems.length, (index) {
                    final item = contactItems[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == contactItems.length - 1 ? 0 : 18),
                      child: _InfoRow(
                        icon: item.icon,
                        label: item.label,
                        value: item.value,
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ) ??
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactInfo {
  const _ContactInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}
