import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'feed_screen.dart';
import 'home_screen.dart';
import 'shop_screen.dart';
import 'achievements_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Start at "Home" (index 2)

  // List of screens corresponding to each icon
  final List<Widget> _screens = [
    SearchScreen(),
    FeedScreen(),
    HomeScreen(),
    ShopScreen(),
    AchievementsScreen(),
  ];

  // Handle icon tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Change selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
