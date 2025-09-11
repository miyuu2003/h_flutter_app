import 'package:flutter/foundation.dart';

// 通知タイプ
enum NotificationType {
  reservationConfirm,    // 予約確認
  reminder24h,           // 24時間前リマインダー  
  reminder1h,            // 1時間前リマインダー
  maintenanceReminder,   // メンテナンス案内
  newsUpdate,            // お知らせ
  specialOffer,          // 特別オファー
}

// 顧客セグメント
enum CustomerSegment {
  newCustomer,       // 新規客
  regularCustomer,   // リピート客
  vipCustomer,       // VIP客（年3回以上利用）
  dormantCustomer,   // 休眠客（1年以上来店なし）
}

class NotificationService {
  // LINE制限を回避する通知システム
  static Future<void> sendNotificationToAll({
    required NotificationType type,
    required String message,
    CustomerSegment? targetSegment,
  }) async {
    final customers = await _getCustomerList(targetSegment);
    
    if (kDebugMode) {
      print('📱 ${customers.length}人に通知送信: $message');
    }
    
    // バッチ処理で送信（サーバー負荷分散）
    for (int i = 0; i < customers.length; i += 50) {
      final batch = customers.skip(i).take(50).toList();
      await _sendBatch(batch, type, message);
      
      // 0.5秒待機（スパム防止）
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  // 予約確認通知
  static Future<void> sendReservationConfirmation({
    required String customerName,
    required String date,
    required String time,
    required String serviceType,
  }) async {
    final message = '''
🎊 予約確認

$customerName 様
$date $time
$serviceType のご予約を承りました。

📍 快眠本舗ヤマグチ
📞 072-761-8097
🗺️ 石橋阪大前駅 西口徒歩3分

※前日にリマインダーをお送りします
''';

    await _sendToCustomer(customerName, NotificationType.reservationConfirm, message);
  }
  
  // リマインダー通知
  static Future<void> sendReminder({
    required String customerName,
    required String date,
    required String time,
    required String serviceType,
    bool is24HoursBefore = true,
  }) async {
    final timing = is24HoursBefore ? '明日' : '1時間後';
    final message = '''
⏰ ${is24HoursBefore ? '明日の' : '間もなく'}ご予約です

$customerName 様
$timing $time より
$serviceType でお待ちしております。

🏪 快眠本舗ヤマグチ
📍 池田市石橋1-15-7

何かご不明な点がございましたら
お気軽にお電話ください 📞072-761-8097
''';

    final type = is24HoursBefore 
        ? NotificationType.reminder24h 
        : NotificationType.reminder1h;
        
    await _sendToCustomer(customerName, type, message);
  }
  
  // メンテナンス案内
  static Future<void> sendMaintenanceReminder(CustomerSegment segment) async {
    final message = '''
🛠️ 枕のメンテナンスはいかがですか？

購入から時間が経つと、中材がへたることがあります。
10年間無料調整サービスをご活用ください！

✅ 高さ調整
✅ 硬さ調整  
✅ 寝心地チェック

ご予約は以下より
📱 アプリ内予約システム
📞 072-761-8097

快適な眠りをサポートします 😴
''';

    await sendNotificationToAll(
      type: NotificationType.maintenanceReminder,
      message: message,
      targetSegment: segment,
    );
  }
  
  // お知らせ・特別オファー
  static Future<void> sendSpecialOffer() async {
    final message = '''
🎉 期間限定キャンペーン

石橋商店街連携企画！
オーダーメイド枕ご購入で
近隣店舗で使える500円クーポンプレゼント🎁

📅 期間: 今月末まで
🏪 対象: 快眠本舗ヤマグチでの新規オーダー

地域の皆様との繋がりを大切に
より良い眠りをお届けします 💤
''';

    await sendNotificationToAll(
      type: NotificationType.specialOffer,
      message: message,
    );
  }

  // プライベートメソッド
  static Future<List<String>> _getCustomerList(CustomerSegment? segment) async {
    // 実際の実装では顧客データベースから取得
    // セグメント別にフィルタリング
    await Future.delayed(const Duration(milliseconds: 100));
    
    switch (segment) {
      case CustomerSegment.newCustomer:
        return ['新規客A', '新規客B', '新規客C'];
      case CustomerSegment.regularCustomer:
        return List.generate(150, (i) => 'リピート客${i + 1}');
      case CustomerSegment.vipCustomer:
        return List.generate(80, (i) => 'VIP客${i + 1}');
      case CustomerSegment.dormantCustomer:
        return List.generate(200, (i) => '休眠客${i + 1}');
      case null:
        return List.generate(500, (i) => '全顧客${i + 1}');
    }
  }
  
  static Future<void> _sendBatch(List<String> customers, NotificationType type, String message) async {
    // 実際の通知送信処理
    if (kDebugMode) {
      print('📨 ${customers.length}人のバッチ送信完了: ${type.name}');
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
  
  static Future<void> _sendToCustomer(String customerName, NotificationType type, String message) async {
    // 個別通知送信
    if (kDebugMode) {
      print('📱 $customerName に${type.name}送信: ${message.substring(0, 20)}...');
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
}