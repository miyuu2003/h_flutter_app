import 'package:flutter/material.dart';
import 'news_list_view.dart'; // NewsItem を使うため

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key, required this.item});
  final NewsItem item;

  String _fmt(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('お知らせ詳細')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(item.title,
              style: Theme.of(context).textTheme.titleLarge,
              strutStyle: const StrutStyle(height: 1.3)),
          const SizedBox(height: 6),
          Text(_fmt(item.publishedAt),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(
            // 本文ダミー。将来はAPIから content を取得して表示
            '${item.excerpt}\n\n本文は準備中です。今後、API連携で差し替えます。',
            style: Theme.of(context).textTheme.bodyMedium,
            strutStyle: const StrutStyle(height: 1.6),
          ),
        ],
      ),
    );
  }
}
