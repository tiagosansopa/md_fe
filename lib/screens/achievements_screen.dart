import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'tab_container_screen.dart';
import 'profileform_screen.dart';
import 'settings_screen.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _firstName = '';
  String _lastName = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        _firstName = userData['first_name'] ?? 'Nombre';
        _lastName = userData['last_name'] ?? 'Apellido';
        _username = userData['username'] ?? 'Usuario';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
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
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    backgroundImage: AssetImage('assets/thumb_photo.png'),
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileFormScreen(),
                            ),
                          );
                          if (result == true) {
                            // Si los datos fueron actualizados, recarga los datos del usuario
                            _loadUserData();
                          }
                        },
                        child: Text(
                          "$_firstName $_lastName",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        "@$_username",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            Expanded(
              child: TabContainerScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
