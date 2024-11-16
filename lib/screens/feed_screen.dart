import 'package:flutter/material.dart';
import 'create_match_screen.dart';
import 'match_detail_screen.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> _matches = [];

  void _navigateToCreateMatch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateMatchScreen()),
    );
    if (result != null) {
      setState(() {
        _matches.add(result);
      });
    }
  }

  void _navigateToMatchDetails(Map<String, dynamic> match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailScreen(match: match),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _navigateToCreateMatch,
            child: Text('Crear Partida'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return ListTile(
                  title: Text(match['location']),
                  subtitle: Text(
                      '${match['dateTime']} - Jugadores: ${match['playerCount']}'),
                  onTap: () => _navigateToMatchDetails(match),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
