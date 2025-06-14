import 'package:flutter/material.dart';

class TherapistsView extends StatelessWidget {
  // Lista de terapeutas simulada para mostrar en la vista
  final List<Therapist> therapists = [
    Therapist(
      name: 'Dr. Ana López',
      specialty: 'Psicología Infantil',
      experience: 5,
      rating: 4.8,
      imageUrl: 'https://via.placeholder.com/150', // URL de imagen de ejemplo
      description: 'Especialista en psicología infantil con enfoque en desarrollo emocional y conductual de niños.',
    ),
    Therapist(
      name: 'Lic. Carlos Pérez',
      specialty: 'Terapia Familiar',
      experience: 8,
      rating: 4.5,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Experto en terapia familiar y resolución de conflictos para mejorar la dinámica familiar.',
    ),
    Therapist(
      name: 'Dra. María García',
      specialty: 'Psicología Clínica',
      experience: 10,
      rating: 4.9,
      imageUrl: 'https://via.placeholder.com/150',
      description: 'Psicóloga clínica con amplia experiencia en tratamiento de trastornos mentales y emocionales.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Evita que el usuario retroceda a la pantalla anterior
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contratar Terapeutas'),
          backgroundColor: const Color(0xFFF2DCD8),
          titleTextStyle: const TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: therapists.length,
          itemBuilder: (context, index) {
            final therapist = therapists[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(therapist.imageUrl),
                  radius: 30,
                ),
                title: Text(
                  therapist.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Especialidad: ${therapist.specialty}'),
                    Text('Experiencia: ${therapist.experience} años'),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${therapist.rating}', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  // Mostrar detalles del terapeuta al hacer clic
                  showTherapistDetails(context, therapist);
                },
                trailing: ElevatedButton(
                  onPressed: () {
                    // Lógica para contratar al terapeuta
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Contratar a ${therapist.name}'),
                        content: Text('¿Deseas contratar los servicios de ${therapist.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Acción de contratación
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Has contratado a ${therapist.name}'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xDDD96C94),
                              foregroundColor: const Color(0xFFF2DCD8),
                            ),
                            child: const Text('Contratar'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xDDD96C94),
                    foregroundColor: const Color(0xFFF2DCD8),
                  ),
                  child: const Text('Contratar'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Método para mostrar detalles del terapeuta
  void showTherapistDetails(BuildContext context, Therapist therapist) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(therapist.imageUrl),
                radius: 50,
              ),
              const SizedBox(height: 16),
              Text(
                therapist.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Especialidad: ${therapist.specialty}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Experiencia: ${therapist.experience} años',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                therapist.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Clase modelo para los terapeutas
class Therapist {
  final String name;
  final String specialty;
  final int experience;
  final double rating;
  final String imageUrl;
  final String description;

  Therapist({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.imageUrl,
    required this.description,
  });
}
