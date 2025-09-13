import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hakkason_team_h/services/database_helper.dart';
import '../providers/purchase_provider.dart';

class PurchaseDateForm extends ConsumerStatefulWidget {
  const PurchaseDateForm({super.key, required this.customerNumber});
  final String customerNumber; // どの顧客へ保存するか

  @override
  ConsumerState<PurchaseDateForm> createState() => _PurchaseDateFormState();
}

class _PurchaseDateFormState extends ConsumerState<PurchaseDateForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    final current = ref.read(purchaseDateProvider); // 既存の値をコントローラへ
    _ctl = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  bool _isValidDate(String v) {
    // YYYY-MM-DD 形式のざっくりチェック（必要なら厳密に拡張）
    final re = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    return re.hasMatch(v);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final date = ref.read(purchaseDateProvider).trim();
    try {
      // customersテーブルの pillow_purchase_date を更新する例
      await DatabaseHelper.instance
          .updatePillowPurchaseDate("CUST-001", "2025-09-12");

      final rowsAffected = await DatabaseHelper.instance
          .updatePillowPurchaseDate(widget.customerNumber, date);

      if (rowsAffected > 0) {
        print("枕購入日を更新しました");
      } else {
        print("顧客が見つかりませんでした");
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購入日を保存しました')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseDate = ref.watch(purchaseDateProvider);
    final isValid = purchaseDate.isNotEmpty && _isValidDate(purchaseDate);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            TextFormField(
              controller: _ctl,
              decoration: const InputDecoration(
                labelText: '購入日 (YYYY-MM-DD)',
                hintText: '2025-09-13',
              ),
              onChanged: (v) {
                // 入力のたびに Riverpod の状態を更新（即UIに反映可能）
                ref.read(purchaseDateProvider.notifier).state = v;
              },
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return '必須です';
                if (!_isValidDate(text)) return 'YYYY-MM-DD の形式で入力してください';
                return null;
              },
              readOnly: false,
            ),
            const SizedBox(height: 12),
            // 便利: ピッカーで値を入れる（任意）
            OutlinedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: DateTime(now.year - 5),
                  lastDate: DateTime(now.year + 5),
                );
                if (picked != null) {
                  final y = picked.year.toString().padLeft(4, '0');
                  final m = picked.month.toString().padLeft(2, '0');
                  final d = picked.day.toString().padLeft(2, '0');
                  final formatted = '$y-$m-$d';
                  _ctl.text = formatted;
                  ref.read(purchaseDateProvider.notifier).state = formatted;
                }
              },
              child: const Text('日付を選択'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isValid ? _save : null, // バリデーションを満たすまで押せない
              child: const Text('購入日を保存'),
            ),
          ],
        ),
      ),
    );
  }
}
