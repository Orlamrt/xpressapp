import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/core/config/routes.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
import 'package:xpressatec/presentation/features/therapists/screens/communication_therapist_marketplace_screen.dart';
import 'package:xpressatec/presentation/features/therapists/screens/tutor_profile_upload_screen.dart';

import 'drawer_action_card.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa Get.find con una verificación de seguridad
    final AuthController authController = Get.find<AuthController>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue,
                  colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.onPrimary,
                  child: Icon(Icons.person, size: 40, color: colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                  authController.userName.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )),
                Obx(() => Text(
                  authController.userEmail.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
                )),
                Obx(() => Text(
                  'Rol: ${authController.userRole.value}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                )),
              ],
            ),
          ),
          // Enlazar tutor (Destacado) - Solo mostrar para pacientes
          Obx(() {
            if (authController.isPaciente) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: DrawerActionCard(
                  leadingIcon: Icons.link,
                  title: 'Enlazar tutor',
                  subtitle: 'Comparte tu código QR con tu tutor',
                  onTap: () => Get.toNamed(Routes.linkTutor),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          // Escanear QR y Mis citas - Mostrar según rol
          Obx(() {
            final bool showScan = authController.isTutor;
            final bool showAppointments =
                authController.isTutor || authController.isTerapeuta;

            if (!showScan && !showAppointments) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                if (showScan)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: DrawerActionCard(
                      leadingIcon: Icons.qr_code_scanner,
                      title: 'Escanear QR',
                      subtitle: 'Escanea el código del paciente',
                      onTap: () => Get.toNamed(Routes.scanQr),
                    ),
                  ),
                if (showAppointments)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: DrawerActionCard(
                      leadingIcon: Icons.event,
                      title: 'Mis citas',
                      subtitle: 'Revisa tu agenda de sesiones',
                      onTap: () => Get.toNamed(Routes.tutorCalendar),
                    ),
                  ),
              ],
            );
          }),
          Obx(() {
            final String userRole =
                authController.currentUser.value?.rol ??
                    authController.userRole.value;

            if (userRole != 'Terapeuta') {
              return const SizedBox.shrink();
            } 
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: DrawerActionCard(
                leadingIcon: Icons.cloud_upload_outlined,
                title: 'Subir información',
                subtitle: 'Actualiza tu perfil profesional en el marketplace',
                onTap: () => Get.to(() => const TutorProfileUploadScreen()),
              ),
            ); 
          }),

          Obx((){
            final String userRole =
                authController.currentUser.value?.rol ??
                    authController.userRole.value;

            if (userRole != 'Tutor') {
              return const SizedBox.shrink();
            } 
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: DrawerActionCard(
                leadingIcon: Icons.store_mall_directory,
                title: 'Marketplace',
                subtitle: 'Explora el marketplace de terapeutas',
                onTap: () => Get.toNamed(Routes.communicationTherapists),
              ),
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ajustes'),
            onTap: () => Get.toNamed(Routes.settings),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () => Get.toNamed(Routes.about),
          ),
          ListTile(
            leading: const Icon(Icons.mic, color: Colors.orange),
            title: const Text('Generador de Audios'),
            subtitle: const Text('Generar y subir audios a Firebase', style: TextStyle(fontSize: 12)),
            onTap: () => Get.toNamed('/audio-testing'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () => authController.logout(),
          ),

        ],
      ),
    );
  }
}
