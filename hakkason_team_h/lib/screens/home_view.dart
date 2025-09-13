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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景画像
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
          ),
          // コントラスト確保のためのグラデーションベール
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(110, 141, 151, 255),
                  Color.fromARGB(0, 62, 135, 190),
                  Color.fromARGB(70, 255, 255, 255),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ロゴ（ロゴだけ秘密タップ）
                      Center(
                        child: GestureDetector(
                          onTap: onLogoSecretTap,
                          behavior: HitTestBehavior.opaque,
                          child: const _Logo(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // お知らせカード
                      GlassCard(
                        // 透明感を少し強め
                        opacity: 0.10,
                        blur: 22,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CardHeader(
                              title: 'お知らせ',
                              trailing: IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: onTapNewsList,
                                tooltip: 'もっと見る',
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...[
                              'レンタル枕の新サービスをご紹介',
                              '自分のカラダ分析ができるようになりました',
                              '今週末のストレッチ体験会',
                            ].map((text) => _BulletItem(text: text)),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2 カード（予約 / 私の枕）
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 480;
                          final cards = [
                            _ActionCard(
                              title: '予約',
                              imagePath: 'assets/images/card_reserve.jpg',
                              onTap: onTapReserve,              // ← 非null断言を外す
                              // 画像が切れやすい対策（全体表示＋上寄せ気味）
                              fit: BoxFit.contain,
                              aspectRatio: 4 / 3,
                              alignment: Alignment.topCenter,
                            ),
                            _ActionCard(
                              title: '私の枕',
                              imagePath: 'assets/images/card_mypillow.jpg',
                              onTap: onTapMyPillow,            // ← 非null断言を外す
                              // サムネ感を出す横長
                              fit: BoxFit.cover,
                              aspectRatio: 16 / 9,
                              alignment: Alignment.center,
                            ),
                          ];

                          if (isNarrow) {
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

                      const SizedBox(height: 32),
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

// -------------------- Parts --------------------

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.gif',
      width: 220,
      height: 140,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 220,
        height: 140,
        color: Colors.white.withOpacity(0.6),
        alignment: Alignment.center,
        child: const Text('画像読み込み失敗'),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blur = 18,
    this.opacity = 0.12,      // 小さいほど透明
    this.tint = Colors.white, // ガラス色
  });

  final Widget child;
  final EdgeInsets padding;
  final double blur;
  final double opacity;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
            // ガラスのハイライト
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.02),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
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
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
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
    this.onTap,                           // ← nullable に
    this.aspectRatio = 16 / 9,            // 見せ方を呼び出し側で調整可
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String title;
  final String imagePath;
  final VoidCallback? onTap;              // ← nullable に変更
  final double aspectRatio;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,                      // nullable OK
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: fit,
                  alignment: alignment,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Text('No Image'),
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
