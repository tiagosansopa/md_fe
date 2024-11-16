import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'main_screen.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas: Log In y Register
      child: Scaffold(
        appBar: AppBar(
          title: Text('Matchday MVP'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Log In'),
              Tab(text: 'Register'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LogInForm(),
            RegisterForm(),
          ],
        ),
      ),
    );
  }
}

class LogInForm extends StatefulWidget {
  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Llama al API de login
      final url = Uri.parse('https://matchapi.uim.gt/api/login/');
      try {
        final response = await http.post(
          url,
          body: {
            'username': _username,
            'password': _password,
          },
        );

        if (response.statusCode == 200) {
          // Redirige a la pantalla principal si el inicio de sesión es exitoso
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null) {
                  return 'Enter a valid user!';
                }
                return null;
              },
              onSaved: (value) {
                _username = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password!';
                }
                return null;
              },
              onSaved: (value) {
                _password = value!;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _username = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Llama al API de registro
      final url = Uri.parse('https://matchapi.uim.gt/api/register/');
      try {
        final response = await http.post(
          url,
          body: {
            'email': _email,
            'password': _password,
            'username': _username,
          },
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || !value.contains('@')) {
                  return 'Enter a valid email!';
                }
                return null;
              },
              onSaved: (value) {
                _email = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters!';
                }
                return null;
              },
              onSaved: (value) {
                _password = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a username!';
                }
                return null;
              },
              onSaved: (value) {
                _username = value!;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
