// lib/screens/reservation_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

// riverpodのStateProviderを使って進捗を管理
final editProvider = StateProvider<bool>((ref) => false);

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
              ? const Text('編集モード')
              : Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white, // ← 白背景
                    borderRadius: BorderRadius.circular(16), // ← 角を丸めたい場合
                  ),
                  child: Center(
                      // 中央に配置
                      child: Stack(children: [
                    shadcn.CircularProgressIndicator(
                      value: 0.8,
                      color: Colors.indigo[200],
                      size: 260,
                    ),
                    Positioned(
                      top: 80,
                      left: 50,
                      child: Text('更新期間まで\n残り20日',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24)),
                    ),
                    Positioned(
                        top: 10,
                        left: 200,
                        child: IconButton(
                            onPressed: () => {handleEdit(ref)},
                            icon: Icon(shadcn.RadixIcons.pencil1)))
                  ])),
                ),
          const shadcn.Gap(48),
          
          // 保証カードも中央寄せ
          SizedBox(
            width: 300,
            child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('保証残り期間: 20日',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[700],
                        )),
                  )),
            ),
          ),
          
          const shadcn.Gap(24),
          
          // 更新記録も中央寄せ
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '更新記録',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
                const shadcn.Gap(16),
                Text('7/25 枕の高さ調整'),
                const Divider(thickness: 1, indent: 20, endIndent: 20),
                Text('7/30 枕の高さ調整'),
              ],
            ),
          ),
          
              const SizedBox(height: 20),
            ],
          ),
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
