import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
        bottomNavigationBar: BottomNavigationBar(
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
