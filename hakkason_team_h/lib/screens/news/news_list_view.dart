// lib/screens/news/news_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shared/read_ids_provider.dart';
import 'news_detail_view.dart';

/// ニュースの簡易モデル
class NewsItem {
  final String id;
  final String title;
  final String excerpt;
  final DateTime publishedAt;
  final String? content;

  const NewsItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.publishedAt,
    this.content,
  });

  factory NewsItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? <String, dynamic>{};
    return NewsItem(
      id: doc.id,
      title: (m['title'] ?? '') as String,
      excerpt: (m['excerpt'] ?? '') as String,
      content: m['content'] as String?,
      // Firestore は Timestamp 型で保存しておくこと！
      publishedAt: (m['publishedAt'] as Timestamp).toDate(),
    );
  }
}

/// Firestore からニュース一覧をリアルタイム購読
final newsListProvider =
    StreamProvider.autoDispose<List<NewsItem>>((ref) {
  return FirebaseFirestore.instance
      .collection('news')
      .orderBy('publishedAt', descending: true)
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (m, _) => m,
      )
      .snapshots()
      .map((snap) => snap.docs.map((d) => NewsItem.fromDoc(d)).toList());
});

class NewsListView extends ConsumerWidget {
  const NewsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNews = ref.watch(newsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('お知らせ一覧')),
      body: asyncNews.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('お知らせはまだありません'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _NewsTile(item: items[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('読み込みに失敗しました：$e'),
        ),
      ),
    );
  }
}

class _NewsTile extends ConsumerWidget {
  const _NewsTile({required this.item, super.key});
  final NewsItem item;

  String _fmt(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readIds = ref.watch(readIdsProvider); // 既読IDの集合を監視
    final isRead = readIds.contains(item.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // 既読に追加してから詳細へ
          await ref.read(readIdsProvider.notifier).markRead(item.id);
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewsDetailView(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 未読ドット
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 10, left: 2),
                child: Icon(
                  Icons.brightness_1,
                  size: 10,
                  color: isRead ? Colors.transparent : Colors.blueAccent,
                ),
              ),

              // テキスト群
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 日付
                    Text(
                      _fmt(item.publishedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // タイトル（既読なら少し薄く）
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            color: isRead ? Colors.grey[700] : Colors.black,
                            fontSize: 16,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // 抜粋
                    Text(
                      item.excerpt,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isRead ? Colors.grey[600] : Colors.grey[800],
                            fontSize: 13,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
