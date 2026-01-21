import 'dart:async'; // Necesită import
import 'package:connectivity_plus/connectivity_plus.dart'; // Import nou
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

  // Variabilă pentru a asculta conexiunea
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final List<Widget> _pages = [const HomePage(), const PlaylistsPage()];

  @override
  void initState() {
    super.initState();
    // 1. Verificăm conexiunea imediat ce intrăm în aplicație
    _checkInitialConnection();

    // 2. Ascultăm schimbările în timp real (dacă pică netul în timp ce folosim app)
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      _handleConnectionChange(results);
    });
  }

  // Funcție care verifică starea inițială
  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    _handleConnectionChange(results);
  }

  // Funcție comună pentru a afișa notificarea
  void _handleConnectionChange(List<ConnectivityResult> results) {
    // Dacă lista de rezultate conține 'none', înseamnă că nu avem net
    if (results.contains(ConnectivityResult.none)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 12),
                Text("No internet connection"),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3), // Stă 3 secunde
            behavior: SnackBarBehavior.floating, // Apare deasupra elementelor
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // Oprim ascultătorul când ieșim
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body-ul este o coloană: Pagina Activă + MiniPlayer
      body: Column(
        children: [
          Expanded(child: _pages[_currentIndex]),
          const MiniPlayer(),
        ],
      ),

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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
