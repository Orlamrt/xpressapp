import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../data/datasources/local/local_storage.dart';
import '../../../../data/datasources/marketplace_api_datasource.dart';
import '../../../shared/widgets/xpressatec_header_appbar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/tutor_profile_controller.dart';

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.white,
              colorScheme.surfaceVariant.withOpacity(0.2),
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
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Datos profesionales'),
                  const SizedBox(height: 12),
                  _buildRequiredField(
                    label: 'Nombre completo',
                    controller: controller.nombreCompletoController,
                    textCapitalization: TextCapitalization.words,
                    validator: _requiredValidator('Ingresa tu nombre completo'),
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    label: 'Cédula profesional',
                    controller: controller.cedulaProfesionalController,
                    textCapitalization: TextCapitalization.characters,
                    validator: _requiredValidator('Ingresa tu cédula profesional'),
                  ),
                  const SizedBox(height: 16),
                  _buildRequiredField(
                    label: 'Especialidad',
                    controller: controller.especialidadController,
                    textCapitalization: TextCapitalization.sentences,
                    validator: _requiredValidator('Indica tu especialidad'),
                  ),
                  const SizedBox(height: 20),
                  _buildModalidadesSelector(theme),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Descripción'),
                  const SizedBox(height: 12),
                  _buildOptionalField(
                    label: 'Biografía (máx. 500 caracteres)',
                    controller: controller.bioController,
                    maxLines: 5,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionalField(
                    label: 'Precio por consulta',
                    controller: controller.precioConsultaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }
                      final String normalized = value.replaceAll(',', '.');
                      if (double.tryParse(normalized) == null) {
                        return 'Ingresa un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Ubicación'),
                  const SizedBox(height: 12),
                  _buildOptionalField(
                    label: 'Estado',
                    controller: controller.estadoController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionalField(
                    label: 'Ciudad',
                    controller: controller.ciudadController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Horarios'),
                  const SizedBox(height: 12),
                  _buildOptionalField(
                    label: 'Horarios (JSON, ejemplo: {"lun": ["10:00-13:00"]})',
                    controller: controller.horariosController,
                    maxLines: 4,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }
                      try {
                        final dynamic parsed = jsonDecode(value.trim());
                        if (parsed is! Map<String, dynamic>) {
                          return 'El JSON debe ser un objeto con días y horarios';
                        }
                      } catch (_) {
                        return 'Revisa el formato JSON de los horarios';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(theme, 'Contacto'),
                  const SizedBox(height: 12),
                  _buildOptionalField(
                    label: 'Correo de contacto',
                    controller: controller.contactoEmailController,
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
                    label: 'Teléfono de contacto',
                    controller: controller.contactoTelefonoController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Obx(
                    () => FilledButton(
                      onPressed: controller.isSaving.value ? null : controller.save,
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

  Widget _buildSectionTitle(ThemeData theme, String title) {
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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

  Widget _buildModalidadesSelector(ThemeData theme) {
    const List<String> opciones = <String>['Presencial', 'En línea'];

    return FormField<List<String>>(
      validator: (_) {
        if (controller.selectedModalidades.isEmpty) {
          return 'Selecciona al menos una modalidad';
        }
        return null;
      },
      builder: (FormFieldState<List<String>> field) {
        return Obx(
          () {
            final List<String> seleccionadas = controller.selectedModalidades.toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Modalidades*',
                  style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: opciones.map((String opcion) {
                    final bool isSelected = seleccionadas.contains(opcion);
                    return FilterChip(
                      label: Text(opcion),
                      selected: isSelected,
                      onSelected: (_) {
                        controller.toggleModalidad(opcion);
                        field.didChange(controller.selectedModalidades.toList());
                      },
                      selectedColor: Colors.lightBlue.shade100,
                      checkmarkColor: Colors.lightBlue.shade900,
                    );
                  }).toList(),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }
}
