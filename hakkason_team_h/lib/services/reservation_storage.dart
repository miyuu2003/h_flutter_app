import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class ReservationStorage {
  static const String _storageKey = 'reservations';
  static const String _migrationKey = 'db_migrated';

  // データベース連携版の保存
  static Future<void> saveReservations(List<Map<String, dynamic>> reservations) async {
    try {
      // 既存データのマイグレーション（初回のみ）
      await _migrateToDatabase();
      
      // データベースには個別保存されるため、この機能は互換性のため残す
      final jsonString = jsonEncode(reservations);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonString);
      
      if (kDebugMode) {
        print('💾 Saved ${reservations.length} reservations (compatibility mode)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving reservations: $e');
      }
    }
  }

  // データベース連携版の読み込み
  static Future<List<Map<String, dynamic>>> loadReservations() async {
    try {
      // Web版では直接SharedPreferencesから読み込み
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final jsonString = prefs.getString(_storageKey);
        
        if (jsonString != null) {
          final List<dynamic> decoded = jsonDecode(jsonString);
          final reservations = decoded.cast<Map<String, dynamic>>();
          
          if (kDebugMode) {
            print('📁 Loaded ${reservations.length} reservations from web storage');
          }
          return reservations;
        }
        return [];
      }
      
      // データベースから読み込み（モバイル版）
      final dbReservations = await DatabaseHelper.instance.getAllReservations();
      
      if (dbReservations.isNotEmpty) {
        if (kDebugMode) {
          print('📁 Loaded ${dbReservations.length} reservations from database');
        }
        return dbReservations;
      }
      
      // フォールバック: SharedPreferencesから読み込み
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final reservations = decoded.cast<Map<String, dynamic>>();
        
        if (kDebugMode) {
          print('📁 Loaded ${reservations.length} reservations from SharedPreferences (fallback)');
        }
        
        // データベースに移行
        for (final reservation in reservations) {
          await _insertReservationToDB(reservation);
        }
        
        return reservations;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading reservations: $e');
      }
    }
    return [];
  }
  
  // 新規予約の保存（データベース優先）
  static Future<int?> saveReservation(Map<String, dynamic> reservation) async {
    try {
      // Web版では SharedPreferences に保存
      if (kIsWeb) {
        final existing = await loadReservations();
        
        // 新しい予約にIDを付与
        final newReservation = Map<String, dynamic>.from(reservation);
        newReservation['id'] = DateTime.now().millisecondsSinceEpoch;
        newReservation['customer_number'] ??= _generateCustomerNumber();
        
        existing.add(newReservation);
        await saveReservations(existing);
        
        if (kDebugMode) {
          print('✅ Reservation saved to web storage: ID=${newReservation['id']}');
        }
        
        return newReservation['id'] as int;
      }
      
      // モバイル版ではデータベースに保存
      // 顧客番号がある場合は既存客として処理
      if (reservation['customer_number'] != null) {
        await DatabaseHelper.instance.updateCustomerVisit(reservation['customer_number']);
      } else {
        // 新規客の場合は顧客番号を生成
        final customerNumber = _generateCustomerNumber();
        reservation['customer_number'] = customerNumber;
        
        await DatabaseHelper.instance.insertCustomer({
          'customer_number': customerNumber,
          'name': reservation['name'],
          'phone': reservation['phone'],
          'email': reservation['email'] ?? '',
          'customer_segment': 'newCustomer',
        });
      }
      
      // 予約をデータベースに保存
      final reservationId = await DatabaseHelper.instance.insertReservation({
        'date': reservation['date'],
        'time': reservation['time'],
        'name': reservation['name'],
        'phone': reservation['phone'],
        'email': reservation['email'] ?? '',
        'service_type': reservation['serviceType'],
        'customer_number': reservation['customer_number'],
        'concerns': reservation['concerns'] ?? '',
      });
      
      if (kDebugMode) {
        print('✅ Reservation saved to database: ID=$reservationId');
      }
      
      return reservationId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving reservation: $e');
      }
      return null;
    }
  }
  
  // 予約の削除
  static Future<bool> deleteReservation(int reservationId) async {
    try {
      final result = await DatabaseHelper.instance.deleteReservation(reservationId);
      
      if (kDebugMode) {
        print('🗑️ Deleted reservation: ID=$reservationId, Result=$result');
      }
      
      return result > 0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting reservation: $e');
      }
      return false;
    }
  }
  
  // 日付別予約取得
  static Future<List<Map<String, dynamic>>> getReservationsByDate(String date) async {
    try {
      if (kIsWeb) {
        // Web版では全予約を読み込んで日付でフィルタリング
        final allReservations = await loadReservations();
        return allReservations.where((r) => r['date'] == date).toList();
      }
      return await DatabaseHelper.instance.getReservationsByDate(date);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting reservations by date: $e');
      }
      return [];
    }
  }
  
  // 統計情報取得
  static Future<Map<String, int>> getReservationStats() async {
    try {
      return await DatabaseHelper.instance.getReservationStats();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting reservation stats: $e');
      }
      return {};
    }
  }
  
  // 既存客の検索
  static Future<Map<String, dynamic>?> findExistingCustomer(String customerNumber) async {
    try {
      return await DatabaseHelper.instance.getCustomerByNumber(customerNumber);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error finding customer: $e');
      }
      return null;
    }
  }
  
  // 全データクリア（開発・テスト用）
  static Future<void> clearReservations() async {
    try {
      await DatabaseHelper.instance.clearAllData();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      
      if (kDebugMode) {
        print('🗑️ Cleared all reservation data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing reservations: $e');
      }
    }
  }
  
  // プライベートメソッド
  static Future<void> _migrateToDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasMigrated = prefs.getBool(_migrationKey) ?? false;
      
      if (hasMigrated) return;
      
      // SharedPreferencesからデータベースへ移行
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final reservations = decoded.cast<Map<String, dynamic>>();
        
        for (final reservation in reservations) {
          await _insertReservationToDB(reservation);
        }
        
        if (kDebugMode) {
          print('🔄 Migrated ${reservations.length} reservations to database');
        }
      }
      
      await prefs.setBool(_migrationKey, true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Migration error: $e');
      }
    }
  }
  
  static Future<void> _insertReservationToDB(Map<String, dynamic> reservation) async {
    // 古いフォーマットを新しいフォーマットに変換
    final dbReservation = <String, dynamic>{
      'date': reservation['date'],
      'time': reservation['time'],
      'name': reservation['name'],
      'phone': reservation['phone'],
      'email': reservation['email'] ?? '',
      'service_type': reservation['serviceType'] ?? reservation['futonType'] ?? 'オーダーメイド枕測定',
      'customer_number': reservation['customer_number'] ?? _generateCustomerNumber(),
      'concerns': reservation['concerns'] ?? '',
    };
    
    await DatabaseHelper.instance.insertReservation(dbReservation);
  }
  
  static String _generateCustomerNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    
    return 'KY-$year$month-$random';
  }
  
  // データベース接続確認
  static Future<bool> isDatabaseConnected() async {
    try {
      final stats = await getReservationStats();
      return stats.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}