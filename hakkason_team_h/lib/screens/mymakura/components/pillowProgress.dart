import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hakkason_team_h/screens/mymakura/providers/daysLeftProvider.dart';
import 'package:hakkason_team_h/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:your_pkg/notification_service.dart';

class PillowAdjustProgress extends ConsumerStatefulWidget {
  const PillowAdjustProgress({
    super.key,
    required this.purchaseDateIso,
  });
  final String purchaseDateIso; // "YYYY-MM-DD"

  @override
  ConsumerState<PillowAdjustProgress> createState() =>
      _PillowAdjustProgressState();
}

class _PillowAdjustProgressState extends ConsumerState<PillowAdjustProgress> {
  late DateTime _start;
  late final int daysLeft;
  @override
  void initState() {
    super.initState();
    _start = DateTime.parse(widget.purchaseDateIso);
    _scheduleNextIfNeeded();
  }

  // 経過状態を計算：リング値 / 残日数 / 次サイクル日 / サイクル番号
  ({double value, int daysLeft, DateTime nextCycleDate, int cycleIndex})
      _calc() {
    final now = DateTime.now();
    final days = now.difference(_start).inHours / 24.0; // 小数日
    final idx = days < 0 ? -1 : (days / 60).floor(); // 0,1,2...
    final passedInCycle = max(0.0, days - max(0, idx) * 60); // 0..60
    final value = (passedInCycle / 60.0).clamp(0.0, 1.0); // 0.0..1.0
    final nextCycleDate = _start.add(Duration(days: (idx + 1) * 60));
    final dOnlyNow = DateTime(now.year, now.month, now.day);
    final daysLeft = nextCycleDate.difference(dOnlyNow).inDays;
    return (
      value: value,
      daysLeft: daysLeft,
      nextCycleDate: nextCycleDate,
      cycleIndex: idx
    );
  }

  Future<void> _scheduleNextIfNeeded() async {
    final c = _calc();
    final key = 'cycle_${widget.purchaseDateIso}_${c.cycleIndex + 1}';

    // 通知は nextCycleDate の「朝9時」に出す（お好みで調整）
    final at9 = DateTime(
      c.nextCycleDate.year,
      c.nextCycleDate.month,
      c.nextCycleDate.day,
      9,
      0,
      0,
    );

    await NotificationService.instance.scheduleOnceIfNeeded(
      cycleKey: key,
      when: at9,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _calc();
    final value = c.value;
    daysLeft = max(0, c.daysLeft);
    ref.read(daysLeftProvider.notifier).state = max(0, c.daysLeft);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // お使いの shadcn ウィジェットに合わせて
        PillowAdjustProgress(purchaseDateIso: '2025-06-01'),
        const SizedBox(height: 12),
        Text(
          value >= 1.0 ? 'ちょうど60日経過！\n枕の調整をお願いします' : '次の調整まで 残り $daysLeft 日',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
