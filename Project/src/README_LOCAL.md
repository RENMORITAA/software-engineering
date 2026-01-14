# Stellar Delivery - フードデリバリープラットフォーム

完全にローカルで動作するFlutter Webアプリケーション

## 概要

Stellar Deliveryは、高知県香美市を対象としたフードデリバリープラットフォームです。
このアプリケーションは完全にローカルで動作し、外部APIへの依存がありません。

## 機能

### ユーザー管理
- ✅ ユーザー認証（ローカルモック）
- ✅ ユーザー登録
- ✅ ログイン/ログアウト
- ✅ プロフィール管理

### 依頼者機能
- ✅ 商品一覧表示
- ✅ ショッピングカート
- ✅ 注文履歴
- ✅ マイページ

### 配達員機能
- ✅ 配達ジョブ一覧
- ✅ 配達地図
- ✅ 配達履歴
- ✅ プロフィール管理

### 店舗機能
- ✅ 注文管理
- ✅ 商品管理
- ✅ プロフィール設定

## クイックスタート

### 必要な環境
- Flutter 3.10.1以上
- Dart 3.10.1以上
- Google Chrome（推奨）

### 実行方法

#### Windows（PowerShell推奨）
```powershell
.\run_local.ps1
```

#### Windows（コマンドプロンプト）
```cmd
run_local.bat
```

#### Linux/Mac
```bash
chmod +x run_local.sh
./run_local.sh
```

### または手動実行
```bash
cd src
flutter pub get
flutter run -d chrome --web-port=8080
```

### Dockerで起動する

```bash
docker compose up --build

# 初回後の再起動（変更を反映したい場合も同じ）
docker compose up
```

- アプリ: http://localhost:8080
- バックエンド: http://localhost:8000
- データベース: localhost:5432 (postgres/postgres)

**環境変数（docker-compose.ymlで設定済み）**
- ENV=docker
- USE_MOCK_API=false
- API_BASE_URL=http://localhost:8000

## テストアカウント

| ロール | Email | パスワード |
|--------|-------|-----------|
| 依頼者 | requester@example.com | password123 |
| 配達員 | deliverer@example.com | password123 |
| 店舗 | store@example.com | password123 |

## プロジェクト構成

```
src/
├── lib/
│   ├── main.dart                 # エントリーポイント
│   ├── config/                   # 設定ファイル
│   │   ├── routes.dart           # ルーティング設定
│   │   ├── theme.dart            # テーマ設定
│   │   └── env_config.dart       # 環境設定
│   ├── services/
│   │   ├── api_service.dart      # API通信（モック対応）
│   │   ├── mock_api_service.dart # モックAPI実装
│   │   ├── auth_service.dart     # 認証サービス
│   │   └── ...
│   ├── page/                     # ページコンポーネント
│   ├── screens/                  # スクリーンコンポーネント
│   ├── widgets/                  # ウィジェット
│   ├── provider/                 # 状態管理（Provider）
│   ├── utils/                    # ユーティリティ
│   └── models/                   # データモデル
├── assets/                       # アセットファイル
│   ├── images/                   # 画像ファイル
│   ├── fonts/                    # フォントファイル
│   └── data/                     # データファイル
├── web/                          # Web設定
├── pubspec.yaml                  # 依存パッケージ管理
├── LOCAL_RUN_GUIDE.md           # 詳細な実行ガイド
├── run_local.bat                # Windows実行スクリプト
├── run_local.ps1                # PowerShell実行スクリプト
└── run_local.sh                 # Linux/Mac実行スクリプト
```

## 認証フロー

1. **ログイン/登録** → ローカルモックで認証
2. **トークン保存** → SharedPreferencesに保存
3. **セッション管理** → AuthGuardで保護
4. **自動リダイレクト** → ロールに応じてホーム画面へ

## API仕様（ローカルモック）

すべてのAPI呼び出しは`MockApiService`で処理されます：

| エンドポイント | メソッド | 説明 |
|---------------|---------|------|
| `/auth/login` | POST | ユーザーログイン |
| `/auth/register` | POST | ユーザー登録 |
| `/auth/me` | GET | ユーザー情報取得 |
| `/profile/requester` | GET/PUT | 依頼者プロフィール |
| `/profile/deliverer` | GET/PUT | 配達員プロフィール |
| `/profile/store` | GET/PUT | 店舗プロフィール |
| `/products` | GET | 商品一覧 |

## トラブルシューティング

### ビルドエラー
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### ポート8080が使用中
```bash
flutter run -d chrome --web-port=8081
```

### キャッシュをリセット
```bash
flutter clean
rm -r .dart_tool
flutter pub get
flutter run -d chrome
```

## ローカルストレージ

アプリケーションは以下の情報をローカルに保存します：
- `auth_token` - 認証トークン
- `current_user` - ユーザー情報
- `user_role` - ユーザーロール
- `login_time` - ログイン時刻

ブラウザの開発者ツール（F12）で確認できます。

## 開発環境設定

### 環境変数の指定
```bash
# ローカル（デフォルト、モック使用）
flutter run -d chrome --dart-define=ENV=local

# 本番環境をシミュレート（実際のAPIが必要）
flutter run -d chrome --dart-define=ENV=production --dart-define=API_BASE_URL=http://localhost:8000
```

## ビルド

### Web版のビルド
```bash
flutter build web --release
```

出力: `build/web/` ディレクトリ

## ライセンス

このプロジェクトはプライベートプロジェクトです。

## サポート

問題や質問がある場合は、プロジェクトの管理者に連絡してください。
