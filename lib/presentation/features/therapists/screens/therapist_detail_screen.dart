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
    addIfValid('Correo', Icons.email_outlined, contacto['Correo'] as String?);
    addIfValid('Red social', Icons.alternate_email, contacto['RedSocial'] as String?);
    addIfValid('WhatsApp', Icons.chat_outlined, contacto['WhatsApp'] as String?);

    return contactInfo;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final TerapeutaMarketplace? terapeuta =
        arguments is TerapeutaMarketplace ? arguments : null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color backgroundTint = colorScheme.primary.withOpacity(0.05);

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
    final List<_ContactInfo> contactItems =
        _buildContactInfo(terapeuta.contacto);

    return Scaffold(
      backgroundColor: backgroundTint,
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TherapistHeroCard(
                terapeuta: terapeuta,
                especialidad: especialidad,
                sectorLabel: _sectorLabel(terapeuta.tipoSector),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Información profesional'),
              const SizedBox(height: 16),
              _ElevatedContainer(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailTile(
                        icon: Icons.badge_outlined,
                        label: 'Cédula profesional',
                        value: terapeuta.cedulaProfesional,
                      ),
                      const SizedBox(height: 12),
                      _DetailTile(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Especialidad',
                        value: especialidad,
                      ),
                      const SizedBox(height: 12),
                      _DetailTile(
                        icon: Icons.apartment_outlined,
                        label: 'Sector',
                        value: _sectorLabel(terapeuta.tipoSector),
                      ),
                      const SizedBox(height: 12),
                      _DetailTile(
                        icon: Icons.mail_outline,
                        label: 'Correo principal',
                        value: terapeuta.email,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle('Datos de contacto'),
              const SizedBox(height: 16),
              if (contactItems.isEmpty)
                _ElevatedContainer(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Text(
                      'No hay información de contacto adicional disponible.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Column(
                  children: contactItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ContactTile(info: item),
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

class _TherapistHeroCard extends StatelessWidget {
  const _TherapistHeroCard({
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
            colorScheme.primary.withOpacity(0.3),
            colorScheme.secondary.withOpacity(0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.12),
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
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terapeuta.nombre,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      especialidad,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _HeroBadge(
                      icon: Icons.apartment_outlined,
                      label: 'Sector',
                      value: sectorLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Contacto principal',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            terapeuta.email,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ElevatedContainer extends StatelessWidget {
  const _ElevatedContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.info});

  final _ContactInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _ElevatedContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.12),
              ),
              child: Icon(info.icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
