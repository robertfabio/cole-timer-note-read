import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'timer_screen.dart';
import 'stats_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'reading_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Keep screen instances alive
  final List<Widget> _screens = [
    HomeScreen(key: PageStorageKey('home')),
    TimerScreen(key: PageStorageKey('timer')),
    NotesScreen(key: PageStorageKey('notes')),
    ReadingScreen(key: PageStorageKey('reading')),
  ];
  
  final List<String> _titles = [
    'Início',
    'Timer',
    'Notas',
    'Biblioteca'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navigationProvider.currentIndex;

    return Scaffold(
      appBar: currentIndex == 0 ? AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.9),
                theme.colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Cole',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          SizedBox(width: 8),
        ],
      ) : null,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          navigationProvider.setIndex(index);
        },
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notas',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Biblioteca',
          ),
        ],
      ),
    );
  }
} 