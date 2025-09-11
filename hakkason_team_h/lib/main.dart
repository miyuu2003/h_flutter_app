import 'package:flutter/material.dart';
import 'screens/reservation_view.dart';
import 'screens/mymakura_view.dart';
import 'screens/home_view.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return shadcn.ShadcnApp(
      theme: shadcn.ThemeData(
        radius: 0.5,
      ),
      home: Scaffold(
        backgroundColor: Colors.orange[50],
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            // Center(child: Text('ホーム画面')),
            HomeView(),
            MymakuraView(),
            ReservationView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: '私の枕',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.brightness_5_sharp),
              label: '予約',
            ),
          ],
          selectedItemColor: Colors.blue,
        ),
      ),
    );
  }
}
