// lib/screens/home_view.dart
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.gif', // 実際のファイル名に合わせて
            width: 250,
            height: 160,
            fit: BoxFit.cover,
            // 失敗時の見た目（任意）
            errorBuilder: (_, __, ___) => Container(
              width: 150,
              height: 60,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Text('画像読み込み失敗'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Home', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('ここにHomeを実装します'),
        ],
      ),
    );
  }
}
