import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../data/datasources/local/local_storage.dart';
import '../../../../data/datasources/marketplace_api_datasource.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../marketplace/controllers/tutor_profile_controller.dart';

class TutorProfileUploadScreen extends StatefulWidget {
  const TutorProfileUploadScreen({super.key});

  @override
  State<TutorProfileUploadScreen> createState() => _TutorProfileUploadScreenState();
}

class _TutorProfileUploadScreenState extends State<TutorProfileUploadScreen> {
  late final TutorProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put<TutorProfileController>(
      TutorProfileController(
        datasource: Get.find<MarketplaceApiDatasource>(),
        authController: Get.find<AuthController>(),
        localStorage: Get.find<LocalStorage>(),
      ),
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<TutorProfileController>()) {
      Get.delete<TutorProfileController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.white,
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
              ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Datos profesionales'),
                  const SizedBox(height: 12),
                  _buildRequiredField(
                    label: 'Correo electrónico',
                    controller: controller.emailCtrl,
                    readOnly: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                    helperText: 'Este correo identifica tu perfil en el marketplace',
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    label: 'Cédula profesional',
                    controller: controller.cedulaCtrl,
                    textCapitalization: TextCapitalization.characters,
                    validator: controller.validateCedula,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionalField(
                    label: 'Especialidad',
                    controller: controller.especialidadCtrl,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Sector de servicio'),
                  const SizedBox(height: 12),
                  _buildSectorSelector(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Contacto'),
                  const SizedBox(height: 12),
                  _buildOptionalField(
                    label: 'Teléfono',
                    controller: controller.telCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOptionalField(
                    label: 'Celular',
                    controller: controller.celCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOptionalField(
                    label: 'Correo alternativo',
                    controller: controller.correoAltCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }
                      if (!GetUtils.isEmail(value.trim())) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionalField(
                    label: 'Red social',
                    controller: controller.redSocialCtrl,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionalField(
                    label: 'WhatsApp',
                    controller: controller.waCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => FilledButton(
                      onPressed: controller.isSaving.value ? null : controller.saveProfile,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Guardar'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Subir información',
          style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ) ??
              TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Comparte o actualiza tu perfil profesional para que las familias puedan encontrarte en el marketplace.',
          style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ) ??
              TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final ThemeData theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ) ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildRequiredField({
    required String label,
    required TextEditingController controller,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: validator,
    );
  }

  Widget _buildOptionalField({
    required String label,
    required TextEditingController controller,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }

  Widget _buildSectorSelector(BuildContext context) {
    final Map<String, String> sectorLabels = <String, String>{
      'PR': 'Privado',
      'PU': 'Público',
      'AM': 'Ambos',
    };

    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: sectorLabels.entries.map((MapEntry<String, String> entry) {
          final bool isSelected = controller.selectedSector.value == entry.key;
          return ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (_) => controller.changeSector(entry.key),
          );
        }).toList(),
      ),
    );
  }
}
