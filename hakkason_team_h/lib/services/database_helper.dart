import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kaimin_yamaguchi.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  
  Future _createDB(Database db, int version) async {
    // 予約テーブル
    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        service_type TEXT NOT NULL,
        customer_number TEXT,
        concerns TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // 顧客テーブル
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_number TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        first_visit_date TEXT NOT NULL,
        last_visit_date TEXT NOT NULL,
        visit_count INTEGER DEFAULT 1,
        pillow_purchase_date TEXT,
        pillow_type TEXT,
        customer_segment TEXT DEFAULT 'newCustomer',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // 通知履歴テーブル  
    await db.execute('''
      CREATE TABLE notification_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        notification_type TEXT NOT NULL,
        message TEXT NOT NULL,
        sent_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');
    
    if (kDebugMode) {
      print('🗄️ Database initialized: kaimin_yamaguchi.db');
    }
  }
  
  // 予約関連メソッド
  Future<int> insertReservation(Map<String, dynamic> reservation) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    
    reservation['created_at'] = now;
    reservation['updated_at'] = now;
    
    final id = await db.insert('reservations', reservation);
    
    if (kDebugMode) {
      print('📅 Reservation inserted: ID=$id');
    }
    
    return id;
  }
  
  Future<List<Map<String, dynamic>>> getAllReservations() async {
    final db = await instance.database;
    return await db.query('reservations', orderBy: 'date DESC, time DESC');
  }
  
  Future<List<Map<String, dynamic>>> getReservationsByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'reservations',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time',
    );
  }
  
  Future<int> updateReservation(int id, Map<String, dynamic> reservation) async {
    final db = await instance.database;
    reservation['updated_at'] = DateTime.now().toIso8601String();
    
    return await db.update(
      'reservations',
      reservation,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> deleteReservation(int id) async {
    final db = await instance.database;
    return await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // 顧客関連メソッド
  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    
    customer['created_at'] = now;
    customer['updated_at'] = now;
    customer['first_visit_date'] = now;
    customer['last_visit_date'] = now;
    
    final id = await db.insert('customers', customer);
    
    if (kDebugMode) {
      print('👤 Customer inserted: ID=$id, Number=${customer['customer_number']}');
    }
    
    return id;
  }
  
  Future<Map<String, dynamic>?> getCustomerByNumber(String customerNumber) async {
    final db = await instance.database;
    final results = await db.query(
      'customers',
      where: 'customer_number = ?',
      whereArgs: [customerNumber],
    );
    
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<List<Map<String, dynamic>>> getCustomersBySegment(String segment) async {
    final db = await instance.database;
    return await db.query(
      'customers',
      where: 'customer_segment = ?',
      whereArgs: [segment],
    );
  }
  
  Future<int> updateCustomerVisit(String customerNumber) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    
    // 訪問回数を増やして最終訪問日を更新
    return await db.rawUpdate('''
      UPDATE customers 
      SET visit_count = visit_count + 1,
          last_visit_date = ?,
          updated_at = ?
      WHERE customer_number = ?
    ''', [now, now, customerNumber]);
  }
  
  // 通知履歴関連メソッド
  Future<int> insertNotificationHistory(Map<String, dynamic> notification) async {
    final db = await instance.database;
    notification['sent_at'] = DateTime.now().toIso8601String();
    
    return await db.insert('notification_history', notification);
  }
  
  Future<List<Map<String, dynamic>>> getUnreadNotifications(int customerId) async {
    final db = await instance.database;
    return await db.query(
      'notification_history',
      where: 'customer_id = ? AND is_read = 0',
      whereArgs: [customerId],
      orderBy: 'sent_at DESC',
    );
  }
  
  // 統計・分析メソッド
  Future<Map<String, int>> getReservationStats() async {
    final db = await instance.database;
    
    // 今月の予約数
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
    
    final thisMonth = await db.rawQuery('''
      SELECT COUNT(*) as count FROM reservations 
      WHERE date >= ? AND date < ?
    ''', [monthStart, DateTime(now.year, now.month + 1, 1).toIso8601String().substring(0, 10)]);
    
    // サービス別統計
    final serviceStats = await db.rawQuery('''
      SELECT service_type, COUNT(*) as count 
      FROM reservations 
      GROUP BY service_type
    ''');
    
    final stats = <String, int>{
      'total_reservations': (await db.rawQuery('SELECT COUNT(*) as count FROM reservations')).first['count'] as int,
      'monthly_reservations': thisMonth.first['count'] as int,
      'total_customers': (await db.rawQuery('SELECT COUNT(*) as count FROM customers')).first['count'] as int,
    };
    
    // サービス別統計を追加
    for (final service in serviceStats) {
      stats[service['service_type'] as String] = service['count'] as int;
    }
    
    return stats;
  }
  
  // データベースクリーンアップ
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    
    if (kDebugMode) {
      print('🗄️ Database closed');
    }
  }
  
  // 開発・デバッグ用メソッド
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('reservations');
    await db.delete('customers');
    await db.delete('notification_history');
    
    if (kDebugMode) {
      print('🗑️ All data cleared from database');
    }
  }
}