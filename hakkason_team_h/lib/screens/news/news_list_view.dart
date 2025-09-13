import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/read_ids_provider.dart';
import 'news_detail_view.dart';

/// ニュースの簡易モデル
class NewsItem {
  final String id;
  final String title;
  final String excerpt;
  final DateTime publishedAt;

  const NewsItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.publishedAt,
  });
}

/// ダミー取得（将来はAPIに差し替え）
final newsListProvider = FutureProvider.autoDispose<List<NewsItem>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400)); // 読み込み演出
  return [
  NewsItem(
    id: 'n1',
    title: 'レンタル枕の新サービスをご紹介',
    excerpt: '3ヶ月ごとの調整プランとセットでお得に…',
    publishedAt: DateTime(2025, 9, 10), // ← OK
  ),
  NewsItem(
    id: 'n2',
    title: '自分のカラダ分析ができるようになりました',
    excerpt: '睡眠傾向のスコア化で「次の調整タイミング」が分かる',
    publishedAt: DateTime(2025, 9, 8),
  ),
  NewsItem(
    id: 'n3',
    title: '今週末のストレッチ体験会',
    excerpt: '店内イベントのお知らせ。参加無料・予約不要です',
    publishedAt: DateTime(2025, 9, 7),
  ),
];
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
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(newsListProvider);
              await ref.read(newsListProvider.future); // 再取得を待つ
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _NewsTile(item: items[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('読み込みに失敗しました'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(newsListProvider),
                child: const Text('リトライ'),
              ),
            ],
          ),
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
          // 既読に追加
          await ref.read(readIdsProvider.notifier).markRead(item.id);

          // 詳細ページへ
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NewsDetailView(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
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

              // タイトル（既読なら薄くする）
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: isRead ? Colors.grey[600] : Colors.black,
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
                      color: isRead ? Colors.grey[500] : Colors.grey[800],
                      fontSize: 13,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}