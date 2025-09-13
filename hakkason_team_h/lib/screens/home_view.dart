// lib/screens/home_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';

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
    final bg = const Color(0xFFF6F7F9); // ごく薄いグレーで白を引き立てる
    final cardRadius = 16.0;
    final gutter = 16.0;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // うっすら背景（上：薄いブルー → 下：完全白）※写真は使わず最小主張
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEFF3FF), // very light blue
                  Color(0xFFFFFFFF), // white
                ],
                stops: [0.0, 0.55],
              ),
            ),
          ),

          // 背景に控えめなノイズ/ブラー（主張しない）
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
                      // ロゴ（タップで秘密トグル）
                      Center(
                        child: GestureDetector(
                          onTap: onLogoSecretTap,
                          behavior: HitTestBehavior.opaque,
                          child: const _Logo(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // セクション：お知らせ
                      _SectionCard(
                        radius: cardRadius,
                        padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
                        title: 'お知らせ',
                        trailing: IconButton(
                          tooltip: 'もっと見る',
                          icon: const Icon(Icons.chevron_right),
                          onPressed: onTapNewsList,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _BulletItem(text: 'レンタル枕の新サービスをご紹介'),
                            _BulletItem(text: '自分のカラダ分析ができるようになりました'),
                            _BulletItem(text: '今週末のストレッチ体験会'),
                          ],
                        ),
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
                              imagePath: 'assets/images/card_reserve.jpg',
                              onTap: onTapReserve,
                            ),
                            _ActionCard(
                              title: '私の枕',
                              subtitle: 'マイデータや調整履歴を確認',
                              imagePath: 'assets/images/card_mypillow.jpg',
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

/// 白ベースの汎用カード
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

/// 行動カード（白ベース / 大きなタップ領域 / 画像は控えめ）
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
            // 画像（控えめな高さ・角丸・全体表示）
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
