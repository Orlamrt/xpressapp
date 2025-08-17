import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class AgendarView extends StatefulWidget {
  const AgendarView({super.key});

  @override
  _AgendarViewState createState() => _AgendarViewState();
}

class _AgendarViewState extends State<AgendarView> {
  final TextEditingController _patientNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _tutorName = '';
  String _searchedTutorName = '';
  bool _isLoadingTutor = true;
  List<Map<String, dynamic>> _patients = [];
  Map<String, dynamic>? _selectedPatient;
  // Variables de estado que necesitarás:
  Map<String, dynamic>?
  _patientInfo; // guardará { idPaciente, idTerapeuta, nombreTutor }

  Future<String?> _getTutorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id_tutor');
  }

  Future<void> _getPatientsByTutor() async {
    try {
      String? tutorId = await _getTutorId();

      if (tutorId == null) {
        setState(() {
          _tutorName = 'No se encontró el ID del tutor';
          _isLoadingTutor = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://69.62.69.122:8080/tutor-por-paciente'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idTutor': tutorId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _patients = List<Map<String, dynamic>>.from(data['pacientes']);
            _isLoadingTutor = false;
            _tutorName = data['pacientes'].isNotEmpty
                ? data['pacientes'][0]['nombreTerapeuta']
                : 'Tutor no asignado';
          });
        } else {
          setState(() {
            _tutorName = 'No asignado';
            _isLoadingTutor = false;
          });
        }
      } else {
        setState(() {
          _tutorName = 'Error al obtener los pacientes';
          _isLoadingTutor = false;
        });
      }
    } catch (e) {
      setState(() {
        _tutorName = 'Error de conexión';
        _isLoadingTutor = false;
      });
    }
  }

  Future<void> _guardarCita() async {
    final nombre = _patientNameController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el nombre del paciente.')),
      );
      return;
    }

    await _buscarPacienteEnDB(nombre);

    if (_patientInfo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Paciente no encontrado.')));
      return;
    }

    // Verificar si los valores no son null o vacíos
    String idTutor = _patientInfo!['idTutor']?.toString() ?? '';
    String idTerapeuta = _patientInfo!['idTerapeuta']?.toString() ?? '';

    if (idTutor.isEmpty || idTerapeuta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de tutor o terapeuta faltante.')),
      );
      return;
    }

    DateTime fechaCita = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final response = await http.post(
        Uri.parse('http://69.62.69.122:8080/guardar-cita'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idTutor': int.parse(idTutor),
          'idTerapeuta': int.parse(idTerapeuta),
          'fechaCita': fechaCita.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita guardada exitosamente')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${data['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _buscarPacienteEnDB(String nombrePaciente) async {
    final response = await http.post(
      Uri.parse('http://69.62.69.122:8080/tutor-por-paciente'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nombrePaciente': nombrePaciente}),
    );

    try {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() {
          _patientInfo = {
            'idPaciente': data['idPaciente'] ?? '',
            'idTerapeuta': data['idTerapeuta'] ?? '',
            'idTutor': data['idTutor'],
            'nombreTutor': data['nombreTutor'] ?? '',
          };
          _searchedTutorName = data['nombreTutor'] ?? 'Sin tutor asignado';
        });
      } else {
        setState(() {
          _patientInfo = null;
          _searchedTutorName = 'Paciente no encontrado';
        });
      }
    } catch (e) {
      print('Error al procesar la respuesta: $e');
      setState(() {
        _patientInfo = null;
        _searchedTutorName = 'Error al buscar el paciente';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getPatientsByTutor();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agendar Cita'),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCalendarCard(),
              const SizedBox(height: 20),
              _buildPatientSearchSection(),
              const SizedBox(height: 20),
              _buildTimePickerSection(),
              const SizedBox(height: 30),
              _buildScheduleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          focusedDay: _selectedDate,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: const Color(0xDDD96C94).withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: const Color(0xDDD96C94),
              shape: BoxShape.circle,
            ),
            weekendTextStyle: TextStyle(
              color: const Color(0xDDD96C94).withOpacity(0.8),
            ),
            outsideDaysVisible: false,
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: const TextStyle(
              color: Color(0xDDD96C94),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            formatButtonVisible: false,
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: Color(0xDDD96C94),
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: Color(0xDDD96C94),
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: const Color(0xDDD96C94).withOpacity(0.8),
            ),
            weekendStyle: TextStyle(
              color: const Color(0xDDD96C94).withOpacity(0.6),
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() => _selectedDate = selectedDay);
          },
          selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
        ),
      ),
    );
  }

  Widget _buildPatientSearchSection() {
    return Column(
      children: [
        TextFormField(
          controller: _patientNameController,
          decoration: InputDecoration(
            labelText: 'Nombre del paciente',
            labelStyle: const TextStyle(color: Color(0xDDD96C94)),
            floatingLabelStyle: const TextStyle(color: Color(0xDDD96C94)),
            prefixIcon: const Icon(Icons.person, color: Color(0xDDD96C94)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xDDD96C94)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xDDD96C94), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search, size: 28, color: Colors.white),
            label: const Text(
              'Buscar Paciente',
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xDDD96C94),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
            ),
            onPressed: () async {
              final nombre = _patientNameController.text.trim();
              if (nombre.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa el nombre del paciente'),
                  ),
                );
                return;
              }
              await _buscarPacienteEnDB(nombre);
            },
          ),
        ),
        if (_searchedTutorName.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xDDD96C94).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xDDD96C94).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Color(0xDDD96C94)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tutor asignado: $_searchedTutorName',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTimePickerSection() {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hora seleccionada:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xDDD96C94).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xDDD96C94),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) setState(() => _selectedTime = time);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time, color: Color(0xDDD96C94)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.calendar_today, size: 28, color: Colors.white),
      label: const Text('Agendar Cita'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xDDD96C94),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      onPressed: _guardarCita,
    );
  }
}
