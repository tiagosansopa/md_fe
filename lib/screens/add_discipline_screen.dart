import 'package:flutter/material.dart';

class AddDisciplineScreen extends StatefulWidget {
  final Function(
    String favoritePosition,
    String preferredFoot,
    String leaderNumber,
    String clutchNumber,
    double pace,
    double defending,
    double shooting,
    double passing,
    double dribbling,
  ) onDone;

  AddDisciplineScreen({required this.onDone});

  @override
  _AddDisciplineScreenState createState() => _AddDisciplineScreenState();
}

class _AddDisciplineScreenState extends State<AddDisciplineScreen> {
  String? _selectedDiscipline;

  // Controladores para el formulario de fútbol
  final _positionController = TextEditingController();
  final _footController = TextEditingController();
  final _leaderNumberController = TextEditingController();
  final _clutchNumberController = TextEditingController();
  double _pace = 3.0;
  double _defending = 3.0;
  double _shooting = 3.0;
  double _passing = 3.0;
  double _dribbling = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Disciplina'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de disciplina
            DropdownButtonFormField<String>(
              value: _selectedDiscipline,
              decoration: InputDecoration(labelText: 'Seleccionar Disciplina'),
              items: ['Fútbol', 'Correr', 'Gimnasio']
                  .map((discipline) => DropdownMenuItem(
                        value: discipline,
                        child: Text(discipline),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDiscipline = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Formulario específico para fútbol
            if (_selectedDiscipline == 'Fútbol') ...[
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Posición Favorita'),
              ),
              TextFormField(
                controller: _footController,
                decoration: InputDecoration(labelText: 'Pie Hábil'),
              ),
              TextFormField(
                controller: _leaderNumberController,
                decoration: InputDecoration(labelText: 'Número Leader'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _clutchNumberController,
                decoration: InputDecoration(labelText: 'Número Clutch'),
                keyboardType: TextInputType.number,
              ),
              _buildSlider('Pace', _pace, (value) {
                setState(() {
                  _pace = value;
                });
              }),
              _buildSlider('Defending', _defending, (value) {
                setState(() {
                  _defending = value;
                });
              }),
              _buildSlider('Shooting', _shooting, (value) {
                setState(() {
                  _shooting = value;
                });
              }),
              _buildSlider('Passing', _passing, (value) {
                setState(() {
                  _passing = value;
                });
              }),
              _buildSlider('Dribbling', _dribbling, (value) {
                setState(() {
                  _dribbling = value;
                });
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Llama a onDone con los datos ingresados en el formulario
                  widget.onDone(
                    _positionController.text,
                    _footController.text,
                    _leaderNumberController.text,
                    _clutchNumberController.text,
                    _pace,
                    _defending,
                    _shooting,
                    _passing,
                    _dribbling,
                  );
                  Navigator.pop(context, 'soccer');
                },
                child: Text('Done'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget para crear sliders personalizados
  Widget _buildSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
