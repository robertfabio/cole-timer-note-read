import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'timer_screen.dart';
import 'stats_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';

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
    StatsScreen(key: PageStorageKey('stats'))
  ];
  
  final List<String> _titles = [
    'Início',
    'Timer',
    'Notas',
    'Estatísticas'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[navigationProvider.currentIndex]),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationProvider.currentIndex,
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
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
} 