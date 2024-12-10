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
  List<Map<String, dynamic>> _playerSlots = [];
  bool _isLoading = true;
  int _playersJoined = 0;
  int? _selectedSlot;
  int _activeTeam = 1; // Tracks the active team (1 or 2)

  final Map<int, List<List<Offset>>> _alignments = {
    5: [
      [
        Offset(0.3, 1.25),
        Offset(1.3, 0.67),
        Offset(1.3, 1.85),
        Offset(2.6, 0.67),
        Offset(2.6, 1.85)
      ],
      [
        Offset(0.1, 0.3),
        Offset(0.25, 0.2),
        Offset(0.25, 0.4),
        Offset(0.4, 0.3),
        Offset(0.6, 0.3)
      ],
      [
        Offset(0.1, 0.2),
        Offset(0.3, 0.2),
        Offset(0.45, 0.1),
        Offset(0.45, 0.3),
        Offset(0.65, 0.2)
      ],
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
      ],
      [
        Offset(0.1, 0.2),
        Offset(0.2, 0.1),
        Offset(0.2, 0.2),
        Offset(0.2, 0.3),
        Offset(0.45, 0.15),
        Offset(0.45, 0.25),
        Offset(0.7, 0.2)
      ],
      [
        Offset(0.1, 0.2),
        Offset(0.2, 0.2),
        Offset(0.45, 0.1),
        Offset(0.45, 0.2),
        Offset(0.45, 0.3),
        Offset(0.7, 0.15),
        Offset(0.7, 0.25)
      ],
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
    _fetchPlayerSlots();
  }

  Future<void> _fetchMatchDetails() async {
    try {
      final response = await AuthService.sendRequest(
        url: 'http://localhost:8000/api/matches/${widget.matchId}',
        method: 'GET',
        context: context,
      );
      if (response.statusCode == 200) {
        setState(() {
          _matchDetails = jsonDecode(response.body);
        });
      } else {
        print('Error:${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading match details: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _fetchPlayerSlots() async {
    try {
      final response = await AuthService.sendRequest(
        url: 'http://localhost:8000/api/player_slots/match/${widget.matchId}/',
        method: 'GET',
        context: context,
      );
      if (response.statusCode == 200) {
        final slots =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        setState(() {
          _playerSlots = slots;
          final teamA = slots.where(
              (slot) => slot['team'] == 1 && slot['player_username'] != null);
          final teamB = slots.where(
              (slot) => slot['team'] == 2 && slot['player_username'] != null);
          _playersJoined = teamA.length + teamB.length;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading slots: ${response.body}')),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _selectSlot(int slotId) async {
    setState(() {
      _selectedSlot = slotId;
    });
  }

  Future<void> _assignPlayerToSlot() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a slot first!')),
      );
      return;
    }

    try {
      final response = await AuthService.sendRequest(
        url: 'http://localhost:8000/api/player_slots/$_selectedSlot/',
        method: 'PATCH',
        headers: {'Content-Type': 'application/json'},
        body: {
          'match': widget.matchId,
          'team': _activeTeam,
        },
        context: context,
      );

      if (response.statusCode == 200) {
        setState(() {
          _selectedSlot = null;
          _fetchPlayerSlots();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully joined the match!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining match: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Widget _buildPlayerList() {
    final teamAPlayers = _playerSlots
        .where((slot) => slot['team'] == 1 && slot['player_username'] != null)
        .toList();
    final teamBPlayers = _playerSlots
        .where((slot) => slot['team'] == 2 && slot['player_username'] != null)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Equipo A:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        teamAPlayers.isEmpty
            ? Text('No Hay jugadores unidos', style: TextStyle(fontSize: 14))
            : ListView.builder(
                itemCount: teamAPlayers.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final player = teamAPlayers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 10.0,
                      backgroundImage:
                          NetworkImage('https://picsum.photos/200'),
                    ),
                    title: Text(player['player_username'] ?? 'Unknown'),
                  );
                },
              ),
        SizedBox(height: 8),
        Text('Equipo B:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        teamBPlayers.isEmpty
            ? Text('No Hay jugadores unidos aun',
                style: TextStyle(fontSize: 14))
            : ListView.builder(
                itemCount: teamBPlayers.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final player = teamBPlayers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 10.0,
                      backgroundImage:
                          NetworkImage('https://picsum.photos/200'),
                    ),
                    title: Text(player['player_username'] ?? 'Unknown'),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildFieldMap() {
    final activeTeamSlots =
        _playerSlots.where((slot) => slot['team'] == _activeTeam).toList();
    final playerCount = activeTeamSlots.length;

    final alignmentIndex =
        int.tryParse(_matchDetails?['formation'] ?? '1') ?? 1;

    final alignmentsForPlayers = _alignments[playerCount] ?? [];
    final positions = alignmentsForPlayers.isNotEmpty &&
            alignmentIndex <= alignmentsForPlayers.length
        ? alignmentsForPlayers[alignmentIndex - 1]
        : [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _activeTeam = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _activeTeam == 1 ? Colors.blue : Colors.grey.shade300,
              ),
              child: Text('Equipo A'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _activeTeam = 2;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _activeTeam == 2 ? Colors.red : Colors.grey.shade300,
              ),
              child: Text('Equipo B'),
            ),
          ],
        ),
        SizedBox(height: 10),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/soccer_field.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    for (int i = 0; i < positions.length; i++)
                      Positioned(
                        top: positions[i].dy * 100,
                        left: positions[i].dx * 100,
                        child: GestureDetector(
                          onTap: activeTeamSlots.length > i &&
                                  activeTeamSlots[i]['player_username'] == null
                              ? () => _selectSlot(activeTeamSlots[i]['id'])
                              : null,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeTeamSlots.length > i &&
                                      activeTeamSlots[i]['id'] == _selectedSlot
                                  ? Colors.green
                                  : (activeTeamSlots.length > i &&
                                          activeTeamSlots[i]
                                                  ['player_username'] !=
                                              null
                                      ? Colors.grey
                                      : Colors.white),
                              border: Border.all(
                                color: activeTeamSlots.length > i &&
                                        activeTeamSlots[i]['id'] ==
                                            _selectedSlot
                                    ? Colors.greenAccent
                                    : Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: activeTeamSlots.length > i &&
                                      activeTeamSlots[i]['player_username'] ==
                                          null
                                  ? Colors.black
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Detalles')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Detalles')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lugar: ${_matchDetails?['place'] ?? 'Unknown'}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                          'Fecha & Hora: ${DateFormat('EEE, MMM d yyyy h:mm a').format(DateTime.parse(_matchDetails?['date_time'] ?? DateTime.now().toIso8601String()))}',
                          style: TextStyle(fontSize: 16)),
                      Text(
                          'Jugadores: $_playersJoined/${_matchDetails?['player_count'] * 2 ?? 0}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _assignPlayerToSlot,
                    child: Text(_selectedSlot == null
                        ? 'Seleccione una posicion'
                        : 'Confirmar Posicion'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(match: _matchDetails!),
                        ),
                      );
                    },
                    child: Text('Chat'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildFieldMap(),
              SizedBox(height: 10),
              Text('Jugadores Unidos:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildPlayerList(),
            ],
          ),
        ),
      ),
    );
  }
}
