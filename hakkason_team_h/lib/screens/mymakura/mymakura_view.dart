// lib/screens/reservation_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hakkason_team_h/screens/mymakura/components/daysLeft.dart';
import 'package:hakkason_team_h/screens/mymakura/components/updateHistory.dart';
import 'package:hakkason_team_h/screens/mymakura/components/editDaysLeft.dart';
import 'components/guaranteeCard.dart';

class MymakuraView extends ConsumerWidget {
  const MymakuraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(editProvider);

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
                  : DaysLeft(), // 保証残り期間表示
              const SizedBox(height: 20),

              // 保証カードも中央寄せ
              const GuaranteeCard(text: '保証期間残り：３０日'),

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
