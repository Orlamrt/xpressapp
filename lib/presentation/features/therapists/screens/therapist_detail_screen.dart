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

    if (terapeuta == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del terapeuta'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del terapeuta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      terapeuta.nombre,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      especialidad,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Cédula profesional',
                      value: terapeuta.cedulaProfesional,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Sector',
                      value: _sectorLabel(terapeuta.tipoSector),
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: 'Correo principal',
                      value: terapeuta.email,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Datos de contacto',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (contactItems.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No hay información de contacto adicional disponible.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Column(
                children: contactItems
                    .map(
                      (item) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            color: colorScheme.primary,
                          ),
                          title: Text(item.label),
                          subtitle: Text(item.value),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
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
