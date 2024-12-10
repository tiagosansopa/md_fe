import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import 'main_screen.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas: Log In y Register
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 50), // Espacio superior
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(height: 30),

              // Tabs y contenido centrado
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: 'Log In'),
                        Tab(text: 'Register'),
                      ],
                    ),
                    SizedBox(height: 20), // Espacio entre tabs y formularios
                    Expanded(
                      child: TabBarView(
                        children: [
                          LogInForm(),
                          RegisterForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de redes sociales con espacio inferior
              Column(
                children: [
                  Text('o continuar con'),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para login con Facebook
                        },
                        icon: Icon(Icons.facebook),
                        label: Text('Facebook'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Facebook color
                        ),
                      ),
                      SizedBox(width: 10.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Lógica para login con Google
                        },
                        icon: Icon(Icons.g_mobiledata),
                        label: Text('Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Google color
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30), // Margen inferior para los botones
            ],
          ),
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
      final url = Uri.parse('http://localhost:8000/api/auth/login/');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _username,
            'password': _password,
          }),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Username'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a valid username!';
                }
                return null;
              },
              onSaved: (value) {
                _username = value!;
              },
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 32),
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
      final url = Uri.parse('http://localhost:8000/api/auth/register/');
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
          mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(height: 16),
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
            SizedBox(height: 16),
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
            SizedBox(height: 32),
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
