import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'add_discipline_screen.dart';
import 'package:image_picker/image_picker.dart';

class TabContainerScreen extends StatefulWidget {
  @override
  _TabContainerScreenState createState() => _TabContainerScreenState();
}

class _TabContainerScreenState extends State<TabContainerScreen> {
  int _selectedIndex = 0; // Start on the home tab
  Map<String, dynamic> _disciplines = {}; // User disciplines
  List<String> _availableTabs = ['home']; // Always include the home tab

  @override
  void initState() {
    super.initState();
    _fetchDisciplines(); // Fetch disciplines on init
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Handle the selected image (e.g., show it or upload it)
        print('Selected image path: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // Fetch disciplines from the API
  Future<void> _fetchDisciplines() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    try {
      final response = await AuthService.sendRequest(
        url: 'https://matchapi.uim.gt/api/user/$userId/disciplines/',
        method: 'GET',
        context: context,
      );

      if (response.statusCode == 200) {
        final List<dynamic> disciplines = jsonDecode(response.body);

        setState(() {
          // Map disciplines to a dictionary for quick access
          _disciplines = {
            for (var discipline in disciplines) discipline['name']: discipline
          };
          // Create available tabs based on disciplines
          _availableTabs = ['home', ..._disciplines.keys];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching disciplines: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  // Build content for the selected tab
  Widget _buildContent() {
    final String selectedTab = _availableTabs[_selectedIndex];

    if (selectedTab == 'home') {
      return _buildHomeTab();
    } else if (selectedTab == 'soccer') {
      return _buildSoccerTab();
    } else if (selectedTab == 'gym') {
      return _buildGymTab();
    } else if (selectedTab == 'running') {
      return _buildRunningTab();
    } else if (selectedTab == 'tennis') {
      return _buildTennisTab();
    } else {
      return Center(child: Text('Tab not supported.'));
    }
  }

  Widget _buildHomeTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 9,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: _pickImage,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.add,
              size: 40.0,
              color: Colors.grey[700],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoccerTab() {
    final soccer = _disciplines['soccer'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Favorite Position: ${soccer['favorite_position']}'),
          Text('Dominant Foot: ${soccer['dominant_foot']}'),
          Divider(thickness: 1.0, color: Colors.grey),
          _buildStarsTable({
            'Pace': soccer['pace'],
            'Defending': soccer['defending'],
            'Shooting': soccer['shooting'],
            'Passing': soccer['passing'],
            'Dribbling': soccer['dribbling'],
          }),
        ],
      ),
    );
  }

  Widget _buildGymTab() {
    final gym = _disciplines['gym'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildStarsTable({
        'Arm': gym['arm'],
        'Chest': gym['chest'],
        'Back': gym['back'],
        'Leg': gym['leg'],
        'Strength': gym['strength'],
        'Resistance': gym['resistance'],
      }),
    );
  }

  Widget _buildRunningTab() {
    final running = _disciplines['running'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Max Distance: ${running['max_distance']} km'),
          Text('Pace Avg: ${running['pace_avg']} min/km'),
          Text('Level: ${running['level']}'),
        ],
      ),
    );
  }

  Widget _buildTennisTab() {
    final tennis = _disciplines['tennis'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Forehand: ${tennis['forehand']}'),
          Text('Backhand: ${tennis['backhand']}'),
          Text('Level: ${tennis['tennis_level']}'),
        ],
      ),
    );
  }

  Widget _buildStarsTable(Map<String, int> attributes) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(120.0),
      },
      children: attributes.entries.map((entry) {
        return TableRow(
          children: [
            Text(entry.key),
            Row(
              children: List.generate(entry.value, (index) {
                return Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20.0,
                );
              }),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _navigateToAddDiscipline() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDisciplineScreen(
          userId: userId,
          onDone: () {
            _fetchDisciplines(); // Refresh disciplines after adding one
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _availableTabs.map((tabName) {
                IconData icon;
                switch (tabName) {
                  case 'home':
                    icon = Icons.home;
                    break;
                  case 'soccer':
                    icon = Icons.sports_soccer;
                    break;
                  case 'gym':
                    icon = Icons.fitness_center;
                    break;
                  case 'running':
                    icon = Icons.directions_run;
                    break;
                  case 'tennis':
                    icon = Icons.sports_tennis;
                    break;
                  default:
                    icon = Icons.help_outline;
                }
                return IconButton(
                  icon: Icon(icon, size: 30.0),
                  color: _selectedIndex == _availableTabs.indexOf(tabName)
                      ? Colors.blue
                      : Colors.grey,
                  onPressed: () {
                    setState(() {
                      _selectedIndex = _availableTabs.indexOf(tabName);
                    });
                  },
                );
              }).toList()
                ..add(
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 30.0),
                    onPressed: _navigateToAddDiscipline,
                  ),
                ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
