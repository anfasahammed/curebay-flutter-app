import 'package:flutter/material.dart';
import 'theme/curebay_theme.dart';
import 'screens/home_screen.dart';
import 'screens/records_screen.dart';
import 'screens/about_screen.dart';

void main() {
  runApp(const CureBayApp());
}

class CureBayApp extends StatelessWidget {
  const CureBayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CureBay Assist',
      debugShowCheckedModeBanner: false,
      theme: curebayTheme(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  // Key to force-rebuild records screen each time tab is tapped
  Key _recordsKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentIndex) {
      case 0:
        body = const HomeScreen();
        break;
      case 1:
        body = RecordsScreen(key: _recordsKey);
        break;
      case 2:
        body = const AboutScreen();
        break;
      default:
        body = const HomeScreen();
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() {
              _currentIndex = i;
              // Force fresh records screen each time it's selected
              if (i == 1) _recordsKey = UniqueKey();
            }),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: CureBayColors.navy,
            unselectedItemColor: CureBayColors.textLight,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_outlined),
                activeIcon: Icon(Icons.folder),
                label: 'Records',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                activeIcon: Icon(Icons.info),
                label: 'About',
              ),
            ],
          ),
        ),
      ),
    );
  }
}