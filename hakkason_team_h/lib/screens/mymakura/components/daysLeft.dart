import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hakkason_team_h/screens/mymakura/components/daysleft_util.dart';
import 'package:hakkason_team_h/screens/mymakura/providers/daysLeftProvider.dart';
import 'package:hakkason_team_h/screens/mymakura/providers/purchase_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

// riverpodのStateProviderを使って進捗を管理
final editProvider = StateProvider<bool>((ref) => false);

class DaysLeft extends ConsumerWidget {
  const DaysLeft({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysLeft = ref.watch(daysLeftProvider); // Riverpodで管理される残日数
    return Container(
      width: 300,
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white, // 白背景
        borderRadius: BorderRadius.circular(16), // 角丸
      ),
      child: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: PillowAdjustProgress(
                  purchaseDateIso: ref.watch(purchaseDateProvider)),
            ),
            Positioned(
              top: 100,
              left: 90,
              child: Text.rich(
                TextSpan(
                  text: '更新期間まで\n残り', // 通常の文字
                  children: [
                    TextSpan(
                      text: '$daysLeft ', // ← サイズを大きくしたい部分
                      style: TextStyle(
                        fontSize: 48, // ← ここだけ大きく
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '日', // 通常サイズに戻す
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(shadcn.RadixIcons.pencil1),
                onPressed: () {
                  // Riverpodを使って状態を切り替え
                  handleEdit(ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void handleEdit(WidgetRef ref) {
  // 編集ボタンが押されたときの処理
  final notifier = ref.read(editProvider.notifier);
  notifier.state = !notifier.state; // 編集モードに切り替え
}
