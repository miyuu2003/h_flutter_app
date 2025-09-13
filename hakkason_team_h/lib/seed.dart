// lib/seed.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedNews() async {
  final news = [
    {
      'title': 'レンタル枕の新サービスをご紹介',
      'excerpt': '3ヶ月ごとの調整プランとセットでお得に…',
      'publishedAt': DateTime(2025, 9, 10),
    },
    {
      'title': '自分のカラダ分析ができるようになりました',
      'excerpt': '睡眠傾向のスコア化で「次の調整タイミング」が分かる',
      'publishedAt': DateTime(2025, 9, 8),
    },
    {
      'title': '今週末のストレッチ体験会',
      'excerpt': '店内イベントのお知らせ。参加無料・予約不要です',
      'publishedAt': DateTime(2025, 9, 7),
    },
    {
      'title': '秋の快眠キャンペーン開催',
      'excerpt': '枕＋布団セットが20%OFF。今だけの限定企画！',
      'publishedAt': DateTime(2025, 9, 5),
    },
    {
      'title': '睡眠アドバイザーによる無料相談会',
      'excerpt': '専門スタッフがあなたに合う枕の選び方を伝授します',
      'publishedAt': DateTime(2025, 9, 3),
    },
  ];

  final col = FirebaseFirestore.instance.collection('news');
  for (var n in news) {
    await col.add({
      'title': n['title'],
      'excerpt': n['excerpt'],
      'publishedAt': Timestamp.fromDate(n['publishedAt'] as DateTime),
    });
  }
  print("✅ ダミーニュースを登録しました！");
}
