# Hakkason Team H - 枕管理アプリ

ハッカソン Team H で開発した、枕の保証期間管理とメンテナンス予約機能を持つFlutterアプリです。

## 📱 対応プラットフォーム

| プラットフォーム | 対応状況 | 備考 |
|---|---|---|
| 🌐 **Web** | ✅ 対応済み | `flutter run -d chrome` |
| 🍎 **iOS** | ✅ 対応済み | `flutter run` (iOS Simulator) |
| 🤖 **Android** | ❌ 未対応 | Firebase設定が必要 |

## 🚀 クイックスタート

### 初心者向け
```bash
# 1. リポジトリをクローン
git clone [repository-url]
cd hakkason_team_h

# 2. 依存関係をインストール
flutter pub get

# 3. アプリを起動
flutter run
```

### 上級者向け
```bash
# Web版で起動
flutter run -d chrome

# iOS版で起動（macOS + Xcode必要）
flutter run -d ios

# デバッグモードでのホットリロード
flutter run --hot
```

## 🏗️ プロジェクト構成

```
lib/
├── main.dart                    # アプリエントリーポイント
├── firebase_options.dart        # Firebase設定（Web/iOS対応）
├── screens/                     # 画面コンポーネント
│   ├── home_view.dart          # ホーム画面
│   ├── reservation_view.dart   # 予約管理画面
│   ├── admin_view.dart         # 管理者画面（隠し機能）
│   ├── mymakura/               # マイ枕機能
│   │   ├── mymakura_view.dart
│   │   ├── components/         # UI部品
│   │   └── providers/          # 状態管理
│   └── news/                   # ニュース機能
├── services/                   # ビジネスロジック
│   ├── database_helper.dart    # SQLite操作
│   ├── notification_service.dart
│   └── reservation_storage.dart
└── shared/                     # 共通機能
    └── read_ids_provider.dart  # 既読管理
```

## 🛠️ 技術スタック

### フレームワーク・ライブラリ
- **Flutter** 3.6.2+ - クロスプラットフォーム開発
- **Riverpod** 2.3.6 - 状態管理
- **ShadCN Flutter** 0.0.44 - UI コンポーネント

### データベース・バックエンド
- **SQLite** (sqflite) - ローカルデータ保存
- **Firebase** - クラウドサービス
  - Cloud Firestore - ニュース記事保存
  - Firebase Auth - 認証（将来対応）

### UI・UX
- **Table Calendar** 3.2.0 - カレンダー表示
- **Material Design** - デザインシステム

## 🔥 主要機能

### 1. マイ枕管理 (`lib/screens/mymakura/`)
- 🛡️ **保証期間追跡** - 購入日から残り日数を自動計算
- 📊 **保証カード表示** - 視覚的な進捗表示
- ✏️ **購入日編集** - 日付の修正機能
- 📝 **更新履歴** - 変更履歴の追跡

### 2. 予約システム (`lib/screens/reservation_view.dart`)
- 📅 **カレンダー表示** - メンテナンス予約日程
- 💾 **ローカル保存** - SQLiteによるオフライン対応
- 🔔 **通知機能** - 予約リマインダー

### 3. ニュース機能 (`lib/screens/news/`)
- 📰 **記事一覧** - Firebase Firestoreから取得
- 👀 **既読管理** - 読んだ記事の追跡
- 🔗 **外部リンク** - WebView での記事表示

### 4. 管理者機能（隠し機能）
- ロゴを7回タップで管理画面を表示
- システム管理・デバッグ用

## ⚙️ 環境要件

### 最小要件
- **Flutter SDK** 3.6.2+
- **Dart SDK** 3.0+

### 開発環境
- **macOS** - iOS開発用（Xcodeが必要）
- **Windows/Linux** - Web開発のみ
- **Android Studio** または **VS Code**

### Firebase設定
```dart
// lib/firebase_options.dart で設定済み
- Web: 完全対応
- iOS: 完全対応  
- Android: 未設定（google-services.json が必要）
```

## 🐛 開発者向け情報

### よくある問題と解決方法

1. **アプリが起動時にクラッシュ**
   ```bash
   # Firebase設定を確認
   flutter clean
   flutter pub get
   ```

2. **Hot Reloadが効かない**
   ```bash
   # フルリスタート
   flutter run --hot
   # または 'R' キー
   ```

3. **依存関係エラー**
   ```bash
   flutter pub deps
   flutter pub upgrade
   ```

### デバッグ用コマンド
```bash
# コード解析
flutter analyze

# テスト実行
flutter test

# パフォーマンス分析
flutter run --profile
```

## 🔄 今後の対応予定

- [ ] **Android対応** - google-services.json 追加
- [ ] **Firebase Auth実装** - ユーザー認証
- [ ] **プッシュ通知** - リアルタイム通知
- [ ] **データ同期** - クラウド・ローカル同期

## 📄 ライセンス

プライベートプロジェクト - ハッカソン Team H
