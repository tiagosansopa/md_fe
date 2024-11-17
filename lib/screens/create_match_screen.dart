import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CreateMatchScreen extends StatefulWidget {
  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  String _location = '';
  DateTime _selectedDateTime = DateTime.now();
  int _playerCount = 11;
  int _alignment = 1; // 1, 2 o 3
  List<int> _playerPositions = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _updatePlayerPositions(); // Inicializa posiciones
  }

  void _updatePlayerPositions() {
    setState(() {
      _playerPositions = List.generate(_playerCount, (index) => index + 1);
    });
  }

  void _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _createMatch() async {
    setState(() {
      _isSubmitting = true;
    });

    final matchData = {
      "place": _location,
      "date_time": _selectedDateTime.toIso8601String(),
      "player_count": _playerCount,
      "formation": _alignment.toString(),
    };

    try {
      final response = await AuthService.sendRequest(
        url: 'https://matchapi.uim.gt/api/matches/',
        method: 'POST',
        body: matchData,
        headers: {
          'Content-Type': 'application/json', // Especifica el tipo de contenido
        },
        context: context, // Para manejar errores de autenticación
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Partido creado exitosamente')),
        );
        Navigator.pop(context, matchData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al crear el partido: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Partido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lugar
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Lugar'),
                    onChanged: (value) {
                      _location = value;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.location_pin),
                  onPressed: () {
                    // Agregar lógica de coordenadas más adelante
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Fecha y hora
            Row(
              children: [
                Text(
                  'Fecha y Hora:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: Text(
                    '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour}:${_selectedDateTime.minute}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Cantidad de jugadores
            Row(
              children: [
                Text(
                  'Cantidad de jugadores:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                DropdownButton<int>(
                  value: _playerCount,
                  items: [5, 7, 9, 11]
                      .map((count) => DropdownMenuItem<int>(
                            value: count,
                            child: Text('$count'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _playerCount = value!;
                      _updatePlayerPositions();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // Alineación
            Text(
              'Alineación:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [1, 2, 3].map((alignment) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _alignment == alignment ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _alignment = alignment;
                    });
                  },
                  child: Text('$alignment'),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Campo de fútbol
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
                  for (int i = 0; i < _playerCount; i++)
                    Positioned(
                      top: (i % 2 == 0 ? 100 : 200) +
                          (_alignment == 1
                              ? 10
                              : _alignment == 2
                                  ? 20
                                  : 30),
                      left: 50.0 + (i * 20.0),
                      child: Icon(Icons.person, size: 24, color: Colors.blue),
                    ),
                ],
              ),
            ),

            // Botón Crear
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _createMatch,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
