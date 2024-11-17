import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  MatchDetailScreen({required this.matchId});

  @override
  _MatchDetailScreenState createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  Map<String, dynamic>? _matchDetails;
  bool _isLoading = true;
  int _playersJoined = 0;
  int? _selectedPlayer;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails(); // Cargar detalles del partido
  }

  Future<void> _fetchMatchDetails() async {
    try {
      final response = await AuthService.sendRequest(
        url: 'https://matchapi.uim.gt/api/matches/${widget.matchId}',
        method: 'GET',
        context: context,
      );

      if (response.statusCode == 200) {
        setState(() {
          _matchDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar detalles: ${response.body}'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalles del Partido'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final location = _matchDetails?['place'] ?? 'Sin lugar';
    final dateTime = _matchDetails?['dateTime'] ?? 'Sin fecha';
    final totalPlayers = _matchDetails?['player_count'] ?? 0;

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
            Text('Fecha y Hora: $dateTime', style: TextStyle(fontSize: 16)),
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
                      builder: (context) => ChatScreen(match: _matchDetails!),
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
