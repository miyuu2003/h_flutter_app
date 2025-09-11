// lib/screens/home_view.dart
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              const Text('快眠本舗ヤマグチ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'オーダーメイド枕で理想の眠りを\nFITLABO認定店として、あなたにぴったりの枕をお作りします',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              // サービスカード
              _buildServiceCard(
                icon: Icons.straighten,
                title: 'オーダーメイド枕測定',
                description: '立位測定器で体型を正確に測定',
                price: '¥44,000',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              
              _buildServiceCard(
                icon: Icons.build,
                title: '枕メンテナンス',
                description: '購入後10年間無料で高さ調整',
                price: '無料',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              
              _buildServiceCard(
                icon: Icons.chat,
                title: '睡眠相談',
                description: 'お悩みに合わせた睡眠アドバイス',
                price: '無料',
                color: Colors.orange,
              ),
              
              const SizedBox(height: 40),
              
              // 店舗情報
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('店舗情報', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on, '大阪府池田市石橋1-15-7'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.train, '石橋阪大前駅 西口より徒歩3分'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.access_time, '10:00 - 19:00 (月曜定休)'),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone, '072-761-8097'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required String price,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color),
              ),
              child: Text(
                price,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }
}
