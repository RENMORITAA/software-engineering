# Stellar Delivery - システム技術ドキュメント

## 📋 目次

1. [プロジェクト概要](#1-プロジェクト概要)
2. [システムアーキテクチャ](#2-システムアーキテクチャ)
3. [技術スタック](#3-技術スタック)
4. [データベース設計](#4-データベース設計)
5. [API設計](#5-api設計)
6. [フロントエンド設計](#6-フロントエンド設計)
7. [認証・セキュリティ](#7-認証セキュリティ)
8. [ユーザーロールと機能](#8-ユーザーロールと機能)
9. [注文フロー](#9-注文フロー)
10. [配達管理システム](#10-配達管理システム)
11. [通知システム](#11-通知システム)
12. [決済・売上管理](#12-決済売上管理)
13. [デプロイ構成](#13-デプロイ構成)
14. [開発・運用情報](#14-開発運用情報)

---

## 1. プロジェクト概要

### 1.1 アプリケーション名
**Stellar Delivery（ステラデリバリー）**

### 1.2 概要
大学キャンパス内で利用可能なフードデリバリーサービスアプリケーション。学生が店舗から料理を注文し、配達員が配達するマッチングプラットフォーム。

### 1.3 主要機能
- **依頼者（Requester）**: 店舗検索、商品注文、配達追跡
- **配達員（Deliverer）**: 配達ジョブ受付、位置情報更新、配達履歴管理
- **店舗（Store）**: 商品管理、注文管理、売上管理

### 1.4 対象ユーザー
- 高知工科大学の学生・教職員
- キャンパス周辺の飲食店
- 配達員として働きたい学生

---

## 2. システムアーキテクチャ

### 2.1 全体構成図

```
┌─────────────────────────────────────────────────────────────────┐
│                        クライアント層                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Flutter Web Application                     │   │
│  │  (Dart / Provider / HTTP Client)                        │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST API
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        リバースプロキシ層                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Nginx                                 │   │
│  │  - 静的ファイル配信 (Flutter Web)                        │   │
│  │  - APIリクエストプロキシ (/api/* → backend:8000)         │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        アプリケーション層                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              FastAPI Backend (Python 3.11)               │   │
│  │  - RESTful API                                           │   │
│  │  - JWT認証                                               │   │
│  │  - SQLAlchemy ORM                                        │   │
│  │  - Pydantic バリデーション                               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        データ層                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              PostgreSQL 15                               │   │
│  │  - リレーショナルDB                                      │   │
│  │  - Docker Volume永続化                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 コンテナ構成

| コンテナ名 | イメージ | ポート | 役割 |
|-----------|---------|--------|------|
| `flutter_web` | nginx:alpine | 80 | フロントエンド配信 + リバースプロキシ |
| `fastapi_backend` | python:3.11-slim | 8000 | REST API サーバー |
| `postgres_db` | postgres:15 | 5432 | データベース |

### 2.3 ネットワーク構成

```
外部アクセス
     │
     ▼ Port 80
┌────────────────┐
│  Nginx (80)    │
│                │
│  /api/* ──────────────┐
│  /*     → 静的ファイル │
└────────────────┘      │
                        ▼ Port 8000
                ┌────────────────┐
                │  FastAPI       │
                │  (8000)        │
                │                │
                │  DB接続 ───────────┐
                └────────────────┘   │
                                     ▼ Port 5432
                             ┌────────────────┐
                             │  PostgreSQL    │
                             │  (5432)        │
                             └────────────────┘
```

---

## 3. 技術スタック

### 3.1 フロントエンド

| 技術 | バージョン | 用途 |
|------|-----------|------|
| **Flutter** | 3.x | クロスプラットフォームUIフレームワーク |
| **Dart** | 3.x | プログラミング言語 |
| **Provider** | - | 状態管理 |
| **http** | - | HTTP通信 |
| **shared_preferences** | - | ローカルストレージ |
| **image_picker** | - | 画像選択 |
| **geolocator** | - | 位置情報取得 |
| **Leaflet.js** | - | 地図表示（Web） |

### 3.2 バックエンド

| 技術 | バージョン | 用途 |
|------|-----------|------|
| **Python** | 3.11 | プログラミング言語 |
| **FastAPI** | - | Webフレームワーク |
| **SQLAlchemy** | - | ORM |
| **Pydantic** | - | データバリデーション |
| **python-jose** | - | JWT処理 |
| **passlib** | - | パスワードハッシュ化 |
| **bcrypt** | - | 暗号化アルゴリズム |
| **fastapi-mail** | - | メール送信 |
| **uvicorn** | - | ASGIサーバー |

### 3.3 データベース

| 技術 | バージョン | 用途 |
|------|-----------|------|
| **PostgreSQL** | 15 | リレーショナルデータベース |

### 3.4 インフラ

| 技術 | 用途 |
|------|------|
| **Docker** | コンテナ化 |
| **Docker Compose** | コンテナオーケストレーション |
| **Nginx** | リバースプロキシ・静的ファイル配信 |
| **AWS EC2** | クラウドホスティング |

---

## 4. データベース設計

### 4.1 ER図（概念）

```
┌──────────────────┐
│      users       │
│  (全ユーザー)     │
└────────┬─────────┘
         │ 1
         │
    ┌────┴────┬─────────────┐
    │ 1       │ 1           │ 1
    ▼         ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│requester│ │deliverer│ │  store  │
│_profiles│ │_profiles│ │_profiles│
└────┬────┘ └────┬────┘ └────┬────┘
     │           │           │
     │ 1:N       │ 1:N       │ 1:N
     ▼           │           ▼
┌─────────┐      │      ┌─────────┐
│addresses│      │      │products │
└─────────┘      │      └────┬────┘
                 │           │
     ┌───────────┴───────────┤
     │                       │
     ▼                       ▼
┌─────────────────────────────────┐
│            orders               │
│  (requester_id, store_id,       │
│   deliverer_id)                 │
└────────────────┬────────────────┘
                 │
        ┌────────┼────────┐
        │        │        │
        ▼        ▼        ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│ order   │ │deliveries│ │payments │
│ details │ │         │ │         │
└─────────┘ └─────────┘ └─────────┘
```

### 4.2 テーブル一覧

| テーブル名 | 説明 | 主要カラム |
|-----------|------|-----------|
| `users` | 全ユーザーの認証情報 | id, email, password, role |
| `requester_profiles` | 依頼者詳細情報 | user_id, name, phone_number |
| `requester_addresses` | 依頼者の住所（複数） | requester_id, address_line1, is_default |
| `deliverer_profiles` | 配達員詳細情報 | user_id, name, vehicle_type, bank_* |
| `store_profiles` | 店舗詳細情報 | user_id, store_name, address, business_hours |
| `product_categories` | 商品カテゴリ | store_id, name |
| `products` | 商品情報 | store_id, name, price, is_available |
| `orders` | 注文情報 | requester_id, store_id, deliverer_id, status |
| `order_details` | 注文明細 | order_id, product_id, quantity, unit_price |
| `deliveries` | 配達情報 | order_id, deliverer_id, status |
| `delivery_location_history` | 配達員位置履歴 | delivery_id, latitude, longitude |
| `notifications` | 通知 | user_id, title, message, type |
| `payments` | 支払い情報 | order_id, amount, payment_status |
| `deliverer_payouts` | 配達員給与 | deliverer_id, total_amount, status |
| `store_sales` | 店舗売上 | store_id, total_amount, commission_amount |

### 4.3 主要テーブル詳細

#### 4.3.1 users テーブル

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,          -- bcryptハッシュ
    role VARCHAR(20) NOT NULL,               -- 'requester', 'deliverer', 'store', 'admin'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**ロール定義:**
| ロール | 説明 |
|--------|------|
| `requester` | 依頼者（注文する側） |
| `deliverer` | 配達員 |
| `store` | 店舗 |
| `admin` | 管理者 |

#### 4.3.2 orders テーブル

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    requester_id INTEGER NOT NULL REFERENCES requester_profiles(id),
    store_id INTEGER NOT NULL REFERENCES store_profiles(id),
    deliverer_id INTEGER REFERENCES deliverer_profiles(id),
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    subtotal INTEGER NOT NULL,               -- 商品小計（円）
    delivery_fee INTEGER NOT NULL DEFAULT 0, -- 配達料（円）
    total_price INTEGER NOT NULL,            -- 合計金額（円）
    delivery_address VARCHAR(500) NOT NULL,
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    notes TEXT,
    estimated_delivery_time TIMESTAMP,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancel_reason TEXT
);
```

**注文ステータス:**
| ステータス | 説明 | 次のステータス |
|-----------|------|---------------|
| `pending` | 注文受付待ち | accepted, cancelled |
| `accepted` | 店舗が受付 | preparing, cancelled |
| `preparing` | 調理中 | ready_for_pickup |
| `ready_for_pickup` | 受け取り準備完了 | picked_up |
| `picked_up` | 配達員が受け取り | delivering |
| `delivering` | 配達中 | delivered |
| `delivered` | 配達完了 | - |
| `cancelled` | キャンセル | - |

#### 4.3.3 deliveries テーブル

```sql
CREATE TABLE deliveries (
    id SERIAL PRIMARY KEY,
    order_id INTEGER UNIQUE NOT NULL REFERENCES orders(id),
    deliverer_id INTEGER NOT NULL REFERENCES deliverer_profiles(id),
    status VARCHAR(30) NOT NULL DEFAULT 'assigned',
    pickup_time TIMESTAMP,
    delivery_time TIMESTAMP,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    distance_km DECIMAL(5, 2),
    delivery_fee INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**配達ステータス:**
| ステータス | 説明 |
|-----------|------|
| `assigned` | 配達員に割り当て |
| `heading_store` | 店舗へ向かっている |
| `at_store` | 店舗に到着 |
| `picked_up` | 商品を受け取った |
| `delivering` | 配達中 |
| `arrived` | 配達先に到着 |
| `completed` | 完了 |

### 4.4 インデックス

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_orders_requester ON orders(requester_id);
CREATE INDEX idx_orders_store ON orders(store_id);
CREATE INDEX idx_orders_deliverer ON orders(deliverer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_products_store ON products(store_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_deliveries_deliverer ON deliveries(deliverer_id);
```

---

## 5. API設計

### 5.1 API概要

- **ベースURL**: `http://34.193.170.210/api`
- **認証方式**: Bearer Token (JWT)
- **データ形式**: JSON
- **ドキュメント**: `http://34.193.170.210/api/docs` (Swagger UI)

### 5.2 エンドポイント一覧

#### 5.2.1 認証 API (`/auth`)

| メソッド | エンドポイント | 説明 | 認証 |
|---------|---------------|------|------|
| POST | `/auth/register` | 新規ユーザー登録 | 不要 |
| POST | `/auth/login` | ログイン（トークン取得） | 不要 |
| GET | `/auth/me` | 現在のユーザー情報取得 | 必要 |
| POST | `/auth/password-reset-request` | パスワードリセット要求 | 不要 |
| DELETE | `/auth/withdraw` | 退会（アカウント削除） | 必要 |

**登録リクエスト例:**
```json
POST /auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "role": "requester",
  "name": "山田太郎"
}
```

**ログインリクエスト例:**
```
POST /auth/login
Content-Type: application/x-www-form-urlencoded

username=user@example.com&password=password123
```

**ログインレスポンス例:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer"
}
```

#### 5.2.2 プロフィール API (`/profile`)

| メソッド | エンドポイント | 説明 | 対象ロール |
|---------|---------------|------|-----------|
| GET | `/profile/requester` | 依頼者プロフィール取得 | requester |
| PUT | `/profile/requester` | 依頼者プロフィール更新 | requester |
| GET | `/profile/deliverer` | 配達員プロフィール取得 | deliverer |
| PUT | `/profile/deliverer` | 配達員プロフィール更新 | deliverer |
| GET | `/profile/store` | 店舗プロフィール取得 | store |
| PUT | `/profile/store` | 店舗プロフィール更新 | store |
| PUT | `/profile/{role}/banking` | 口座情報更新 | all |
| GET | `/profile/requester/addresses` | 住所一覧取得 | requester |
| POST | `/profile/requester/addresses` | 住所追加 | requester |
| PUT | `/profile/requester/addresses/{id}` | 住所更新 | requester |
| DELETE | `/profile/requester/addresses/{id}` | 住所削除 | requester |

#### 5.2.3 店舗・商品 API (`/stores`, `/products`)

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| GET | `/stores/` | 店舗一覧取得 |
| GET | `/stores/{id}` | 店舗詳細取得 |
| GET | `/products/` | 全商品取得 |
| GET | `/products/store/{store_id}` | 店舗の商品取得 |
| POST | `/products/` | 商品登録（店舗のみ） |
| PUT | `/products/{id}` | 商品更新 |
| DELETE | `/products/{id}` | 商品削除 |

#### 5.2.4 注文 API (`/orders`)

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| POST | `/orders/` | 注文作成 |
| GET | `/orders/my` | 自分の注文一覧 |
| GET | `/orders/{id}` | 注文詳細 |
| PUT | `/orders/{id}/status` | 注文ステータス更新 |

**注文作成リクエスト例:**
```json
POST /orders/
{
  "store_id": 1,
  "delivery_address": "高知県香美市土佐山田町...",
  "delivery_latitude": 33.5968,
  "delivery_longitude": 133.6823,
  "notes": "玄関前に置いてください",
  "details": [
    {"product_id": 1, "quantity": 2, "notes": "大盛り希望"},
    {"product_id": 3, "quantity": 1}
  ]
}
```

#### 5.2.5 配達 API (`/delivery`)

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| GET | `/delivery/jobs` | 利用可能な配達ジョブ一覧 |
| POST | `/delivery/jobs/{order_id}/accept` | ジョブ受諾 |
| GET | `/delivery/my` | 自分の配達一覧 |
| PUT | `/delivery/{id}/status` | 配達ステータス更新 |
| PUT | `/delivery/{id}/location` | 位置情報更新 |

#### 5.2.6 通知 API (`/notifications`)

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| GET | `/notifications/` | 通知一覧取得 |
| PUT | `/notifications/{id}/read` | 既読にする |
| DELETE | `/notifications/{id}` | 通知削除 |

#### 5.2.7 その他 API

| メソッド | エンドポイント | 説明 |
|---------|---------------|------|
| POST | `/contact/send` | お問い合わせ送信 |
| POST | `/uploads/image` | 画像アップロード |

### 5.3 認証フロー

```
1. ユーザーがログイン
   POST /auth/login {username, password}
   
2. サーバーがJWTトークンを発行
   Response: {access_token: "eyJ...", token_type: "bearer"}
   
3. クライアントがトークンをローカルストレージに保存
   
4. 以降のリクエストにトークンを付与
   Authorization: Bearer eyJ...
   
5. サーバーがトークンを検証してユーザーを特定
```

### 5.4 エラーレスポンス

```json
{
  "detail": "エラーメッセージ"
}
```

| ステータスコード | 説明 |
|-----------------|------|
| 400 | Bad Request - リクエスト不正 |
| 401 | Unauthorized - 認証エラー |
| 403 | Forbidden - 権限エラー |
| 404 | Not Found - リソースなし |
| 500 | Internal Server Error - サーバーエラー |

---

## 6. フロントエンド設計

### 6.1 ディレクトリ構成

```
src/lib/
├── main.dart                    # アプリケーションエントリーポイント
├── config/
│   ├── routes.dart              # ルーティング定義
│   ├── theme.dart               # テーマ設定
│   └── env_config.dart          # 環境設定
├── models/
│   └── database_models.dart     # データモデル定義
├── services/
│   ├── api_service.dart         # API通信基盤
│   ├── auth_service.dart        # 認証サービス
│   ├── delivery_service.dart    # 配達サービス
│   └── location_service.dart    # 位置情報サービス
├── provider/
│   ├── cart_provider.dart       # カート状態管理
│   ├── order_provider.dart      # 注文状態管理
│   ├── delivery_provider.dart   # 配達状態管理
│   ├── store_provider.dart      # 店舗状態管理
│   └── notification_provider.dart # 通知状態管理
├── page/
│   ├── login_page.dart          # ログイン画面
│   ├── new_member.dart          # 新規登録画面
│   ├── requester/               # 依頼者向け画面
│   ├── deliverer/               # 配達員向け画面
│   └── store/                   # 店舗向け画面
├── component/                   # 共通コンポーネント
├── widgets/                     # 再利用可能ウィジェット
├── overlay/                     # オーバーレイ（ダイアログ等）
└── utils/                       # ユーティリティ
```

### 6.2 状態管理（Provider）

```dart
// main.dart での Provider 設定
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserRoleProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
    ChangeNotifierProvider(create: (_) => DeliveryProvider()),
    ChangeNotifierProvider(create: (_) => StoreProvider()),
    ChangeNotifierProvider(create: (_) => OverScreenController()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProvider(create: (_) => LocationProvider()),
  ],
  child: const StellarDeliveryApp(),
)
```

### 6.3 ルーティング

```dart
// 主要ルート
static const String login = '/login';
static const String register = '/register';

// 依頼者ルート
static const String requestorHome = '/requester/home';
static const String requestorProducts = '/requester/products';
static const String requestorCart = '/requester/cart';
static const String requestorOrders = '/requester/orders';
static const String requestorProfile = '/requester/profile';

// 配達員ルート
static const String delivererHome = '/deliverer/home';
static const String delivererJobs = '/deliverer/jobs';
static const String delivererMap = '/deliverer/map';
static const String delivererHistory = '/deliverer/history';
static const String delivererProfile = '/deliverer/profile';

// 店舗ルート
static const String storeHome = '/store/home';
static const String storeOrders = '/store/orders';
static const String storeProducts = '/store/products';
static const String storeProfile = '/store/profile';
```

### 6.4 認証ガード

```dart
// AuthGuard - ログイン必須の画面を保護
class AuthGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;

  // トークンとロールを確認
  // - 未ログイン → ログイン画面へリダイレクト
  // - 許可されたロール以外 → 適切なホームへリダイレクト
}

// GuestGuard - 未ログイン時のみアクセス可能
class GuestGuard extends StatelessWidget {
  // ログイン済み → ロール別ホームへリダイレクト
}
```

### 6.5 画面一覧

#### 依頼者（Requester）画面

| 画面 | ファイル | 機能 |
|------|---------|------|
| ホーム | `c_home.dart` | 店舗一覧、通知 |
| 店舗検索 | `c_store_search.dart` | 店舗検索 |
| 商品一覧 | `c_product_list.dart` | 店舗の商品表示 |
| カート | `c_cart.dart` | カート管理 |
| 注文確認 | `c_order_confirmation.dart` | 注文確定前確認 |
| 注文追跡 | `c_order_tracking.dart` | 配達状況確認 |
| 注文履歴 | `c_order_history.dart` | 過去の注文 |
| 支払い履歴 | `c_payment_history_page.dart` | 支払い明細 |
| マイページ | `c_mypage.dart` | プロフィール |
| 住所管理 | `c_address_management.dart` | 配達先住所 |
| 通知 | `c_notification.dart` | 通知一覧 |

#### 配達員（Deliverer）画面

| 画面 | ファイル | 機能 |
|------|---------|------|
| ホーム | `d_home.dart` | ダッシュボード |
| ジョブ選択 | `d_job_select.dart` | 配達ジョブ一覧 |
| 配達マップ | `d_delivery_map.dart` | 地図表示 |
| 配達履歴 | `d_delivery_history.dart` | 過去の配達 |
| 給与明細 | `d_payment_history_page.dart` | 給与履歴 |
| 口座情報 | `d_banking_information.dart` | 振込先口座 |
| マイページ | `d_mypage.dart` | プロフィール |
| 通知 | `d_notification.dart` | 通知一覧 |

#### 店舗（Store）画面

| 画面 | ファイル | 機能 |
|------|---------|------|
| ホーム | `s_home.dart` | ダッシュボード |
| 注文管理 | `s_order_management.dart` | 受注処理 |
| メニュー編集 | `s_menu_edit.dart` | 商品管理 |
| 在庫状況 | `s_inventory_status.dart` | 在庫管理 |
| 売上管理 | `s_sales.dart` | 売上集計 |
| 口座情報 | `s_banking_info.dart` | 振込先口座 |
| マイページ | `s_mypage.dart` | 店舗プロフィール |

---

## 7. 認証・セキュリティ

### 7.1 認証方式

- **JWT (JSON Web Token)** によるトークンベース認証
- トークン有効期限: 30分
- アルゴリズム: HS256

### 7.2 パスワード処理

```python
# bcrypt によるハッシュ化
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)
```

### 7.3 JWT トークン構造

```json
{
  "sub": "user@example.com",  // ユーザーのメールアドレス
  "role": "requester",        // ユーザーロール
  "user_id": 1,               // ユーザーID
  "exp": 1706000000           // 有効期限（Unix timestamp）
}
```

### 7.4 CORS設定

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # 開発用（本番では制限推奨）
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 7.5 セキュリティ注意事項

| 項目 | 現状 | 推奨対応 |
|------|------|---------|
| HTTPS | 未対応 | Let's Encrypt導入 |
| CORS | 全許可 | ドメイン制限 |
| Rate Limiting | 未実装 | 導入推奨 |
| SQL Injection | SQLAlchemy ORM使用で対策済み | - |
| XSS | Flutter側で対策 | - |

---

## 8. ユーザーロールと機能

### 8.1 ロール別機能マトリクス

| 機能 | 依頼者 | 配達員 | 店舗 | 管理者 |
|------|:------:|:------:|:----:|:------:|
| アカウント登録 | ✅ | ✅ | ✅ | - |
| ログイン/ログアウト | ✅ | ✅ | ✅ | ✅ |
| プロフィール編集 | ✅ | ✅ | ✅ | - |
| 住所管理 | ✅ | - | - | - |
| 店舗検索・閲覧 | ✅ | - | - | - |
| 商品注文 | ✅ | - | - | - |
| カート管理 | ✅ | - | - | - |
| 注文履歴閲覧 | ✅ | - | - | - |
| 配達追跡 | ✅ | - | - | - |
| 配達ジョブ受諾 | - | ✅ | - | - |
| 配達ステータス更新 | - | ✅ | - | - |
| 位置情報送信 | - | ✅ | - | - |
| 給与明細閲覧 | - | ✅ | - | - |
| 商品管理 | - | - | ✅ | - |
| 注文受付・処理 | - | - | ✅ | - |
| 売上管理 | - | - | ✅ | - |
| 口座情報管理 | - | ✅ | ✅ | - |

### 8.2 ユーザーフロー

#### 依頼者フロー
```
1. アプリ起動 → ログイン/新規登録
2. ホーム画面 → 店舗一覧表示
3. 店舗選択 → 商品一覧表示
4. 商品をカートに追加
5. カート確認 → 注文確定
6. 注文追跡画面で配達状況確認
7. 配達完了通知受信
```

#### 配達員フロー
```
1. アプリ起動 → ログイン
2. ホーム画面 → ステータス確認
3. ジョブ一覧 → 配達ジョブ選択
4. ジョブ受諾
5. 店舗へ移動 → 商品受け取り
6. 配達先へ移動 → 位置情報更新
7. 配達完了 → ステータス更新
```

#### 店舗フロー
```
1. アプリ起動 → ログイン
2. ホーム画面 → 本日の注文確認
3. 新規注文通知受信
4. 注文受付 → 調理開始
5. 調理完了 → 受け取り準備完了
6. 配達員が受け取り
7. 売上確認
```

---

## 9. 注文フロー

### 9.1 注文ステータス遷移図

```
┌─────────┐
│ pending │ ←── 注文作成
└────┬────┘
     │ 店舗が受付
     ▼
┌──────────┐
│ accepted │
└────┬─────┘
     │ 調理開始
     ▼
┌───────────┐
│ preparing │
└────┬──────┘
     │ 調理完了
     ▼
┌──────────────────┐
│ ready_for_pickup │
└────────┬─────────┘
         │ 配達員が受け取り
         ▼
    ┌───────────┐
    │ picked_up │
    └─────┬─────┘
          │ 配達開始
          ▼
    ┌────────────┐
    │ delivering │
    └──────┬─────┘
           │ 配達完了
           ▼
    ┌───────────┐
    │ delivered │
    └───────────┘
    
※ どの段階でも cancelled への遷移可能
```

### 9.2 注文処理詳細

#### 注文作成時の処理

```python
# 1. 商品の合計金額を計算
subtotal = sum(product.price * item.quantity for item in order.details)

# 2. 配達料を設定（固定300円）
delivery_fee = 300

# 3. 合計金額を計算
total_price = subtotal + delivery_fee

# 4. 注文レコードを作成
db_order = Order(
    requester_id=requester.id,
    store_id=order.store_id,
    status="pending",
    subtotal=subtotal,
    delivery_fee=delivery_fee,
    total_price=total_price,
    delivery_address=order.delivery_address,
)

# 5. 注文明細を作成
for item in order.details:
    db_detail = OrderDetail(
        order_id=db_order.id,
        product_id=item.product_id,
        quantity=item.quantity,
        unit_price=product.price,
        subtotal=product.price * item.quantity,
    )
```

---

## 10. 配達管理システム

### 10.1 配達ジョブのマッチング

```python
# 利用可能な配達ジョブを取得
# 条件: preparing または ready_for_pickup で、配達員未割り当て
orders = db.query(Order).filter(
    Order.status.in_(["preparing", "ready_for_pickup"]),
    Order.deliverer_id == None
).all()
```

### 10.2 位置情報トラッキング

```dart
// 配達員の位置情報を定期更新
class LocationService {
  Future<void> updateDelivererLocation(int deliveryId) async {
    final position = await Geolocator.getCurrentPosition();
    await _apiService.put('/delivery/$deliveryId/location', {
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }
}
```

### 10.3 地図システム（Leaflet.js + OSRM）

#### 10.3.1 技術構成

本アプリケーションでは、Flutter Web上で地図機能を実現するため、以下の技術を組み合わせています。

| 技術 | 役割 | ライセンス |
|------|------|-----------|
| **Leaflet.js** | 地図表示ライブラリ | BSD-2-Clause |
| **OpenStreetMap** | 地図タイルデータ | ODbL |
| **OSRM** | ルート検索API | BSD-2-Clause |

#### 10.3.2 アーキテクチャ概要

```
┌──────────────────────────────────────────────────────────────────┐
│                     Flutter Web Application                       │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                    MapWidget (Dart)                         │  │
│  │  - HtmlElementView で HTML要素を埋め込み                     │  │
│  │  - postMessage でJavaScript と双方向通信                    │  │
│  └────────────────────┬───────────────────────────────────────┘  │
│                       │ postMessage                              │
│  ┌────────────────────▼───────────────────────────────────────┐  │
│  │              delivery_map.js (JavaScript)                   │  │
│  │  - Leaflet.js による地図描画                                │  │
│  │  - マーカー・ルート・アニメーション制御                      │  │
│  └────────────────────┬───────────────────────────────────────┘  │
└───────────────────────│──────────────────────────────────────────┘
                        │ HTTP
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ OpenStreetMap │ │   OSRM API    │ │ Location API  │
│  Tile Server  │ │ (ルート計算)  │ │ (ブラウザ)    │
└───────────────┘ └───────────────┘ └───────────────┘
```

#### 10.3.3 ファイル構成

```
src/
├── web/
│   ├── index.html          # Leaflet CSS/JS を読み込み
│   └── delivery_map.js     # 地図制御スクリプト
└── lib/
    ├── widgets/
    │   └── map_widget.dart # Flutter側の地図ウィジェット
    └── services/
        ├── location_service.dart           # 位置情報サービス
        └── delivery_simulation_service.dart # 配達シミュレーション
```

#### 10.3.4 実装詳細

##### ① index.html（Leafletライブラリの読み込み）

```html
<!-- Leaflet CSS -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
      crossorigin="anonymous"/>

<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
        crossorigin="anonymous"></script>

<!-- カスタム地図制御スクリプト -->
<script src="delivery_map.js"></script>
```

##### ② MapWidget（Flutter/Dart側）

```dart
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class MapWidget extends StatefulWidget {
  final double? initialLatitude;   // 初期緯度（デフォルト: 高知県香美市 33.5944）
  final double? initialLongitude;  // 初期経度（デフォルト: 133.8628）
  final double initialZoom;        // ズームレベル
  final double? destinationLatitude;
  final double? destinationLongitude;
  final bool showRoute;            // ルート表示フラグ
  final Stream<LocationData>? delivererLocationStream; // 配達員位置ストリーム
}

class _MapWidgetState extends State<MapWidget> {
  late String _mapId;  // ユニークなマップID

  @override
  void initState() {
    super.initState();
    _mapId = 'delivery-map-${_mapIdCounter++}';
    
    // HTMLコンテナを登録
    ui_web.platformViewRegistry.registerViewFactory(
      _mapId,
      (int viewId) => html.DivElement()..id = _mapId,
    );
    
    // 地図初期化
    Future.delayed(Duration(milliseconds: 1000), _initLeafletMap);
  }

  void _initLeafletMap() {
    // JavaScriptに初期化メッセージを送信
    html.window.postMessage({
      'type': 'initMap',
      'mapId': _mapId,
      'startLat': widget.initialLatitude ?? 33.5944,  // 高知県香美市
      'startLng': widget.initialLongitude ?? 133.8628,
      'destLat': widget.destinationLatitude,
      'destLng': widget.destinationLongitude,
      'zoom': widget.initialZoom,
      'showRoute': widget.showRoute,
    }, '*');
  }

  @override
  Widget build(BuildContext context) {
    // HtmlElementViewでHTML要素を埋め込み
    return HtmlElementView(viewType: _mapId);
  }
}
```

##### ③ delivery_map.js（JavaScript側）

```javascript
// グローバルマップオブジェクト管理
const deliveryMaps = {};

// Flutter からのメッセージを受信
window.addEventListener('message', function(event) {
  const data = event.data;
  
  if (data.type === 'initMap') {
    initDeliveryMap(data);  // 地図初期化
  } else if (data.type === 'updateDeliverer') {
    updateDelivererPosition(data);  // 配達員位置更新
  }
});

// 地図初期化
function initDeliveryMap(config) {
  const { mapId, startLat, startLng, destLat, destLng, zoom, showRoute } = config;
  
  // Leaflet地図を作成
  const map = L.map(mapId, {
    center: [startLat, startLng],
    zoom: zoom || 13,
  });

  // OpenStreetMapタイルを追加
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap',
  }).addTo(map);

  // 店舗マーカー（緑、🏪アイコン）
  const storeMarker = L.marker([startLat, startLng], {
    icon: createIcon('#4CAF50', '🏪')
  }).addTo(map);

  // 配達員マーカー（青、🚗アイコン、アニメーション付き）
  const delivererMarker = L.marker([startLat, startLng], {
    icon: createIcon('#2196F3', '🚗')
  }).addTo(map);

  // マップオブジェクトを保存
  deliveryMaps[mapId] = { map, storeMarker, delivererMarker };

  // ルート表示
  if (showRoute && destLat && destLng) {
    // 依頼者マーカー（赤、🏁アイコン）
    L.marker([destLat, destLng], {
      icon: createIcon('#f44336', '🏁')
    }).addTo(map);
    
    // OSRMでルート取得
    fetchRoute(mapId, startLat, startLng, destLat, destLng, map);
  }
}
```

##### ④ OSRMルート検索

```javascript
async function fetchRoute(mapId, startLat, startLng, endLat, endLng, map) {
  // OSRM公開APIを使用（無料、レート制限あり）
  const url = `https://router.project-osrm.org/route/v1/driving/` +
              `${startLng},${startLat};${endLng},${endLat}` +
              `?overview=full&geometries=geojson`;
  
  const response = await fetch(url);
  const data = await response.json();
  const route = data.routes[0];
  
  // GeoJSON座標をLeaflet用に変換
  const latlngs = route.geometry.coordinates.map(
    coord => [coord[1], coord[0]]  // [経度,緯度] → [緯度,経度]
  );
  
  // ルートをポリラインで描画（紫色、太さ6）
  const routePolyline = L.polyline(latlngs, {
    color: '#667eea',
    weight: 6,
    opacity: 0.8,
  }).addTo(map);
  
  // 地図をルート全体が見えるように調整
  map.fitBounds(routePolyline.getBounds());
  
  // ルート情報（距離・時間）をFlutterに通知
  const distanceKm = route.distance / 1000;
  const durationMin = Math.round(route.duration / 60);
  
  window.parent.postMessage({
    type: 'routeCalculated',
    mapId: mapId,
    distanceKm: distanceKm,
    durationMin: durationMin
  }, '*');
}
```

##### ⑤ 配達員位置のリアルタイム更新

```javascript
function updateDelivererPosition(config) {
  const { mapId, lat, lng } = config;
  const mapObj = deliveryMaps[mapId];
  
  // マーカーをアニメーションで移動（1秒かけて滑らかに）
  animateMarker(mapObj.delivererMarker, currentPos, newPos, 1000);
  
  // 地図の中心を配達員に追従
  mapObj.map.panTo([lat, lng], { animate: true });
}

function animateMarker(marker, startPos, endPos, duration) {
  const startTime = Date.now();
  
  function update() {
    const progress = Math.min((Date.now() - startTime) / duration, 1);
    
    // 線形補間で位置を計算
    const lat = startPos.lat + (endPos.lat - startPos.lat) * progress;
    const lng = startPos.lng + (endPos.lng - startPos.lng) * progress;
    
    marker.setLatLng([lat, lng]);
    
    if (progress < 1) requestAnimationFrame(update);
  }
  update();
}
```

#### 10.3.5 マーカーアイコン

| マーカー | 色 | アイコン | 用途 |
|---------|-----|---------|------|
| 店舗 | 緑 `#4CAF50` | 🏪 | 配達開始地点 |
| 配達員 | 青 `#2196F3` | 🚗 | 現在位置（アニメーション付き） |
| 配達先 | 赤 `#f44336` | 🏁 | 目的地（依頼者の住所） |

#### 10.3.6 デフォルト座標（高知県香美市）

| 地点 | 緯度 | 経度 | 説明 |
|------|------|------|------|
| 店舗 | 33.5944 | 133.8628 | 高知工科大学付近 |
| 配達先 | 33.5850 | 133.8750 | 香美市内 |

#### 10.3.7 Flutter ↔ JavaScript 通信フロー

```
┌─────────────────┐                    ┌─────────────────┐
│  Flutter/Dart   │                    │   JavaScript    │
│   (MapWidget)   │                    │ (delivery_map)  │
└────────┬────────┘                    └────────┬────────┘
         │                                      │
         │  postMessage('initMap', config)      │
         │ ────────────────────────────────────>│
         │                                      │
         │                          地図初期化   │
         │                          OSRMルート取得│
         │                                      │
         │  postMessage('routeCalculated')      │
         │ <────────────────────────────────────│
         │                                      │
    ルート情報表示                              │
         │                                      │
         │  postMessage('updateDeliverer')      │
         │ ────────────────────────────────────>│
         │                                      │
         │                     マーカーアニメーション
         │                                      │
```

#### 10.3.8 注意事項・制限

| 項目 | 詳細 |
|------|------|
| **Web専用** | `dart:html`を使用しているため、Web以外では動作しない |
| **HTTPS推奨** | 位置情報APIはHTTPSでのみ動作（HTTPではデモ用固定座標） |
| **OSRMレート制限** | 公開APIのため、大量リクエスト時は自前サーバー構築を推奨 |
| **オフライン** | 地図タイルはオンラインで取得するため、オフラインでは表示不可 |

---

## 11. 通知システム

### 11.1 通知タイプ

| タイプ | 説明 | 対象ユーザー |
|--------|------|-------------|
| `order_update` | 注文ステータス変更 | 依頼者、店舗 |
| `delivery_update` | 配達ステータス変更 | 依頼者、配達員 |
| `payment` | 支払い関連 | 依頼者、店舗、配達員 |
| `system` | システム通知 | 全ユーザー |
| `promotion` | プロモーション | 全ユーザー |

### 11.2 通知データ構造

```sql
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    related_order_id INTEGER REFERENCES orders(id),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 12. 決済・売上管理

### 12.1 料金構成

| 項目 | 説明 |
|------|------|
| 商品小計 | 各商品の単価 × 数量 の合計 |
| 配達料 | 固定 300円 |
| 合計金額 | 商品小計 + 配達料 |

### 12.2 配達員報酬

```sql
CREATE TABLE deliverer_payouts (
    id SERIAL PRIMARY KEY,
    deliverer_id INTEGER NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_deliveries INTEGER NOT NULL DEFAULT 0,  -- 配達件数
    total_amount INTEGER NOT NULL DEFAULT 0,      -- 合計報酬額
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 12.3 店舗売上

```sql
CREATE TABLE store_sales (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_orders INTEGER NOT NULL DEFAULT 0,      -- 注文件数
    total_amount INTEGER NOT NULL DEFAULT 0,      -- 総売上
    commission_rate DECIMAL(5, 2) DEFAULT 10.00,  -- 手数料率 10%
    commission_amount INTEGER NOT NULL DEFAULT 0, -- 手数料額
    net_amount INTEGER NOT NULL DEFAULT 0,        -- 純売上
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMP
);
```

---

## 13. デプロイ構成

### 13.1 本番環境情報

| 項目 | 値 |
|------|-----|
| **プラットフォーム** | AWS EC2 |
| **インスタンスタイプ** | t2.micro |
| **Elastic IP** | 34.193.170.210 |
| **OS** | Ubuntu |
| **Docker** | Docker Compose v2 |

### 13.2 アクセスURL

| サービス | URL |
|---------|-----|
| フロントエンド | http://34.193.170.210/ |
| API | http://34.193.170.210/api/ |
| API ドキュメント | http://34.193.170.210/api/docs |

### 13.3 Docker Compose 構成

```yaml
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./src/build/web:/usr/share/nginx/html
      - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf

  backend:
    build: ./backend
    expose:
      - "8000"
    environment:
      - DATABASE_URL=postgresql://student:student@db:5432/university_app
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=student
      - POSTGRES_PASSWORD=student
      - POSTGRES_DB=university_app
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./docker/db/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U student -d university_app"]

volumes:
  db_data:
```

### 13.4 Nginx 設定

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # API リクエストをバックエンドにプロキシ
    location /api/ {
        proxy_pass http://backend:8000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 静的ファイルアップロード
    location /uploads/ {
        proxy_pass http://backend:8000/uploads/;
    }

    # SPA用フォールバック
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 14. 開発・運用情報

### 14.1 テストアカウント

| ロール | メールアドレス | パスワード |
|--------|----------------|------------|
| 依頼者 | user1@test.com | password |
| 店舗 | store1@test.com | password |
| 配達員 | deliverer1@test.com | password |
| 管理者 | admin@stellar.local | password |

### 14.2 開発環境セットアップ

```bash
# リポジトリクローン
git clone https://github.com/RENMORITAA/software-engineering.git

# Docker起動
cd software-engineering/Project
docker-compose up --build -d

# アクセス
# フロントエンド: http://localhost:8080
# API Docs: http://localhost:8000/docs
```

### 14.3 よく使うコマンド

```bash
# フロントエンドデプロイ
cd /home/morita/software-engineering/Project/src && \
flutter build web --release \
  --dart-define=API_BASE_URL=http://34.193.170.210/api \
  --dart-define=ENV=production \
  --pwa-strategy=none && \
scp -i ~/.ssh/ZoneOil.pem -r build/web/* ubuntu@34.193.170.210:~/Project/src/build/web/

# SSH接続
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210

# コンテナ状態確認
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker ps"

# ログ確認
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker logs fastapi_backend --tail 50"
```

### 14.4 トラブルシューティング

| 問題 | 確認事項 | 対処法 |
|------|---------|--------|
| APIに接続できない | コンテナが起動しているか | `docker ps` で確認 |
| ログインできない | トークンが有効か | ブラウザのローカルストレージを確認 |
| 画面が更新されない | キャッシュ | Ctrl+Shift+R でハードリロード |
| 位置情報が取得できない | HTTPS必須（本番） | HTTPでは一部機能制限あり |

### 14.5 今後の改善予定

- [ ] HTTPS対応（Let's Encrypt + Certbot）
- [ ] CI/CD パイプライン構築（GitHub Actions）
- [ ] プッシュ通知（Firebase Cloud Messaging）
- [ ] 決済システム統合（Stripe等）
- [ ] ログ監視・アラート設定
- [ ] バックアップ自動化
- [ ] 負荷テスト・パフォーマンス最適化

---

## 📊 統計情報

| 項目 | 数値 |
|------|------|
| 総Dartファイル数 | 114 |
| 総Pythonファイル数 | 12 |
| データベーステーブル数 | 15 |
| APIエンドポイント数 | 約40 |
| 総コミット数 | 587 |
| 開発者数 | 7名 |

---

## 📝 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-01-23 | 初版作成 |
| 2026-01-23 | AWS EC2デプロイ完了 |
| 2026-01-26 | システムドキュメント作成 |
| 2026-02-05 | 地図システム（Leaflet.js + OSRM）の詳細ドキュメント追加 |
| 2026-02-05 | デフォルト座標を高知県香美市に変更 |

---

*このドキュメントは Stellar Delivery プロジェクトの技術仕様書です。*
*質問がある場合は、開発チームまでお問い合わせください。*
