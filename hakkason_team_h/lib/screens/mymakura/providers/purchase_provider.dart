import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 購入日（テキスト）。ページをまたいでも保持したいので autoDispose にはしない。
final purchaseDateProvider = StateProvider<String>((ref) => '');
