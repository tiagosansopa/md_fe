import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CreateMatchScreen extends StatefulWidget {
  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  String _location = '';
  DateTime _selectedDateTime = DateTime.now();
  int _playerCount = 5;
  int _alignment = 1; // 1, 2, or 3
  bool _isSubmitting = false;

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
          'Content-Type': 'application/json',
        },
        context: context,
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
    final alignmentsForPlayers = _alignments[_playerCount] ??
        []; // Fetch alignments for current player count
    final positions = alignmentsForPlayers.isNotEmpty
        ? alignmentsForPlayers[_alignment - 1]
        : [];

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
                  onPressed: () {},
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
                  items: [5, 7, 11]
                      .map((count) => DropdownMenuItem<int>(
                            value: count,
                            child: Text('$count'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _playerCount = value!;
                      _alignment =
                          1; // Reset to first alignment when player count changes
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
                  for (int i = 0; i < positions.length; i++)
                    Positioned(
                      top: positions[i].dy * MediaQuery.of(context).size.height,
                      left: positions[i].dx * MediaQuery.of(context).size.width,
                      child: Icon(Icons.person_pin_rounded,
                          size: 30, color: Colors.white),
                      //     Text(
                      //   '${i + 1}', // Display the index starting from 1
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.white, // Match the icon color
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // )
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
