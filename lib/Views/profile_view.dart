import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpressapp/Controllers/controller.dart';
import 'package:xpressapp/Views/qr_scanner_view.dart';

class ProfileView extends StatefulWidget {
  final String name;
  final String email;
  final String role;
  final String? assignedPatientName; // Añade este parámetro

  const ProfileView({
    Key? key,
    required this.name,
    required this.email,
    required this.role,
    this.assignedPatientName, // Añade este parámetro en el constructor
  }) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? patientUuid; // Variable para almacenar el UUID del paciente
  final controller = Get.find<ControllerTeach>(); // Instancia del controlador

  @override
  void initState() {
    super.initState();
    _loadPatientUuid(); // Cargar el UUID al iniciar
  }

  // Método para cargar el UUID
  Future<void> _loadPatientUuid() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      // Verifica si el widget sigue montado
      setState(() {
        patientUuid = prefs.getString('patient_uuid'); // Cargar el UUID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          backgroundColor: const Color(0xFFF2DCD8),
          titleTextStyle: const TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildUserInfoSection(),
              const SizedBox(height: 30),
              if (widget.role == 'Paciente') _buildQrButton(),
              if (widget.role == 'Tutor') _buildScannerButton(),
              const SizedBox(height: 30),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xDDD96C94),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: Text(
              widget.name.isNotEmpty ? widget.name[0] : '?',
              style: const TextStyle(
                fontSize: 50,
                color: Color(0xDDD96C94),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.name.isNotEmpty ? widget.name : 'No disponible',
          style: const TextStyle(
            fontSize: 28,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Icons.email,
          title: 'Email',
          content: widget.email,
        ),
        const SizedBox(height: 15),
        _buildInfoCard(
          icon: Icons.people,
          title: 'Rol',
          content: widget.role,
        ),
        if (widget.role == 'Tutor' && widget.assignedPatientName != null)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: _buildInfoCard(
              icon: Icons.medical_services,
              title: 'Paciente Asignado',
              content: widget.assignedPatientName!,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String content}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xDDD96C94), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
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

  Widget _buildQrButton() {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.qr_code,
        size: 28,
        color: Colors.white,
      ),
      label: const Text('Enlazar Tutor'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xDDD96C94),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      onPressed: () async {
        final qrCodeBytes = await controller.fetchQrCodeImage();
        if (qrCodeBytes != null) {
          Get.dialog(
            AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Código QR',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xDDD96C94)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.memory(qrCodeBytes),
                  const SizedBox(height: 20),
                  const Text(
                    'Escanea este código para vincular un tutor',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xDDD96C94),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildScannerButton() {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.qr_code_scanner,
        size: 28,
        color: Colors.white,
      ),
      label: const Text('Escanear Código QR'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xDDD96C94),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 8,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      onPressed: () async {
        final scannedCode = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QrScannerView()),
        );

        // Aquí puedes manejar el código escaneado
        if (scannedCode != null) {
          // Por ejemplo, mostrarlo en un SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Código escaneado: $scannedCode')),
          );
        }
      },
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(
        Icons.logout,
        size: 28,
        color: const Color(0xDDD96C94),
      ),
      label: const Text('Cerrar Sesión'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xDDD96C94),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xDDD96C94), width: 2),
        ),
        elevation: 8,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      onPressed: () => Get.find<ControllerTeach>().logout(),
    );
  }
}
