// lib/screens/mymakura/mymakura_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hakkason_team_h/screens/mymakura/components/daysLeft.dart' as days_left;
import 'package:hakkason_team_h/screens/mymakura/components/updateHistory.dart';
import 'package:hakkason_team_h/screens/mymakura/components/editDaysLeft.dart';
import 'package:hakkason_team_h/screens/mymakura/components/guaranteeCard.dart';
import 'package:hakkason_team_h/screens/mymakura/providers/purchase_provider.dart';

class MymakuraView extends ConsumerWidget {
  const MymakuraView({super.key});

  bool _isValidDate(String v) => RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(days_left.editProvider);
    final date = ref.watch(purchaseDateProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              isEditing
                  ? EditDaysLeft(
                      purchaseDate: '2023/7/25',
                      maintenanceRange: '2024/7/25 - 2025/7/25',
                    )
                  : const days_left.DaysLeft(), // 保証残り期間表示
              const SizedBox(height: 20),
              date.isEmpty || !_isValidDate(date)
                  ? const Text('購入日を入力すると保証残り期間を表示します')
                  : GuaranteeCard(warrantyStartIso: date),

              const SizedBox(height: 20),

              // 更新記録も中央寄せ
              const UpdateHistory(title: '更新記録'),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
