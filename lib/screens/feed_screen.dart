import 'package:flutter/material.dart';
import 'dart:convert'; // Para jsonDecode
import '../services/auth_service.dart'; // Ruta relativa a AuthService
import 'create_match_screen.dart';
import 'match_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _fetchMatches(); // Carga los matches al iniciar
  }

  Future<void> _fetchMatches() async {
    try {
      final response = await AuthService.sendRequest(
        url: 'https://matchapi.uim.gt/api/matches/',
        method: 'GET',
        context: context, // Para manejar errores de autenticación
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          // Mapear datos y manejar valores nulos
          _matches = data.map((match) {
            return {
              'id': match['id'] ?? 0,
              'place': match['place'] ?? '',
              'dateTime': match['date_time'] ?? '',
              'playerCount': match['player_count'] ?? 0,
              'formation': match['formation'] ?? '',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar los matches: ${response.body}')),
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

  void _navigateToCreateMatch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateMatchScreen()),
    );
    if (result != null) {
      // setState(() {
      //   _matches.add(result);
      // });
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

  // Función para formatear la fecha
  String formatDate(String dateTimeString) {
    try {
      final dateTime =
          DateTime.parse(dateTimeString); // Convierte el string a DateTime
      final formattedDate =
          DateFormat('EEEE d MMM hh:mm a', 'es_ES').format(dateTime);
      return formattedDate;
    } catch (e) {
      print('Error al formatear la fecha: $e'); // Imprime el error
      return 'Fecha inválida'; // Si hay un error en el formato
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator()) // Indicador de carga
                : _matches.isEmpty
                    ? Center(child: Text('No hay partidas disponibles'))
                    : ListView.builder(
                        itemCount: _matches.length,
                        itemBuilder: (context, index) {
                          final match = _matches[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              elevation: 4.0, // Sombra del Card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                title: Text(
                                  match['place'] ?? 'Sin lugar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                subtitle: Text(
                                  '${formatDate(match['dateTime'])} - Jugadores: ${match['playerCount']}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () =>
                                    _navigateToMatchDetails(match['id']),
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
}
