// providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 残り日数（初期0）
final daysLeftProvider = StateProvider<int>((ref) => 30);
