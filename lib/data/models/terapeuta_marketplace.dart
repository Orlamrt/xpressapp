class TerapeutaMarketplace {
  TerapeutaMarketplace({
    required this.idPersona,
    required this.nombre,
    required this.email,
    required this.cedulaProfesional,
    required this.tipoSector,
    this.especialidad,
    Map<String, dynamic>? contacto,
  }) : contacto = contacto ?? <String, dynamic>{};

  final int idPersona;
  final String nombre;
  final String email;
  final String cedulaProfesional;
  final String? especialidad;
  final String tipoSector;
  final Map<String, dynamic> contacto;

  factory TerapeutaMarketplace.fromJson(Map<String, dynamic> json) {
    return TerapeutaMarketplace(
      idPersona: json['id_persona'] as int,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      cedulaProfesional: json['cedula_profesional'] as String,
      especialidad: json['especialidad'] as String?,
      tipoSector: json['tipo_sector'] as String,
      contacto:
          (json['contacto'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }
}
