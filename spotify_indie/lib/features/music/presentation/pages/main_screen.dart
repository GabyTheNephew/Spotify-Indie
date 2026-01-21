import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';
import 'home_page.dart';
import 'playlists_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Lista de pagini disponibile
  final List<Widget> _pages = [
    const HomePage(),
    const PlaylistsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body-ul este o coloană: Pagina Activă + MiniPlayer
      body: Column(
        children: [
          // 1. Pagina Activă (ocupă tot spațiul rămas)
          Expanded(
            child: _pages[_currentIndex], 
          ),
          
          // 2. MiniPlayer (Persistent peste pagini)
          const MiniPlayer(),
        ],
      ),
      
      // 3. Bara de Navigație (Footer)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}