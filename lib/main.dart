import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:matchday_mvp/screens/auth/welcome_screen.dart';
import 'package:matchday_mvp/screens/main_screen.dart';
import 'package:matchday_mvp/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que las bindings estén inicializadas
  await initializeDateFormatting(
      'es_ES', null); // Inicializa la localización para español
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> _getInitialScreen() async {
    final tokens = await AuthService.getTokens();
    if (tokens['access'] != null && tokens['refresh'] != null) {
      // Si existen tokens en almacenamiento, verifica su validez
      final isTokenValid = await AuthService.refreshAccessToken();
      if (isTokenValid) {
        return MainScreen(); // Cambia esto por tu pantalla principal
      }
    }
    return WelcomeScreen(); // Si no hay tokens o no son válidos, muestra la pantalla de bienvenida
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar una pantalla de carga mientras se verifica
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // En caso de error, muestra la WelcomeScreen
          return MaterialApp(
            home: WelcomeScreen(),
          );
        } else {
          // Si no hay errores, muestra la pantalla determinada
          return MaterialApp(
            title: 'Matchday MVP',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: snapshot.data,
          );
        }
      },
    );
  }
}
