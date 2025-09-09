class MockUser {
  final String name;
  final String email;
  final String password;
  final String role;

  MockUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

// Lista de usuarios de prueba
final List<MockUser> mockUsers = [
  MockUser(
    name: 'Juan Pérez',
    email: 'juan@example.com',
    password: '123456',
    role: 'Paciente',
  ),
  MockUser(
    name: 'María López',
    email: 'maria@example.com',
    password: 'password',
    role: 'Tutor',
  ),
  MockUser(
    name: 'Carlos Martínez',
    email: 'carlos@example.com',
    password: 'terapeuta123',
    role: 'Terapeuta',
  ),
];