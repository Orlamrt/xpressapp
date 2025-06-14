import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final Map<DateTime, List<String>> _events;
  @override
  void initState() {
    super.initState();
    _events = _loadEvents();
  }

  Map<DateTime, List<String>> _loadEvents() {
    return {
      DateTime.now().add(const Duration(days: 2)): [
        'Cita de seguimiento a las 11:00 AM'
      ],
    };
  }

  List<String> _getUpcomingEvents() {
    final today = DateTime.now();
    return _events.entries
        .where((entry) => entry.key.isAfter(today))
        .map((entry) => entry.value)
        .expand((eventList) => eventList)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendario de Citas'),
          backgroundColor: const Color(0xFFF2DCD8),
          titleTextStyle: const TextStyle(
            fontSize: 32,
            color: Color(0xDDD96C94),
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFFF2DCD8),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildCalendarCard(),
              const SizedBox(height: 25),
              _buildEventsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: const Color(0xDDD96C94).withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            // Remueve decoración del día seleccionado
            selectedDecoration: const BoxDecoration(
              color: Colors.transparent,
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            formatButtonVisible: false,
            leftChevronIcon:
                const Icon(Icons.chevron_left, color: Color(0xDDD96C94)),
            rightChevronIcon:
                const Icon(Icons.chevron_right, color: Color(0xDDD96C94)),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle:
                TextStyle(color: const Color(0xDDD96C94).withOpacity(0.8)),
            weekendStyle:
                TextStyle(color: const Color(0xDDD96C94).withOpacity(0.6)),
          ),
          onDaySelected: null,
          selectedDayPredicate: (day) => false,
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Expanded(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Próximas Citas',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xDDD96C94),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _getUpcomingEvents().isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _getUpcomingEvents().length,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xDDD96C94).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xDDD96C94).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event,
                                  color: Color(0xDDD96C94), size: 24),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  _getUpcomingEvents()[index],
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No hay citas programadas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
