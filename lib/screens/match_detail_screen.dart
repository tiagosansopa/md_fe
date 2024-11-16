import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final Map<String, dynamic> match;

  MatchDetailScreen({required this.match});

  @override
  _MatchDetailScreenState createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  int _playersJoined = 0; // Número de jugadores ya inscritos
  int? _selectedPlayer; // Posición seleccionada del jugador
  bool _isJoining = false; // Estado del botón Unirme/Enviar

  @override
  Widget build(BuildContext context) {
    final totalPlayers = widget.match['playerCount'];
    final location = widget.match['location'];
    final dateTime = widget.match['dateTime'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Partido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del partido
            Text('Lugar: $location', style: TextStyle(fontSize: 18)),
            Text(
              'Fecha y Hora: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}',
              style: TextStyle(fontSize: 16),
            ),
            Text('Jugadores: $totalPlayers', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // Mapa con alineación
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/soccer_field.png',
                      fit: BoxFit.fitWidth,
                      height: double.infinity,
                    ),
                  ),
                  for (int i = 0; i < totalPlayers; i++)
                    Positioned(
                      top: (i % 2 == 0 ? 100 : 200) + (i * 10),
                      left: 50.0 + (i * 20.0),
                      child: GestureDetector(
                        onTap: !_isJoining
                            ? null
                            : () {
                                setState(() {
                                  _selectedPlayer = i;
                                });
                              },
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: _selectedPlayer == i
                              ? Colors.green
                              : (i < _playersJoined
                                  ? Colors.red
                                  : Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Jugadores inscritos y botón unirme/enviar
            SizedBox(height: 20),
            Text(
              'Jugadores inscritos: $_playersJoined/$totalPlayers',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (!_isJoining) {
                    setState(() {
                      _isJoining = true;
                    });
                  } else if (_selectedPlayer != null) {
                    setState(() {
                      _playersJoined++;
                      _isJoining = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Posición confirmada: Jugador ${_selectedPlayer! + 1}',
                        ),
                      ),
                    );
                  }
                },
                child: Text(_isJoining
                    ? (_selectedPlayer == null ? 'Selecciona' : 'Enviar')
                    : 'Unirme'),
              ),
            ),
            SizedBox(height: 20),

            // Botón de chat
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(match: widget.match),
                    ),
                  );
                },
                child: Text('Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
