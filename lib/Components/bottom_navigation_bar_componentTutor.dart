import 'package:flutter/material.dart';

/// Esta clase sirve para crear un BottomNavigationBar en la aplicación
class BottomNavigationBarComponentTutor extends StatelessWidget {
  /// La función que se ejecuta al hacer tap en un ítem del BottomNavigationBar
  final void Function(int) onTap;

  /// El índice del ítem actualmente seleccionado
  final int currentIndex;

  const BottomNavigationBarComponentTutor({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xDDDFF2E7),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_outlined),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          label: 'Tareas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Citas'
          )
          ,BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_outlined),
            label: 'Asignar'),
            BottomNavigationBarItem(
              icon: Icon(Icons.screen_search_desktop_outlined),
              label: 'Terapeutas' ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                label: 'Chats')
      ],
      currentIndex: currentIndex, // Establece el ítem seleccionado
      selectedItemColor: const Color(0xfff555b7a6), // Color para el ítem seleccionado
      unselectedItemColor: const Color(0xfff464959), // Color para los ítems no seleccionados
      onTap: onTap,
    );
  }
}