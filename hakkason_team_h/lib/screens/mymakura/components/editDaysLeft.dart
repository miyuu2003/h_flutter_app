import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:hakkason_team_h/screens/mymakura/components/daysLeft.dart';

/// 購入日・メンテ期間を表示するカード
class EditDaysLeft extends ConsumerWidget {
  final String purchaseDate; // 例: '2023/7/25'
  final String maintenanceRange; // 例: '2024/7/25 - 2025/7/25'

  const EditDaysLeft({
    super.key,
    required this.purchaseDate,
    required this.maintenanceRange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // 右上の「編集完了」ボタン
          Positioned(
            top: 10,
            right: 10, // left:200 固定より right の方がレイアウトに強い
            child: IconButton(
              icon: Icon(shadcn.RadixIcons.check),
              onPressed: () {
                // 編集完了ボタンが押されたときの処理
                handleEdit(ref);
              },
            ),
          ),
          // 中央のテキスト
          Center(
            child: Text.rich(
              TextSpan(
                text: '購入日時\n',
                style: const TextStyle(fontSize: 16), // ベース
                children: [
                  TextSpan(
                    text: '$purchaseDate\n',
                    style: const TextStyle(
                      fontSize: 24, // 強調
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: 'メンテナンス期間\n'),
                  TextSpan(
                    text: maintenanceRange,
                    style: const TextStyle(
                      fontSize: 24, // 強調
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

void handleEdit(WidgetRef ref) {
  // 編集ボタンが押されたときの処理
  final notifier = ref.read(editProvider.notifier);
  notifier.state = !notifier.state; // 編集モードに切り替え
}
