// lib/screens/home_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
// 追加
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'news/news_list_view.dart' show NewsItem;
import 'news/news_detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    this.onLogoSecretTap,
    this.onTapReserve,
    this.onTapMyPillow,
    this.onTapNewsList,
  });

    final VoidCallback? onLogoSecretTap;
    final VoidCallback? onTapReserve;
    final VoidCallback? onTapMyPillow;
    final VoidCallback? onTapNewsList;

  @override
  Widget build(BuildContext context) {
    // ベーストーン（白基調）
    final bg = const Color(0xFFF6F7F9);
    final cardRadius = 16.0;
    final gutter = 16.0;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEFF3FF), Color(0xFFFFFFFF)],
                stops: [0.0, 0.55],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: onLogoSecretTap,
                          behavior: HitTestBehavior.opaque,
                          child: const _Logo(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ===== お知らせカード（最新3件） =====
                      _SectionCard(
                        radius: cardRadius,
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
                        title: 'お知らせ',
                        trailing: IconButton(
                          tooltip: 'もっと見る',
                          icon: const Icon(Icons.chevron_right),
                          onPressed: onTapNewsList,
                        ),
                        child: const _NewsBullets(), // ← 差し替え：Firestoreから取得
                      ),

                      const SizedBox(height: 14),

                      // 2カード：予約 / 私の枕（レスポンシブ）
                      LayoutBuilder(
                        builder: (context, c) {
                          final narrow = c.maxWidth < 520;
                          final cards = [
                            _ActionCard(
                              title: '予約',
                              subtitle: '来店や体験のご予約はこちら',
                              imagePath: 'assets/images/image-morning.jpg',
                              onTap: onTapReserve,
                            ),
                            _ActionCard(
                              title: '私の枕',
                              subtitle: 'マイデータや調整履歴を確認',
                              imagePath: 'assets/images/pillow.jpg',
                              onTap: onTapMyPillow,
                            ),
                          ];
                          if (narrow) {
                            return Column(
                              children: [
                                cards[0],
                                const SizedBox(height: 12),
                                cards[1],
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: cards[0]),
                              const SizedBox(width: 12),
                              Expanded(child: cards[1]),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Firestore モデル & Provider ==========

class _NewsItem {
  final String id;
  final String title;
  final String excerpt;
  final DateTime publishedAt;
  final String? content;

  _NewsItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.publishedAt,
    this.content,
  });

  factory _NewsItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return _NewsItem(
      id: doc.id,
      title: (m['title'] ?? '') as String,
      excerpt: (m['excerpt'] ?? '') as String,
      content: m['content'] as String?,
      publishedAt: (m['publishedAt'] as Timestamp).toDate(), // ← FirestoreはTimestampで
    );
  }
}

// 最新3件だけ購読
final latestNewsProvider =
    StreamProvider.autoDispose<List<NewsItem>>((ref) {
  return FirebaseFirestore.instance
      .collection('news')
      .orderBy('publishedAt', descending: true)
      .limit(3)
      .snapshots()
      .map((snap) => snap.docs.map((d) {
            final m = d.data() as Map<String, dynamic>;
            return NewsItem(
              id: d.id,
              title: (m['title'] ?? '') as String,
              excerpt: (m['excerpt'] ?? '') as String,
              publishedAt: (m['publishedAt'] as Timestamp).toDate(),
            );
          }).toList());
});

// ========== Parts ==========

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.gif',
      width: 200,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: 200,
        height: 120,
        alignment: Alignment.center,
        child: const Text('LOGO', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.radius = 16,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// Firestoreからの最新3件を表示するウィジェット
class _NewsBullets extends ConsumerWidget {
  const _NewsBullets();

  String _fmt(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNews = ref.watch(latestNewsProvider);

    return asyncNews.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonLine(),
          SizedBox(height: 8),
          _SkeletonLine(widthFactor: 0.85),
          SizedBox(height: 8),
          _SkeletonLine(widthFactor: 0.6),
        ],
      ),
      error: (e, _) => Text('お知らせを読み込めませんでした', style: TextStyle(color: Colors.red)),
      data: (items) {
        if (items.isEmpty) return const Text('最新のお知らせはまだありません');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((it) {
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NewsDetailView(item: it), // そのまま渡す
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${it.title}（${_fmt(it.publishedAt)}）',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// 簡易スケルトン
class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({this.widthFactor = 1.0});
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 6, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.imagePath,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String imagePath;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = 16.0;
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ヘッダー（タイトル + 矢印）
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.55),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
            // 画像
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF1F3F5),
                      alignment: Alignment.center,
                      child: Text(
                        'No Image',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
