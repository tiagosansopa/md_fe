import 'dart:convert';

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _password = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await AuthService.sendOpenRequest(
          url: 'https://matchapi.uim.gt/api/auth/login/',
          headers: {'Content-Type': 'application/json'},
          method: 'POST',
          body: {'username': _name, 'password': _password},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          await AuthService.saveTokens(data['access'], data['refresh']);

          // Obtiene los datos del usuario después del login
          await AuthService.fetchUserData(context);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          print(response.statusCode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.body}')),
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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 50,
                  width: 50,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Log In Now',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              TextFormField(
                decoration: InputDecoration(
                  labelText:
                      'Username', // Replace with 'Username' or other labels
                  labelStyle:
                      TextStyle(color: Colors.grey), // Customize label color
                  hintText: 'Enter your username', // Optional hint
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
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null) {
                    return 'Enter a valid username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText:
                      'Password', // Replace with 'Username' or other labels
                  labelStyle:
                      TextStyle(color: Colors.grey), // Customize label color
                  hintText: 'Enter your Password', // Optional hint
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
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Slightly rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 16.0), // Increase vertical size
                  minimumSize: Size.fromHeight(50), // Full-width
                ),
                child: Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
