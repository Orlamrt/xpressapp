import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressapp/Controllers/controller.dart';

class CodeVer extends StatefulWidget {
  const CodeVer({super.key});

  @override
  _CodeVerState createState() => _CodeVerState();
}

class _CodeVerState extends State<CodeVer> {
  final controller = Get.find<ControllerTeach>();

  @override
  void initState() {
    super.initState();
    // Fetch tasks when the widget is initialized
    controller.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Puedes agregar lógica aquí si es necesario
        return false; // Retornar false previene que se regrese a la pantalla anterior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tareas Pendientes'),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF2DCD8),
          titleTextStyle: const TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ), // Esto elimina la flecha de regreso en el AppBar
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Obx(() {
                if (controller.tasks.isEmpty) {
                  return const Text('No hay tareas pendientes.');
                } else {
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2DCD8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: controller.tasks.length,
                        itemBuilder: (context, index) {
                          var task = controller.tasks[index];
                          bool isCompleted =
                              task['is_completed'] ==
                              'true'; // Verifica si la tarea está completada
                          bool isNotCompleted =
                              task['is_not_completed'] ==
                              'true'; // Verifica si la tarea no está completada

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xDDD96C94),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(task['task_name']!),
                              subtitle: Text(task['task_description']!),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Realizada'),
                                      Checkbox(
                                        value: isCompleted,
                                        onChanged: (bool? value) {
                                          // Actualiza el estado de la tarea
                                          setState(() {
                                            task['is_completed'] = value == true
                                                ? 'true'
                                                : 'false';
                                            // Llama a un método en el controlador para actualizar el backend
                                            // controller.updateTaskStatus(task);

                                            //  Notificación si la tarea se completa
                                            if (value == true) {
                                              Get.find<ControllerTeach>()
                                                  .notificationService
                                                  .showTaskCompletionNotification(
                                                    task['task_name']!,
                                                  );
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children: [
                                      const Text('No Realizada'),
                                      Checkbox(
                                        value: isNotCompleted,
                                        onChanged: (bool? value) {
                                          // Actualiza el estado de la tarea
                                          setState(() {
                                            task['is_not_completed'] =
                                                value == true
                                                ? 'true'
                                                : 'false';
                                            // Llama a un método en el controlador para actualizar el backend
                                            // controller.updateTaskStatus(task);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
