import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> match;

  ChatScreen({required this.match});

  @override
  Widget build(BuildContext context) {
    final location = match['location'] ?? 'Sin lugar';
    final dateTimeString = match['dateTime'];
    DateTime? dateTime;

    // Parsear la fecha de tipo String a DateTime
    if (dateTimeString != null) {
      try {
        dateTime = DateTime.parse(dateTimeString);
      } catch (e) {
        print('Error al parsear la fecha: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat del Partido'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Datos del partido en la parte superior
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lugar: $location', style: TextStyle(fontSize: 18)),
                Text(
                  dateTime != null
                      ? 'Fecha y Hora: ${DateFormat.yMMMMEEEEd('es_ES').add_Hm().format(dateTime)}'
                      : 'Fecha y Hora: Sin fecha',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Chat del partido específico',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
