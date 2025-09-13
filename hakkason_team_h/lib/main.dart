import 'package:flutter/material.dart';
import 'screens/reservation_view.dart';
import 'screens/mymakura/mymakura_view.dart';
import 'screens/home_view.dart';
import 'screens/admin_view.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // FFI の初期化
  sqfliteFfiInit();

  // databaseFactory を FFI 用に差し替え
  databaseFactory = databaseFactoryFfi;

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  bool _showAdminPanel = false;
  int _logoTapCount = 0;
  DateTime? _lastTap;

  void _onLogoTap() {
    final now = DateTime.now();

    // 5秒以内のタップでなければリセット
    if (_lastTap != null && now.difference(_lastTap!).inSeconds > 5) {
      _logoTapCount = 0;
    }

    _logoTapCount++;
    _lastTap = now;

    // 7回タップで管理画面表示
    if (_logoTapCount >= 7) {
      _showAdminPanel = !_showAdminPanel;
      _logoTapCount = 0;

      // 管理画面を非表示にする場合、選択インデックスが3以上なら0にリセット
      if (!_showAdminPanel && _selectedIndex >= 3) {
        _selectedIndex = 0;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_showAdminPanel ? '管理画面を表示しました' : '管理画面を非表示にしました'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
          children: [
            // Center(child: Text('ホーム画面')),
            GestureDetector(
              onTap: _onLogoTap,
              child: const HomeView(),
            ),
            const MymakuraView(),
            const ReservationView(),
            if (_showAdminPanel) const AdminView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) {
            // 管理画面が非表示の場合、インデックスを調整
            if (!_showAdminPanel && i >= 3) return;
            setState(() => _selectedIndex = i);
          },
          type: _showAdminPanel
              ? BottomNavigationBarType.fixed
              : BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ホーム',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: '私の枕',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.brightness_5_sharp),
              label: '予約',
            ),
            if (_showAdminPanel)
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: '管理',
              ),
          ],
          selectedItemColor: Colors.blue,
        ),
      ),
    );
  }
}
