class CommunicationTherapist {
  CommunicationTherapist({
    required this.nombre,
    required this.especialidad,
    required this.anosExperiencia,
    required this.modalidad,
    required this.ubicacion,
    required this.rating,
    required this.tags,
    this.fotoUrl,
  });

  final String nombre;
  final String especialidad;
  final int anosExperiencia;
  final String modalidad;
  final String ubicacion;
  final double rating;
  final List<String> tags;
  final String? fotoUrl;
}
