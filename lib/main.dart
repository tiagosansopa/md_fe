import 'package:flutter/material.dart';
import 'screens/auth_screen.dart'; // Importa la pantalla que creaste

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matchday MVP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthScreen(), // Aquí defines la pantalla inicial
    );
  }
}
