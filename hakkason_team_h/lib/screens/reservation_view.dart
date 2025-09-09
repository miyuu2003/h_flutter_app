// lib/screens/reservation_view.dart
import 'package:flutter/material.dart';

class ReservationView extends StatelessWidget {
  const ReservationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.calendar_today, size: 80, color: Colors.blue),
        SizedBox(height: 20),
        Text('予約画面', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text('ここに予約機能を実装します'),
      ]),
    );
  }
}
