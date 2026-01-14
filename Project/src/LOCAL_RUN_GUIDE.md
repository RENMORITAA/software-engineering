# ローカル実行ガイド

このアプリケーションは完全にローカルで動作するようにセットアップされています。

## 前提条件
- Flutter 3.10.1以上
- Dart 3.10.1以上
- ブラウザ（Google Chrome推奨）

## セットアップ手順

### 1. 依存パッケージをインストール

```bash
cd "C:\Users\mrenk\software-engineering\Project\src"
flutter pub get
```

### 2. アプリを起動（Web版）

```bash
# Chrome ブラウザで起動
flutter run -d chrome
```

または

```bash
# 特定のポート番号を指定して起動
flutter run -d chrome --web-port=8080
```

### 3. アプリにアクセス

ブラウザで以下のURLにアクセス：
- http://localhost:8080 （デフォルト）
- http://localhost:8080/login （ログイン画面）
- http://localhost:8080/requester/home （依頼者ホーム）

## テストアカウント

### 依頼者アカウント
- Email: `requester@example.com`
- Password: `password123`
- Role: requester

### 配達員アカウント
- Email: `deliverer@example.com`
- Password: `password123`
- Role: deliverer

### 店舗アカウント
- Email: `store@example.com`
- Password: `password123`
- Role: store

## 機能

### 実装済み
- ✅ ユーザー認証（ローカルモック）
- ✅ ユーザー登録
- ✅ ログイン/ログアウト
- ✅ 依頼者画面
- ✅ 配達員画面
- ✅ 店舗画面
- ✅ プロフィール管理
- ✅ ローカルストレージ

### モック実装
すべてのAPI呼び出しはモックで処理されます：
- `/auth/login` - ユーザー認証
- `/auth/register` - ユーザー登録
- `/auth/me` - ユーザー情報取得
- `/profile/*` - プロフィール取得/更新
- `/products` - 商品一覧

## トラブルシューティング

### ビルドエラーが出る場合

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### ポート8080が使用中の場合

```bash
# 別のポートを指定
flutter run -d chrome --web-port=8081
```

### 3. Dockerで起動（フロント/バックエンド/DBまとめて）

```bash
cd "C:\Users\mrenk\software-engineering\Project"
docker compose up --build
```

アクセス先:
- フロントエンド: http://localhost:8080
- バックエンド: http://localhost:8000
### キャッシュをリセットしたい場合

```bash
flutter clean
rm -r .dart_tool
flutter pub get
flutter run -d chrome
```

## ローカルAPI モックの詳細

### MockApiService
- ファイル: `lib/services/mock_api_service.dart`
- すべてのAPI呼び出しをインターセプトします
- レスポンスはダミーデータで返されます
- 実際のAPI呼び出しはスキップされます

### モック有効化条件
- `USE_MOCK_API=true` もしくは `ENV=local` のときにモックを使用
- Docker起動時は `USE_MOCK_API=false` で実APIに接続

### 環境変数の指定

```bash
# 本番環境をシミュレート（実際のAPIが必要）
flutter run -d chrome --dart-define=ENV=production --dart-define=API_BASE_URL=http://localhost:8000

# ローカル環境（デフォルト）
flutter run -d chrome --dart-define=ENV=local
```

## 開発時の注意点

### シェアード設定のリセット

開発中にSharedPreferencesをリセットしたい場合は、以下のコードを実行：

```dart
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

### ブラウザの開発者ツール

- F12 キーで開発者ツールを開く
- Console タブでログを確認
- Storage タブでLocalStorageを確認

## ビルド

### Web ビルド

```bash
flutter build web
```

出力: `build/web/` ディレクトリ

### その他のプラットフォーム

現在、Web版のみ実装されています。Android/iOS対応は後続の実装で行います。
