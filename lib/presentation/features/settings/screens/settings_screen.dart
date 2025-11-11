import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/routes.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Ajustes',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Preferencias'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notificaciones'),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            trailing: const Text('Español'),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema oscuro'),
            value: false,
            onChanged: (_) {},
          ),
          const Divider(),
          _buildSectionTitle(context, 'Experiencia'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Personalización'),
            subtitle: const Text('Gestiona tus pictogramas locales'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.customization),
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title: const Text('Descargar pictogramas'),
            subtitle:
                const Text('Guarda los pictogramas en el dispositivo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.downloadPictograms),
          ),
          ListTile(
            leading: const Icon(Icons.headset_mic_outlined),
            title: const Text('Descargar paquetes de audio'),
            subtitle: const Text('Gestionar voces de asistentes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(
              Routes.packageDownload,
              arguments: {'fromSettings': true},
            ),
          ),
          const Divider(),
          _buildSectionTitle(context, 'Soporte'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacidad'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Ayuda'),
            onTap: () {},
          ),
        ],
      ),
    )
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
