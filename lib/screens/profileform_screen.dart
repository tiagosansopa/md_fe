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
  String _disability = 'Ninguna';

  int? _userId;

  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        _dateOfBirth = userData['date_of_birth'] ?? '';
        _gender = userData['gender'] == 'M'
            ? 'Masculino'
            : userData['gender'] == 'F'
                ? 'Femenino'
                : 'Otro';
        // _height = userData['height'];
        // _heightUnit = userData['height_unit'] ?? 'cm';
        // _weight = userData['weight'];
        // _weightUnit = userData['weight_unit'] ?? 'kg';
        _country = userData['country'] ?? '';
        _disability = userData['disability'] ?? 'Ninguna';
      });
      print("hola ");
      print(userData['first_name']);
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

          // Actualiza datos locales
          await AuthService.fetchUserData(context);

          // Regresa a la pantalla anterior
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
        padding: const EdgeInsets.symmetric(horizontal: 55.0, vertical: 5.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                initialValue: _firstName,
                decoration: InputDecoration(
                  labelText:
                      'nombre', // Replace with 'Username' or other labels
                  labelStyle:
                      TextStyle(color: Colors.grey), // Customize label color
                  hintText: 'Enter your nombre', // Optional hint
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400), // Optional hint styling
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 15, horizontal: 20), // Adjust padding
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide:
                        BorderSide(color: Colors.grey), // Default border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.grey.shade300), // Light border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.blue, width: 2.0), // Focused border color
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value!,
              ),
              SizedBox(height: 10),

              // Apellido
              TextFormField(
                initialValue: _lastName,
                decoration: InputDecoration(
                  labelText:
                      'Apellido', // Replace with 'Username' or other labels
                  labelStyle:
                      TextStyle(color: Colors.grey), // Customize label color
                  hintText: 'Enter your apellido', // Optional hint
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400), // Optional hint styling
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 15, horizontal: 20), // Adjust padding
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide:
                        BorderSide(color: Colors.grey), // Default border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.grey.shade300), // Light border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.blue, width: 2.0), // Focused border color
                  ),
                ),
                onSaved: (value) => _lastName = value!,
              ),
              SizedBox(height: 10),

              // Apodo
              TextFormField(
                initialValue: _nickname,
                decoration: InputDecoration(
                  labelText: 'Apodo', // Replace with 'Username' or other labels
                  labelStyle:
                      TextStyle(color: Colors.grey), // Customize label color
                  hintText: 'Enter your apodo', // Optional hint
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400), // Optional hint styling
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 15, horizontal: 20), // Adjust padding
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide:
                        BorderSide(color: Colors.grey), // Default border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.grey.shade300), // Light border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    borderSide: BorderSide(
                        color: Colors.blue, width: 2.0), // Focused border color
                  ),
                ),
                onSaved: (value) => _nickname = value!,
              ),
              SizedBox(height: 10),

              // Cumpleaños
              TextFormField(
                initialValue: _dateOfBirth,
                decoration:
                    InputDecoration(labelText: 'Cumpleaños (YYYY-MM-DD)'),
                onSaved: (value) => _dateOfBirth = value!,
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
              TextFormField(
                initialValue: _height?.toString(),
                decoration: InputDecoration(labelText: 'Altura ($_heightUnit)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _height = double.tryParse(value ?? ''),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _heightUnit = _heightUnit == 'cm' ? 'cm' : 'cm';
                  });
                },
                child: Text('Cambiar unidad'),
              ),
              SizedBox(height: 10),

              // Peso
              TextFormField(
                initialValue: _weight?.toString(),
                decoration: InputDecoration(labelText: 'Peso ($_weightUnit)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _weight = double.tryParse(value ?? ''),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _weightUnit = _weightUnit == 'kg' ? 'lb' : 'kg';
                  });
                },
                child: Text('Cambiar unidad'),
              ),
              SizedBox(height: 10),

              // País
              TextFormField(
                initialValue: _country,
                decoration: InputDecoration(labelText: 'País'),
                onSaved: (value) => _country = value!,
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
                    borderRadius:
                        BorderRadius.circular(8.0), // Slightly rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 16.0), // Increase vertical size
                  minimumSize: Size.fromHeight(50), // Full-width
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
