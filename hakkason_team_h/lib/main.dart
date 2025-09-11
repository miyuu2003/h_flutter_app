import 'package:flutter/material.dart';
import 'screens/reservation_view.dart';
import 'screens/mymakura_view.dart';
import 'screens/home_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp>{
  int _selectedIndex = 0;
  String _titleForIndex(int i) {
    switch (i) {
      case 0: return '快眠本舗ヤマグチ';
      case 1: return '私の枕';
      case 2: return '予約';
      default: return '';
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // ← ヘッダーを追加
        appBar: AppBar(
          // 背景をうっすら白、影なし（好みで調整）
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: 0,
          scrolledUnderElevation: 0,
          // 文字色やアイコン色
          foregroundColor: Colors.black87,
          centerTitle: false,
          title: Text(
            _titleForIndex(_selectedIndex),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.transparent,
              // ロゴがあれば差し替え。なければアイコンでOK
              child: Image.asset(
                'assets/images/logo.gif',
                errorBuilder: (_, __, ___) => const Icon(Icons.bedtime_outlined),
              ),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'お知らせ',
              onPressed: () {/* TODO: /news に遷移 */},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton(
              tooltip: '設定',
              onPressed: () {/* TODO: /settings に遷移 */},
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children : [
            // Center(child: Text('ホーム画面')),
            HomeView(),
            MymakuraView(),
            ReservationView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) =>setState(() => _selectedIndex = i),
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
