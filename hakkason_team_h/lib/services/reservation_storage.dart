import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationStorage {
  static const String _storageKey = 'reservations';
  static final Map<String, dynamic> _memoryCache = {};

  static Future<void> saveReservations(List<Map<String, dynamic>> reservations) async {
    try {
      final jsonString = jsonEncode(reservations);
      
      // SharedPreferencesに保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonString);
      
      // メモリキャッシュにも保存
      _memoryCache[_storageKey] = jsonString;
      
      if (kDebugMode) {
        print('Saved ${reservations.length} reservations to persistent storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving reservations: $e');
      }
      // エラー時はメモリキャッシュのみに保存
      _memoryCache[_storageKey] = jsonEncode(reservations);
    }
  }

  static Future<List<Map<String, dynamic>>> loadReservations() async {
    try {
      // SharedPreferencesから読み込み
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final reservations = decoded.cast<Map<String, dynamic>>();
        
        // メモリキャッシュも更新
        _memoryCache[_storageKey] = jsonString;
        
        if (kDebugMode) {
          print('Loaded ${reservations.length} reservations from persistent storage');
        }
        return reservations;
      }
      
      // SharedPreferencesにデータがない場合、メモリキャッシュを確認
      final cacheString = _memoryCache[_storageKey];
      if (cacheString != null) {
        final List<dynamic> decoded = jsonDecode(cacheString);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading reservations: $e');
      }
      
      // エラー時はメモリキャッシュから読み込み
      final cacheString = _memoryCache[_storageKey];
      if (cacheString != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cacheString);
          return decoded.cast<Map<String, dynamic>>();
        } catch (_) {
          return [];
        }
      }
    }
    return [];
  }

  static Future<void> clearReservations() async {
    try {
      // SharedPreferencesから削除
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      
      // メモリキャッシュからも削除
      _memoryCache.remove(_storageKey);
      
      if (kDebugMode) {
        print('Cleared all reservations from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing reservations: $e');
      }
      // エラー時でもメモリキャッシュは削除
      _memoryCache.remove(_storageKey);
    }
  }
  
  static Future<bool> hasReservations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_storageKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking reservations: $e');
      }
      return _memoryCache.containsKey(_storageKey);
    }
  }
}