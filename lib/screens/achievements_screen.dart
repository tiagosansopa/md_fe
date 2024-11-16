import 'package:flutter/material.dart';
import 'tab_container_screen.dart';
import 'profileform_screen.dart';
import 'settings_screen.dart'; // Importar la pantalla de configuración

class AchievementsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings), // Icono de configuración
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(), // Navegar a Settings
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row con avatar y nombre
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Fondo gris claro
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: AssetImage(
                        'assets/thumb_photo.png'), // Reemplaza con tu imagen
                  ),
                  SizedBox(width: 16.0),
                  GestureDetector(
                    onTap: () {
                      // Navegar a ProfileScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileFormScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Abraham Rodriguez",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),

            // Contenido principal
            Expanded(
              child: TabContainerScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
