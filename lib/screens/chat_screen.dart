import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> match;

  ChatScreen({required this.match});

  @override
  Widget build(BuildContext context) {
    final location = match['location'];
    final dateTime = match['dateTime'];

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
                  'Fecha y Hora: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}',
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
