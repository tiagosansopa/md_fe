import 'package:flutter/material.dart';
import 'package:matchday_mvp/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class ProfileFormScreen extends StatefulWidget {
  @override
  _ProfileFormScreenState createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController = TextEditingController();
  late TextEditingController _lastNameController = TextEditingController();
  late TextEditingController _nicknameController = TextEditingController();
  late TextEditingController _dateOfBirthController = TextEditingController();
  late TextEditingController _heightController = TextEditingController();
  late TextEditingController _weightController = TextEditingController();

  String _gender = 'Masculino';
  String _heightUnit = 'cm';
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController.dispose();
    _dateOfBirthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
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
        _dateOfBirthController.text =
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
        _firstNameController.text = userData['first_name'] ?? '';
        _lastNameController.text = userData['last_name'] ?? '';
        _nicknameController.text = userData['nickname'] ?? '';
        _dateOfBirthController.text = userData['date_of_birth'] ?? '1990-01-01';
        _selectedDate = DateTime.tryParse(userData['date_of_birth'] ?? '');
        _gender = userData['gender'] == 'M'
            ? 'Masculino'
            : userData['gender'] == 'F'
                ? 'Femenino'
                : 'Otro';
        _heightController.text = userData['height']?.toString() ?? '';
        _heightUnit = userData['height_unit'] ?? 'cm';
        _weightController.text = userData['weight']?.toString() ?? '';
        _weightUnit = userData['weight_unit'] ?? 'kg';
        _country = userData['country'] ?? '';
        _disability = userData['disability'] ?? 'none';
      });
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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'nickname': _nicknameController.text,
        'date_of_birth': _dateOfBirthController.text,
        'gender': _gender == 'Masculino'
            ? 'M'
            : _gender == 'Femenino'
                ? 'F'
                : 'O',
        'height': double.tryParse(_heightController.text),
        'height_unit': _heightUnit,
        'weight': double.tryParse(_weightController.text),
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
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen()), // Replace with your main screen
            (route) => false, // Remove all previous routes
          );
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
              TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration('Nombre', 'Ingrese su nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese su nombre' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration('Apellido', 'Ingrese su apellido'),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _nicknameController,
                decoration: _inputDecoration('Apodo', 'Ingrese su apodo'),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateOfBirthController,
                    decoration: _inputDecoration(
                        'Cumpleaños', 'Seleccione su fecha de nacimiento'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField(
                value: _gender,
                decoration: _inputDecoration('Género', ''),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration:
                          _inputDecoration('Altura', 'Ingrese su altura'),
                      keyboardType: TextInputType.number,
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: _inputDecoration('Peso', 'Ingrese su peso'),
                      keyboardType: TextInputType.number,
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
              DropdownButtonFormField(
                value: _country,
                decoration: _inputDecoration('País', 'Seleccione su país'),
                items: ['', 'guatemala', 'USA', 'Canada', 'Mexico']
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
              DropdownButtonFormField(
                value: _disability,
                decoration: _inputDecoration(
                    'Incapacidad', 'Seleccione su tipo de incapacidad'),
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
              ElevatedButton(
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
