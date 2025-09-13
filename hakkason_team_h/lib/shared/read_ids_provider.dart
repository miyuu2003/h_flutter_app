import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 既読記事IDのProvider
final readIdsProvider =
    StateNotifierProvider<ReadIdsNotifier, Set<String>>((ref) {
  return ReadIdsNotifier();
});

class ReadIdsNotifier extends StateNotifier<Set<String>> {
  ReadIdsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('readNewsIds') ?? [];
    state = ids.toSet();
  }

  Future<void> markRead(String id) async {
    if (!state.contains(id)) {
      final updated = {...state, id};
      state = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('readNewsIds', updated.toList());
    }
  }
}
