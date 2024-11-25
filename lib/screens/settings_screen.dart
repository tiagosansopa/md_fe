import 'package:flutter/material.dart';
import 'package:matchday_mvp/screens/auth/welcome_screen.dart';
import 'auth_screen.dart'; // Importar la pantalla de autenticación

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  (route) => false, // Remueve todas las rutas anteriores
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
