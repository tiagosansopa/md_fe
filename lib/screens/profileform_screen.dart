import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class ProfileFormScreen extends StatefulWidget {
  @override
  _ProfileFormScreenState createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _firstName = '';
  String _lastName = '';
  String _nickname = '';
  String _dateOfBirth = '';
  String _gender = 'Masculino';
  double? _height;
  String _heightUnit = 'cm';
  double? _weight;
  String _weightUnit = 'kg';
  String _country = '';
  String _disability = 'none';

  int? _userId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _pickDate() async {
    DateTime initialDate = _selectedDate ?? DateTime(1990, 1, 1);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateOfBirth =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        _userId = userData['id'];
        _firstName = userData['first_name'] ?? '';
        _lastName = userData['last_name'] ?? '';
        _nickname = userData['nickname'] ?? '';
        _dateOfBirth = userData['date_of_birth'] ?? '1990-01-01';
        _selectedDate = DateTime.tryParse(_dateOfBirth);
        _gender = userData['gender'] == 'M'
            ? 'Masculino'
            : userData['gender'] == 'F'
                ? 'Femenino'
                : 'Otro';
        _height = userData['height'];
        _heightUnit = userData['height_unit'] ?? 'cm';
        _weight = userData['weight'];
        _weightUnit = userData['weight_unit'] ?? 'kg';
        _country = userData['country'] ?? '';
        _disability = userData['disability'] ?? 'none';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userData = {
        'first_name': _firstName,
        'last_name': _lastName,
        'nickname': _nickname,
        'date_of_birth': _dateOfBirth,
        'gender': _gender == 'Masculino'
            ? 'M'
            : _gender == 'Femenino'
                ? 'F'
                : 'O',
        'height': _height,
        'height_unit': _heightUnit,
        'weight': _weight,
        'weight_unit': _weightUnit,
        'country': _country,
        'disability': _disability,
      };

      try {
        final response = await AuthService.sendRequest(
          url: 'https://matchapi.uim.gt/api/users/$_userId/',
          method: 'PATCH',
          body: userData,
          headers: {'Content-Type': 'application/json'},
          context: context,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cambios guardados exitosamente')),
          );

          await AuthService.fetchUserData(context);
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al guardar cambios: ${response.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre
              TextFormField(
                initialValue: _firstName,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su nombre';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value!,
              ),
              SizedBox(height: 10),

              // Apellido
              TextFormField(
                initialValue: _lastName,
                decoration: InputDecoration(labelText: 'Apellido'),
                onSaved: (value) => _lastName = value!,
              ),
              SizedBox(height: 10),

              // Apodo
              TextFormField(
                initialValue: _nickname,
                decoration: InputDecoration(labelText: 'Apodo'),
                onSaved: (value) => _nickname = value!,
              ),
              SizedBox(height: 10),

              // Cumpleaños
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Cumpleaños'),
                    controller: TextEditingController(
                      text: _selectedDate == null
                          ? ''
                          : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Género
              DropdownButtonFormField(
                value: _gender,
                decoration: InputDecoration(labelText: 'Género'),
                items: ['Masculino', 'Femenino', 'Otro']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  _gender = value as String;
                },
              ),
              SizedBox(height: 10),

              // Altura
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _height?.toString(),
                      decoration:
                          InputDecoration(labelText: 'Altura ($_heightUnit)'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) =>
                          _height = double.tryParse(value ?? ''),
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _heightUnit,
                    items: ['cm', 'ft']
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _heightUnit = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Peso
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _weight?.toString(),
                      decoration:
                          InputDecoration(labelText: 'Peso ($_weightUnit)'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) =>
                          _weight = double.tryParse(value ?? ''),
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _weightUnit,
                    items: ['kg', 'lb']
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _weightUnit = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),

              // País
              DropdownButtonFormField(
                value: _country,
                decoration: InputDecoration(labelText: 'País'),
                items: ['', 'Guatemala', 'USA', 'Canada', 'Mexico']
                    .map((country) => DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        ))
                    .toList(),
                onChanged: (value) {
                  _country = value as String;
                },
              ),
              SizedBox(height: 10),

              // Incapacidad
              DropdownButtonFormField(
                value: _disability,
                decoration: InputDecoration(labelText: 'Incapacidad'),
                items: ['none', 'sight_impaired', 'asthma']
                    .map((disability) => DropdownMenuItem(
                          value: disability,
                          child: Text(disability),
                        ))
                    .toList(),
                onChanged: (value) {
                  _disability = value as String;
                },
              ),
              SizedBox(height: 20),

              // Botón para guardar cambios
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  minimumSize: Size.fromHeight(50),
                ),
                onPressed: _saveChanges,
                child: Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
