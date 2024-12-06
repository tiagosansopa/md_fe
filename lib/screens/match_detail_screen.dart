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

  final Map<int, List<List<Offset>>> _alignments = {
    5: [
      [
        Offset(0.1, 0.25),
        Offset(0.3, 0.17),
        Offset(0.3, 0.35),
        Offset(0.6, 0.17),
        Offset(0.6, 0.35)
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
        url: 'https://matchapi.uim.gt/api/matches/${widget.matchId}',
        method: 'GET',
        context: context,
      );
      if (response.statusCode == 200) {
        setState(() {
          _matchDetails = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading match details: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _fetchPlayerSlots() async {
    try {
      final response = await AuthService.sendRequest(
        url:
            'https://matchapi.uim.gt/api/player_slots/match/${widget.matchId}/',
        method: 'GET',
        context: context,
      );
      if (response.statusCode == 200) {
        setState(() {
          _playerSlots =
              List<Map<String, dynamic>>.from(jsonDecode(response.body));
          _playersJoined = _playerSlots
              .where((slot) => slot['player_username'] != null)
              .length;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading slots: ${response.body}')),
        );
      }
    } catch (error) {
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
        url: 'https://matchapi.uim.gt/api/player_slots/${_selectedSlot}/',
        method: 'PATCH',
        headers: {'Content-Type': 'application/json'},
        body: {'match': widget.matchId},
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
    final joinedPlayers =
        _playerSlots.where((slot) => slot['player_username'] != null).toList();

    if (joinedPlayers.isEmpty) {
      return Text('No players have joined yet.',
          style: TextStyle(fontSize: 16));
    }

    return ListView.builder(
      itemCount: joinedPlayers.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final player = joinedPlayers[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 10.0,
            backgroundImage: NetworkImage('https://picsum.photos/200'),
          ),
          title: Text(player['player_username'] ?? 'Unknown'),
        );
      },
    );
  }

  Widget _buildFieldMap() {
    final playerCount = _matchDetails?['player_count'] ?? 0;
    final alignment = int.tryParse(_matchDetails?['formation'] ?? '1') ?? 1;

    final alignmentsForPlayers = _alignments[playerCount] ?? [];
    final positions = alignmentsForPlayers.isNotEmpty &&
            alignment <= alignmentsForPlayers.length
        ? alignmentsForPlayers[alignment - 1]
        : [];

    return Stack(
      children: [
        Center(
          child: Image.asset('assets/soccer_field.png', fit: BoxFit.fitWidth),
        ),
        for (int i = 0; i < positions.length; i++)
          Positioned(
            top: positions[i].dy * MediaQuery.of(context).size.height * 0.8,
            left: positions[i].dx * MediaQuery.of(context).size.width * 0.8,
            child: GestureDetector(
              onTap: _playerSlots[i]['player_username'] == null
                  ? () => _selectSlot(_playerSlots[i]['id'])
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _playerSlots[i]['id'] == _selectedSlot
                      ? Colors.green
                      : (_playerSlots[i]['player_username'] != null
                          ? Colors.grey
                          : Colors.white),
                  border: Border.all(
                    color: _playerSlots[i]['id'] == _selectedSlot
                        ? Colors.greenAccent
                        : Colors.black,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.person_pin_circle,
                    size: 30,
                    color: _playerSlots[i]['player_username'] == null
                        ? Colors.black
                        : Colors.grey.shade800,
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
      body: Padding(
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
                        'Jugadores: $_playersJoined/${_matchDetails?['player_count'] ?? 0}',
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
                      ? 'Unirse al partido'
                      : 'Confirmar Posicion'),
                ),
                ElevatedButton(
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
              ],
            ),
            Expanded(child: _buildFieldMap()),
            SizedBox(height: 2),
            Text('Jugadores Unidos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildPlayerList(),
          ],
        ),
      ),
    );
  }
}
