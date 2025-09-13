import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as shadcn;
import 'package:hakkason_team_h/services/notification_service.dart';
// import 'package:your_pkg/notification_service.dart'; // 上のサービスを参照

class PillowAdjustProgress extends StatefulWidget {
  const PillowAdjustProgress({
    super.key,
    required this.purchaseDateIso,
  });
  final String purchaseDateIso;

  @override
  State<PillowAdjustProgress> createState() => _PillowAdjustProgressState();
}

class _PillowAdjustProgressState extends State<PillowAdjustProgress> {
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    _start = DateTime.parse(widget.purchaseDateIso);
    _scheduleNextIfNeeded(); // マウント時に通知を仕込む
  }

  // 経過（リングvalue/残日数/次サイクル日）を計算
  ({double value, int daysLeft, DateTime nextCycleDate, int cycleIndex})
      _calc() {
    final now = DateTime.now();
    final diff = now.difference(_start);
    final days = diff.inHours / 24.0; // 小数日
    final cycleIndex = days < 0 ? -1 : (days / 60).floor(); // 0,1,2...
    final passedInCycle = max(0.0, days - max(0, cycleIndex) * 60); // 0..60
    final value = (passedInCycle / 60.0).clamp(0.0, 1.0);
    final nextCycleDate = _start.add(Duration(days: (cycleIndex + 1) * 60));
    final daysLeft =
        nextCycleDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    return (
      value: value,
      daysLeft: daysLeft,
      nextCycleDate: nextCycleDate,
      cycleIndex: cycleIndex
    );
  }

  Future<void> _scheduleNextIfNeeded() async {
    final c = _calc();
    final key = 'cycle_${widget.purchaseDateIso}_${c.cycleIndex + 1}';
    await NotificationService.instance.scheduleOnceIfNeeded(
      cycleKey: key,
      when: c.nextCycleDate, // この日時で満タン＝通知
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _calc();
    final ringValue = c.value; // 0.0〜1.0
    final daysLeft = max(0, c.daysLeft); // 残日数（切り上げたければ調整）
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // お使いの shadcn.CircularProgressIndicator に合わせて
        SizedBox(
          width: 260, // 円の直径
          height: 260, // 円の直径
          child: shadcn.CircularProgressIndicator(
            value: ringValue,
            color: Colors.indigo[200],
            strokeWidth: 12, // 任意: 線の太さ
          ),
        ),

        const SizedBox(height: 12),
        Text(
          ringValue >= 1.0
              ? 'ちょうど60日経過！\n枕の調整をお願いします'
              : '次の調整まで 残り $daysLeft 日',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
