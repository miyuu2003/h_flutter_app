import 'package:flutter/material.dart';
import 'package:hakkason_team_h/services/notification_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/reservation_view.dart';
import 'screens/mymakura/mymakura_view.dart';
import 'screens/home_view.dart';
import 'screens/admin_view.dart';
import 'screens/news/news_list_view.dart';
import 'seed.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  // Firebase 初期化（Web / 他プラットフォーム共通）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await seedNews();

  // ④: optionsで初期化 + ログ出し
  final o = DefaultFirebaseOptions.currentPlatform;
  debugPrint(
      'Firebase options -> appId=${o.appId}, projectId=${o.projectId}, bundleId=${o.iosBundleId}');
  try {
    final app = await Firebase.initializeApp(options: o);
    debugPrint('Firebase initialized -> appId=${app.options.appId}');
  } on FirebaseException catch (e) {
    debugPrint('Firebase init error: ${e.code} ${e.message}');
    rethrow; // ここで止めたい場合は残す。継続したいなら削除。
  }

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
    if (_lastTap != null && now.difference(_lastTap!).inSeconds > 5) {
      _logoTapCount = 0;
    }
    _logoTapCount++;
    _lastTap = now;
    if (_logoTapCount >= 7) {
      _showAdminPanel = !_showAdminPanel;
      _logoTapCount = 0;
      if (!_showAdminPanel && _selectedIndex >= 3) _selectedIndex = 0;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_showAdminPanel ? '管理画面を表示しました' : '管理画面を非表示にしました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return shadcn.ShadcnApp(
      theme: shadcn.ThemeData(radius: 0.5),
      home: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (innerContext) => Scaffold(
            backgroundColor: const Color.fromARGB(255, 240, 242, 246),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                HomeView(
                  onLogoSecretTap: _onLogoTap,
                  onTapReserve: () => setState(() => _selectedIndex = 2),
                  onTapMyPillow: () => setState(() => _selectedIndex = 1),
                  onTapNewsList: () {
                    Navigator.push(
                      innerContext,
                      MaterialPageRoute(builder: (_) => const NewsListView()),
                    );
                  },
                ),
                const MymakuraView(),
                const ReservationView(),
                if (_showAdminPanel) const AdminView(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) {
                if (!_showAdminPanel && i >= 3) return;
                setState(() => _selectedIndex = i);
              },
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'ホーム'),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.message), label: '私の枕'),
                const BottomNavigationBarItem(
                    icon: Icon(Icons.brightness_5_sharp), label: '予約'),
                if (_showAdminPanel)
                  const BottomNavigationBarItem(
                      icon: Icon(Icons.admin_panel_settings), label: '管理'),
              ],
              selectedItemColor: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
