import 'package:flutter/material.dart';
import 'add_discipline_screen.dart';

class TabContainerScreen extends StatefulWidget {
  @override
  _TabContainerScreenState createState() => _TabContainerScreenState();
}

class _TabContainerScreenState extends State<TabContainerScreen> {
  int _selectedIndex = 0; // Índice inicial para las tabs
  bool _showSoccerTab = false; // Controlar si se muestra el Tab de Balón

  // Datos de fútbol
  String? _favoritePosition;
  String? _preferredFoot;
  String? _leaderNumber;
  String? _clutchNumber;
  int _pace = 3;
  int _defending = 3;
  int _shooting = 3;
  int _passing = 3;
  int _dribbling = 3;

  // Cambiar el índice seleccionado al hacer clic en una pestaña
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Navegar a la pantalla de agregar disciplina
  void _navigateToAddDiscipline() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDisciplineScreen(
          onDone: (
            String
                favoritePosition, // Ajusta según el nuevo nombre de variable si cambió
            String preferredFoot,
            String leaderNumber,
            String clutchNumber,
            double
                pace, // Si es necesario, cambia a int en la pantalla AddDisciplineScreen
            double defending,
            double shooting,
            double passing,
            double dribbling,
          ) {
            setState(() {
              // Actualiza los datos con los valores ingresados
              _favoritePosition = favoritePosition;
              _preferredFoot = preferredFoot;
              _leaderNumber = leaderNumber;
              _clutchNumber = clutchNumber;
              _pace = pace.round(); // Convierte a int si es necesario
              _defending = defending.round();
              _shooting = shooting.round();
              _passing = passing.round();
              _dribbling = dribbling.round();
              _showSoccerTab =
                  true; // Muestra el Tab de Balón cuando se selecciona "fútbol"
              _selectedIndex = 1; // Cambia automáticamente al Tab de Balón
            });
          },
        ),
      ),
    );
    if (result == 'soccer') {
      setState(() {
        _showSoccerTab =
            true; // Muestra el Tab de Balón cuando se selecciona "fútbol"
        _selectedIndex = 1; // Cambia automáticamente al Tab de Balón
      });
    }
  }

  // Contenido inferior basado en la pestaña seleccionada
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: // Tab de casa
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: 9,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 elementos por fila
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.add, // Ícono de signo de más
                size: 40.0,
                color: Colors.grey[700],
              ),
            );
          },
        );
      case 1: // Tab de balón
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Posición Favorita: $_favoritePosition'),
              Text('Pie Hábil: $_preferredFoot'),
              Text('Número Leader: $_leaderNumber'),
              Text('Número Clutch: $_clutchNumber'),
              SizedBox(height: 10),
              _buildStarsRow('Pace', _pace),
              _buildStarsRow('Defending', _defending),
              _buildStarsRow('Shooting', _shooting),
              _buildStarsRow('Passing', _passing),
              _buildStarsRow('Dribbling', _dribbling),
            ],
          ),
        );
      case 2: // Tab de signo de más
        return Center(
          child: Text(
            'Próximamente',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return Container(); // Por defecto, un contenedor vacío
    }
  }

  // Construye una fila de estrellas para la calificación
  Widget _buildStarsRow(String label, int rating) {
    return Row(
      children: [
        Text('$label: '),
        Row(
          children: List.generate(rating, (index) {
            // Genera solo las estrellas llenas
            return Icon(
              Icons.star,
              color: Colors.amber,
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.blueGrey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home, size: 30.0),
                  color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
                  onPressed: () => _onTabTapped(0),
                ),
                if (_showSoccerTab) // Muestra el Tab de Balón solo si se seleccionó fútbol
                  IconButton(
                    icon: Icon(Icons.sports_soccer, size: 30.0),
                    color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
                    onPressed: () => _onTabTapped(1),
                  ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 30.0),
                  color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
                  onPressed:
                      _navigateToAddDiscipline, // Navega a agregar disciplina
                ),
              ],
            ),
          ),
          // Contenido inferior
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
