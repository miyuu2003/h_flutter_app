import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hakkason_team_h/screens/mymakura/components/purchase_date_form.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:hakkason_team_h/screens/mymakura/components/daysLeft.dart';

/// 購入日・メンテ期間を表示するカード
class EditDaysLeft extends ConsumerWidget {
  final String purchaseDate;
  final String maintenanceRange;

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
            right: 10,
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
            child: PurchaseDateForm(customerNumber: "CUST-001"),
          ), // フォームを埋め込む
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
