import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'screens/auth_screen.dart'; // Importa la pantalla que creaste

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que las binding estén inicializadas
  await initializeDateFormatting(
      'es_ES', null); // Inicializa la localización para español
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
