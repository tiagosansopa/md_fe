import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AddDisciplineScreen extends StatefulWidget {
  final int userId;
  final VoidCallback onDone;

  AddDisciplineScreen({required this.userId, required this.onDone});

  @override
  _AddDisciplineScreenState createState() => _AddDisciplineScreenState();
}

class _AddDisciplineScreenState extends State<AddDisciplineScreen> {
  String? _selectedDiscipline;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic> _userDisciplines = {};
  List<String> _availableDisciplines = ['soccer', 'running', 'gym', 'tennis'];

  double _pace = 3.0,
      _defending = 3.0,
      _shooting = 3.0,
      _passing = 3.0,
      _dribbling = 3.0;
  double _arm = 3.0,
      _chest = 3.0,
      _back = 3.0,
      _leg = 3.0,
      _strength = 3.0,
      _resistance = 3.0;
  double _maxDistance = 0.0, _paceAvg = 0.0;
  int _level = 0;
  String? _dominantFoot, _forehand, _backhand;

  @override
  void initState() {
    super.initState();
    _fetchUserDisciplines();
  }

  Future<void> _fetchUserDisciplines() async {
    try {
      final response = await AuthService.sendRequest(
        url: 'https://matchapi.uim.gt/api/user/${widget.userId}/disciplines/',
        method: 'GET',
        context: context,
      );

      if (response.statusCode == 200) {
        setState(() {
          final List<dynamic> disciplines = jsonDecode(response.body);
          _userDisciplines = {
            for (var d in disciplines) d['name']: d,
          };
          _availableDisciplines
              .removeWhere((d) => _userDisciplines.containsKey(d));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching disciplines: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> _saveDiscipline() async {
    if (_formKey.currentState!.validate() && _selectedDiscipline != null) {
      Map<String, dynamic> disciplineData = {"name": _selectedDiscipline};

      // Add discipline-specific fields
      if (_selectedDiscipline == 'soccer') {
        disciplineData.addAll({
          "favorite_position": _controllers['favorite_position']?.text ?? '',
          "dominant_foot": _dominantFoot ?? '',
          "pace": _pace.round(),
          "defending": _defending.round(),
          "shooting": _shooting.round(),
          "passing": _passing.round(),
          "dribbling": _dribbling.round(),
        });
      } else if (_selectedDiscipline == 'gym') {
        disciplineData.addAll({
          "arm": _arm.round(),
          "chest": _chest.round(),
          "back": _back.round(),
          "leg": _leg.round(),
          "strength": _strength.round(),
          "resistance": _resistance.round(),
        });
      } else if (_selectedDiscipline == 'running') {
        disciplineData.addAll({
          "max_distance":
              double.tryParse(_controllers['max_distance']?.text ?? '0') ?? 0.0,
          "pace_avg":
              double.tryParse(_controllers['pace_avg']?.text ?? '0') ?? 0.0,
          "level": _level,
        });
      } else if (_selectedDiscipline == 'tennis') {
        disciplineData.addAll({
          "forehand": _forehand ?? '',
          "backhand": _backhand ?? '',
          "tennis_level": _level,
        });
      }

      // Submit discipline data
      try {
        final response = await AuthService.sendRequest(
          url: 'https://matchapi.uim.gt/api/user/${widget.userId}/disciplines/',
          method: 'POST',
          body: disciplineData,
          headers: {'Content-Type': 'application/json'},
          context: context,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Disciplina creada exitosamente')),
          );
          widget.onDone();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al crear disciplina: ${response.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, String hintText) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
      ),
    );
  }

  Widget _buildTextField(String key, String label, String hint) {
    _controllers.putIfAbsent(key, () => TextEditingController());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: _inputDecoration(label, hint),
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _buildDropdown(String key, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: key == 'forehand'
            ? _forehand
            : key == 'backhand'
                ? _backhand
                : _dominantFoot,
        decoration: _inputDecoration(label, ''),
        items: ['left', 'right']
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.capitalize()),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            if (key == 'forehand') {
              _forehand = value;
            } else if (key == 'backhand') {
              _backhand = value;
            } else {
              _dominantFoot = value;
            }
          });
        },
      ),
    );
  }

  Widget _buildSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            value: value,
            min: 0,
            max: 5,
            divisions: 5,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpecificFields() {
    if (_selectedDiscipline == 'soccer') {
      return [
        _buildTextField(
            'favorite_position', 'Posición Favorita', 'Ingresa tu posición'),
        _buildDropdown('dominant_foot', 'Pie Hábil'),
        _buildSlider('Pace', _pace, (v) => setState(() => _pace = v)),
        _buildSlider(
            'Defending', _defending, (v) => setState(() => _defending = v)),
        _buildSlider(
            'Shooting', _shooting, (v) => setState(() => _shooting = v)),
        _buildSlider('Passing', _passing, (v) => setState(() => _passing = v)),
        _buildSlider(
            'Dribbling', _dribbling, (v) => setState(() => _dribbling = v)),
      ];
    } else if (_selectedDiscipline == 'gym') {
      return [
        _buildSlider('Arm', _arm, (v) => setState(() => _arm = v)),
        _buildSlider('Chest', _chest, (v) => setState(() => _chest = v)),
        _buildSlider('Back', _back, (v) => setState(() => _back = v)),
        _buildSlider('Leg', _leg, (v) => setState(() => _leg = v)),
        _buildSlider(
            'Strength', _strength, (v) => setState(() => _strength = v)),
        _buildSlider(
            'Resistance', _resistance, (v) => setState(() => _resistance = v)),
      ];
    } else if (_selectedDiscipline == 'running') {
      return [
        _buildTextField('max_distance', 'Max Distance', 'Enter max distance'),
        _buildTextField('pace_avg', 'Pace Avg', 'Enter avg pace'),
        _buildSlider('Level', _level.toDouble(),
            (v) => setState(() => _level = v.toInt())),
      ];
    } else if (_selectedDiscipline == 'tennis') {
      return [
        _buildDropdown('forehand', 'Forehand'),
        _buildDropdown('backhand', 'Backhand'),
        _buildSlider('Tennis Level', _level.toDouble(),
            (v) => setState(() => _level = v.toInt())),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Disciplina')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDiscipline,
                decoration: _inputDecoration('Seleccionar Disciplina', ''),
                items: _availableDisciplines.map((discipline) {
                  final displayName = {
                    'soccer': 'Fútbol',
                    'running': 'Correr',
                    'gym': 'Gimnasio',
                    'tennis': 'Tennis',
                  }[discipline];
                  return DropdownMenuItem(
                      value: discipline,
                      child: Text(displayName ?? discipline));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedDiscipline = value),
              ),
              if (_selectedDiscipline != null) ..._buildSpecificFields(),
              SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _saveDiscipline, child: Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
