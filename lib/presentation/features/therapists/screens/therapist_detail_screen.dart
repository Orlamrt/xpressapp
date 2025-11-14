import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/data/models/terapeuta_marketplace.dart';

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
        contactInfo.add(_ContactInfo(label: label, value: value.trim(), icon: icon));
      }
    }

    addIfValid('Teléfono', Icons.phone, contacto['Telefono'] as String?);
    addIfValid('Celular', Icons.smartphone, contacto['Celular'] as String?);
    addIfValid('Correo', Icons.email_outlined, contacto['Correo'] as String?);
    addIfValid('Red social', Icons.alternate_email, contacto['RedSocial'] as String?);
    addIfValid('WhatsApp', Icons.chat, contacto['WhatsApp'] as String?);

    return contactInfo;
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final TerapeutaMarketplace? terapeuta =
        arguments is TerapeutaMarketplace ? arguments : null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color backgroundTint = colorScheme.primary.withOpacity(0.06);

    if (terapeuta == null) {
      return Scaffold(
        backgroundColor: backgroundTint,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Detalle del terapeuta',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: Get.back,
          ),
        ),
        body: Center(
          child: Text(
            'No se pudo cargar la información del terapeuta.',
            style: theme.textTheme.bodyLarge,
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

    final String initials = _initialsFromName(terapeuta.nombre);

    return Scaffold(
      backgroundColor: backgroundTint,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Detalle del terapeuta',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.18),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.12),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          initials,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                especialidad,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _DetailHighlight(
                    icon: Icons.badge_outlined,
                    label: 'Cédula profesional',
                    value: terapeuta.cedulaProfesional,
                  ),
                  const SizedBox(height: 12),
                  _DetailHighlight(
                    icon: Icons.domain_outlined,
                    label: 'Sector',
                    value: _sectorLabel(terapeuta.tipoSector),
                  ),
                  const SizedBox(height: 12),
                  _DetailHighlight(
                    icon: Icons.mail_outline,
                    label: 'Correo principal',
                    value: terapeuta.email,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Datos de contacto',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            if (contactItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Text(
                  'No hay información de contacto adicional disponible.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              )
            else
              Column(
                children: contactItems
                    .map(
                      (item) => _ContactCard(
                        info: item,
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      final word = parts.first;
      final int count = min(2, word.length);
      return word.substring(0, count).toUpperCase();
    }
    final String first = parts.first;
    final String last = parts.last;
    final String firstInitial = first.isNotEmpty ? first[0] : '';
    final String lastInitial = last.isNotEmpty ? last[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }
}

class _DetailHighlight extends StatelessWidget {
  const _DetailHighlight({
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
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.info,
    required this.colorScheme,
    required this.theme,
  });

  final _ContactInfo info;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(info.icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
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
