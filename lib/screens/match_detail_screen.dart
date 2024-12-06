import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
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
  bool _showTeamA = true; // Toggle between Team A and Team B

  final Map<int, List<List<Offset>>> _alignments = {
    5: [
      [
        Offset(0.1, 0.2),
        Offset(0.3, 0.15),
        Offset(0.3, 0.3),
        Offset(0.6, 0.15),
        Offset(0.6, 0.3)
      ], // Alignment 1
      [
        Offset(0.1, 0.2),
        Offset(0.25, 0.15),
        Offset(0.25, 0.3),
        Offset(0.35, 0.2),
        Offset(0.6, 0.2)
      ], // Alignment 2
      [
        Offset(0.1, 0.2),
        Offset(0.3, 0.2),
        Offset(0.45, 0.15),
        Offset(0.45, 0.3),
        Offset(0.6, 0.2)
      ], // Alignment 3
    ],
    7: [
      [
        Offset(0.1, 0.2),
        Offset(0.2, 0.15),
        Offset(0.2, 0.25),
        Offset(0.45, 0.1),
        Offset(0.45, 0.2),
        Offset(0.45, 0.3),
        Offset(0.7, 0.2)
      ], // Alignment 1
      [
        Offset(0.1, 0.2),
        Offset(0.2, 0.1),
        Offset(0.2, 0.2),
        Offset(0.2, 0.3),
        Offset(0.45, 0.15),
        Offset(0.45, 0.25),
        Offset(0.7, 0.2)
      ], // Alignment 2
      [
        Offset(0.1, 0.2),
        Offset(0.2, 0.2),
        Offset(0.45, 0.1),
        Offset(0.45, 0.2),
        Offset(0.45, 0.3),
        Offset(0.7, 0.15),
        Offset(0.7, 0.25),
      ], // Alignment 3
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
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
    final playerCount = _matchDetails?['player_count'] ?? 0;
    final alignment = int.tryParse(_matchDetails?['formation'] ?? '1') ?? 1;

    // Fetch positions for current playerCount and alignment
    final alignmentsForPlayers = _alignments[playerCount] ?? [];
    final positions = alignmentsForPlayers.isNotEmpty &&
            alignment <= alignmentsForPlayers.length
        ? alignmentsForPlayers[alignment - 1]
        : [];

    if (positions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalles del Partido'),
        ),
        body: Center(
          child: Text(
            'No hay alineación disponible para esta configuración.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

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
            Text('Lugar: ${_matchDetails?['place'] ?? 'Sin lugar'}',
                style: TextStyle(fontSize: 18)),
            Text(
              'Fecha y Hora: ${DateFormat('EEEE, d MMM yyyy hh:mm a', 'es_ES').format(DateTime.parse(_matchDetails?['date_time'] ?? DateTime.now().toIso8601String()))}',
              style: TextStyle(fontSize: 16),
            ),
            Text('Jugadores: $playerCount', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // Botones para TEAM A y TEAM B
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showTeamA = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _showTeamA ? Colors.blue : Colors.grey.shade300,
                  ),
                  child: Text('TEAM A'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showTeamA = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_showTeamA ? Colors.blue : Colors.grey.shade300,
                  ),
                  child: Text('TEAM B'),
                ),
              ],
            ),
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
                  for (int i = 0; i < positions.length; i++)
                    Positioned(
                      top: positions[i].dy *
                          MediaQuery.of(context).size.height *
                          0.8, // Adjusted to fit field size
                      left: positions[i].dx *
                          MediaQuery.of(context).size.width *
                          0.8, // Adjusted to fit field size
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_pin_circle_rounded,
                            size: 30,
                            color: _showTeamA ? Colors.black : Colors.yellow,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _showTeamA ? Colors.black : Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Botón Unirme
            SizedBox(height: 20),
            Text(
              'Jugadores inscritos: $_playersJoined/$playerCount',
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
                child: Text(
                  _isJoining
                      ? (_selectedPlayer == null ? 'Selecciona' : 'Enviar')
                      : 'Unirme',
                ),
              ),
            ),
            SizedBox(height: 20),

            // Botón de Chat
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
