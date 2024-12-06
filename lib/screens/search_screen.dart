import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import 'create_match_screen.dart';
import 'match_detail_screen.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _filteredMatches = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'place'; // 'place' or 'player'
  bool _hasSoccerDiscipline = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDisciplines(); // Fetch disciplines before fetching matches
  }

  Future<void> _fetchUserDisciplines() async {
    try {
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await AuthService.sendRequest(
        url: 'https://matchapi.uim.gt/api/user/$userId/disciplines/',
        method: 'GET',
        context: context,
      );

      if (response.statusCode == 200) {
        final List<dynamic> disciplines = jsonDecode(response.body);
        setState(() {
          _hasSoccerDiscipline =
              disciplines.any((discipline) => discipline['name'] == 'soccer');
        });

        if (_hasSoccerDiscipline) {
          _fetchMatches(); // Only fetch matches if the user has soccer
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar disciplinas: ${response.body}')),
        );
        setState(() {
          _isLoading = false;
        });
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

  Future<void> _fetchMatches() async {
    try {
      final response = await AuthService.sendRequest(
        url: 'https://matchapi.uim.gt/api/matches/',
        method: 'GET',
        context: context,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _matches = data.map((match) {
            return {
              'id': match['id'] ?? 0,
              'place': match['place'] ?? '',
              'dateTime': match['date_time'] ?? '',
              'playerCount': match['player_count'] ?? 0,
              'formation': match['formation'] ?? '',
            };
          }).toList();
          _filteredMatches = _matches;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar matches: ${response.body}')),
        );
        setState(() {
          _isLoading = false;
        });
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

  void _filterMatches(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_filterType == 'place') {
        _filteredMatches = _matches
            .where(
                (match) => match['place'].toLowerCase().contains(_searchQuery))
            .toList();
      } else if (_filterType == 'player') {
        _filteredMatches = _matches
            .where((match) =>
                match['playerCount'].toString().contains(_searchQuery))
            .toList();
      }
    });
  }

  void _navigateToCreateMatch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateMatchScreen()),
    );
    if (result != null) {
      _fetchMatches();
    }
  }

  void _navigateToMatchDetails(int matchId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailScreen(matchId: matchId),
      ),
    );
  }

  String formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final formattedDate =
          DateFormat('EEEE d MMM hh:mm a', 'es_ES').format(dateTime);
      return formattedDate;
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasSoccerDiscipline) {
      return Scaffold(
        appBar: AppBar(title: Text("Partidas Disponibles")),
        body: Center(
          child: Text(
            "You dont have any disciplines yet",
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Partidas Disponibles")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onChanged: _filterMatches,
                  ),
                ),
                SizedBox(width: 8.0),
                ToggleButtons(
                  isSelected: [_filterType == 'place', _filterType == 'player'],
                  onPressed: (index) {
                    setState(() {
                      _filterType = index == 0 ? 'place' : 'player';
                      _filterMatches(_searchQuery);
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Partido'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Jugadores'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredMatches.isEmpty
                    ? Center(child: Text('No hay partidas disponibles'))
                    : ListView.builder(
                        itemCount: _filteredMatches.length,
                        itemBuilder: (context, index) {
                          final match = _filteredMatches[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: GestureDetector(
                              onTap: () => _navigateToMatchDetails(match['id']),
                              child: Card(
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                color: Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _teamWidget(
                                          'Equipo A', match['playerCount']),
                                      Column(
                                        children: [
                                          Text(
                                            match['place'] ?? 'Sin lugar',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            formatDate(match['dateTime']),
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                      _teamWidget(
                                          'Equipo B', match['playerCount']),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateMatch,
        child: Icon(Icons.add),
        tooltip: 'Crear Partida',
      ),
    );
  }

  Widget _teamWidget(String teamName, int playerCount) {
    return Column(
      children: [
        Icon(Icons.shield, size: 48.0, color: Colors.black54),
        SizedBox(height: 8.0),
        Text(
          teamName,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.0),
        Text(
          '$playerCount/7',
          style: TextStyle(fontSize: 12.0, color: Colors.black54),
        ),
      ],
    );
  }
}
