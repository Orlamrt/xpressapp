import 'package:get/get.dart';

import '../models/communication_therapist.dart';

class CommunicationTherapistController extends GetxController {
  CommunicationTherapistController();

  /// TODO: Replace this mock list with data provided by a
  /// [TherapistRepository] once the backend is available.
  final RxList<CommunicationTherapist> therapists = <CommunicationTherapist>[
    CommunicationTherapist(
      nombre: 'Laura Fernández',
      especialidad: 'Terapia de Lenguaje Infantil',
      anosExperiencia: 8,
      modalidad: 'Online',
      ubicacion: 'Ciudad de México',
      rating: 4.8,
      tags: const ['Autismo', 'Infantil', 'TEACCH'],
    ),
    CommunicationTherapist(
      nombre: 'Miguel Torres',
      especialidad: 'Comunicación Aumentativa y Alternativa',
      anosExperiencia: 12,
      modalidad: 'Híbrido',
      ubicacion: 'Guadalajara',
      rating: 4.6,
      tags: const ['CAA', 'Adultos', 'Tecnología Asistiva'],
    ),
    CommunicationTherapist(
      nombre: 'Ana Beltrán',
      especialidad: 'Rehabilitación del Habla',
      anosExperiencia: 6,
      modalidad: 'Presencial',
      ubicacion: 'Monterrey',
      rating: 4.9,
      tags: const ['Neurológico', 'Adultos'],
    ),
    CommunicationTherapist(
      nombre: 'Paola Jiménez',
      especialidad: 'Lenguaje y Comunicación Temprana',
      anosExperiencia: 5,
      modalidad: 'Online',
      ubicacion: 'Puebla',
      rating: 4.7,
      tags: const ['Infantil', 'Intervención Temprana'],
    ),
  ].obs;

  final RxList<CommunicationTherapist> filteredTherapists =
      <CommunicationTherapist>[].obs;

  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filteredTherapists.assignAll(therapists);
  }

  void filterTherapists(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredTherapists.assignAll(therapists);
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredTherapists.assignAll(
      therapists.where(
        (therapist) => therapist.nombre.toLowerCase().contains(lowerQuery) ||
            therapist.especialidad.toLowerCase().contains(lowerQuery) ||
            therapist.ubicacion.toLowerCase().contains(lowerQuery),
      ),
    );
  }
}
