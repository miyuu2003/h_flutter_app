import 'package:flutter/material.dart';

/// yyyy-MM-dd などのISO文字列でも扱える保証カード
class GuaranteeCard extends StatelessWidget {
  /// 例: "2018-05-03"（ISO8601推奨）。DateTime.parseできればOK
  final String warrantyStartIso; // 保証開始日（DBからの文字列想定）

  const GuaranteeCard({
    super.key,
    required this.warrantyStartIso,
  });

  @override
  Widget build(BuildContext context) {
    final display = _buildWarrantyDisplay(warrantyStartIso);
    final theme = Theme.of(context);

    return SizedBox(
      width: 300,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  display.expired ? '保証期間' : '保証期間まで',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  display.expired ? '終了' : '残り',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                // メイン表示（大きく）
                Text(
                  display.mainLine,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (display.subLine != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    display.subLine!,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 表示用データ（UIに渡すだけ）
class _WarrantyDisplay {
  final String mainLine; // 大きく出す行
  final String? subLine; // 補助の行（不要ならnull）
  final bool expired; // 期限切れ
  const _WarrantyDisplay(this.mainLine, {this.subLine, this.expired = false});
}

/// yyyy-MM-dd → 表示用データを作る
_WarrantyDisplay _buildWarrantyDisplay(String startIso) {
  final start = DateTime.parse(startIso);
  final end = DateTime(start.year + 10, start.month, start.day); // 10年保証の満了日
  final today = DateTime.now();

  // 日付だけで比較（時刻は切り落とす）
  final dOnly = DateTime(today.year, today.month, today.day);
  if (!dOnly.isBefore(end)) {
    return const _WarrantyDisplay('保証期限切れ', expired: true);
  }

  final daysLeft = end.difference(dOnly).inDays;
  if (daysLeft < 365) {
    // 1年未満は日数のみ
    return _WarrantyDisplay('$daysLeft日');
  }

  // 1年以上 → 年月日を算出
  final diff = _diffYMD(dOnly, end);
  // 例: メインに「5年3ヶ月」、サブに「324日」
  return _WarrantyDisplay('${diff.years}年${diff.months}ヶ月',
      subLine: '${diff.days}日');
}

/// 年月日差分（うるう年・月末も自然に考慮）
class _YmdDiff {
  final int years, months, days;
  const _YmdDiff(this.years, this.months, this.days);
}

_YmdDiff _diffYMD(DateTime from, DateTime to) {
  // 日付のみで計算
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);

  int y = to.year - from.year;
  int m = to.month - from.month;
  int d = to.day - from.day;

  if (d < 0) {
    // to の前月末の日数を借りる
    final prevMonthEnd = DateTime(to.year, to.month, 0);
    d += prevMonthEnd.day;
    m -= 1;
  }
  if (m < 0) {
    m += 12;
    y -= 1;
  }
  return _YmdDiff(y, m, d);
}
