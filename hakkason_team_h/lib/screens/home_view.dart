// lib/screens/home_view.dart
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/logo.gif', // 実際のファイル名に合わせて
                width: 250,
                height: 160,
                fit: BoxFit.cover,
                // 失敗時の見た目（任意）
                errorBuilder: (_, __, ___) => Container(
                  width: 250,
                  height: 160,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Text('画像読み込み失敗'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Home', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('ここにHomeを実装します'),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
