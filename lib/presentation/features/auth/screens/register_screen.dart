import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
import 'package:xpressatec/presentation/shared/widgets/xpressatec_header_appbar.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // State controllers remain here
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final fechaNacimientoController = TextEditingController();
    final cedulaController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    final obscurePassword = true.obs;
    final obscureConfirmPassword = true.obs;
    DateTime? selectedDate;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const XpressatecHeaderAppBar(showBack: true),
      body: SafeArea(
        // Use LayoutBuilder to create a responsive layout
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              // Constrain the width on larger screens (e.g., tablets, web)
              child: ConstrainedBox(
                // A slightly wider max-width for the registration form
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildRegisterForm(
                  context: context,
                  formKey: formKey,
                  nombreController: nombreController,
                  emailController: emailController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  fechaNacimientoController: fechaNacimientoController,
                  cedulaController: cedulaController,
                  obscurePassword: obscurePassword,
                  obscureConfirmPassword: obscureConfirmPassword,
                  onDateSelected: (date) {
                    selectedDate = date;
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Extracted the form into a separate method for cleanliness
  Widget _buildRegisterForm({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController nombreController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController fechaNacimientoController,
    required TextEditingController cedulaController,
    required RxBool obscurePassword,
    required RxBool obscureConfirmPassword,
    required Function(DateTime) onDateSelected,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // Title
            const Text(
              'Crear Cuenta',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Completa el formulario para registrarte',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Role Selector
            const Text(
              'Selecciona tu rol',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildRoleOption(
                    'Paciente',
                    'Usuario que recibirá terapia',
                    Icons.face,
                    controller.selectedRole.value == 'Paciente',
                        () => controller.selectedRole.value = 'Paciente',
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildRoleOption(
                    'Tutor',
                    'Familiar o cuidador del paciente',
                    Icons.supervisor_account,
                    controller.selectedRole.value == 'Tutor',
                        () => controller.selectedRole.value = 'Tutor',
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  _buildRoleOption(
                    'Terapeuta',
                    'Profesional de la salud',
                    Icons.local_hospital,
                    controller.selectedRole.value == 'Terapeuta',
                        () => controller.selectedRole.value = 'Terapeuta',
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),

            // --- ALL OTHER FORM FIELDS AND BUTTONS REMAIN THE SAME ---
            // (The code below is identical to your original file)

            // Nombre Field
            TextFormField(
              controller: nombreController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                hintText: 'Juan Pérez',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu nombre completo';
                }
                if (value.length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'ejemplo@correo.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu correo';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password Field
            Obx(() => TextFormField(
              controller: passwordController,
              obscureText: obscurePassword.value,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => obscurePassword.toggle(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa una contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            )),
            const SizedBox(height: 16),

            // Confirm Password Field
            Obx(() => TextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword.value,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => obscureConfirmPassword.toggle(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor confirma tu contraseña';
                }
                if (value != passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            )),
            const SizedBox(height: 16),

            // Conditional Fields based on Role
            Obx(() {
              final role = controller.selectedRole.value;
              final requiresBirthDate =
                  role == 'Paciente' || role == 'Tutor' || role == 'Terapeuta';
              final showCedula = role == 'Terapeuta';

              return Column(
                children: [
                  if (requiresBirthDate)
                    Column(
                      children: [
                        TextFormField(
                          controller: fechaNacimientoController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Fecha de nacimiento',
                            hintText: 'dd/mm/aaaa',
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1920),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.blue.shade700,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              onDateSelected(picked);
                              fechaNacimientoController.text =
                                  '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                            }
                          },
                          validator: (value) {
                            if (requiresBirthDate &&
                                (value == null || value.isEmpty)) {
                              return 'Por favor selecciona tu fecha de nacimiento';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  if (showCedula)
                    Column(
                      children: [
                        TextFormField(
                          controller: cedulaController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Cédula profesional',
                            hintText: '1234567',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (showCedula && (value == null || value.isEmpty)) {
                              return 'Por favor ingresa tu cédula profesional';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                ],
              );
            }),

            const SizedBox(height: 8),

            // Register Button
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                if (formKey.currentState!.validate()) {
                  // Format date to YYYY-MM-DD for API
                  String? formattedDate;
                  final dateText = fechaNacimientoController.text;
                  if (dateText.isNotEmpty) {
                    try {
                      // A simple way to get the date back if needed
                      final parts = dateText.split('/');
                      final day = int.parse(parts[0]);
                      final month = int.parse(parts[1]);
                      final year = int.parse(parts[2]);
                      final selectedDate = DateTime(year, month, day);
                      formattedDate =
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                    } catch (e) {
                      formattedDate = null;
                    }
                  }

                  final selectedRole = controller.selectedRole.value;
                  final requiresBirthDate = selectedRole == 'Paciente' ||
                      selectedRole == 'Tutor' ||
                      selectedRole == 'Terapeuta';

                  controller.register(
                    nombre: nombreController.text.trim(),
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    rol: selectedRole,
                    fechaNacimiento:
                        requiresBirthDate ? formattedDate : null,
                    cedula: selectedRole == 'Terapeuta' &&
                            cedulaController.text.trim().isNotEmpty
                        ? cedulaController.text.trim()
                        : null,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            const SizedBox(height: 16),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Ya tienes cuenta? ',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // This helper method remains unchanged
  Widget _buildRoleOption(
      String role,
      String description,
      IconData icon,
      bool isSelected,
      VoidCallback onTap,
      ) {
    // ... (Your existing code for this method is perfect)
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue.shade700 : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }
}