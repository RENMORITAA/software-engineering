# プロジェクト開発ガイド

このドキュメントは、このプロジェクトの構成、開発方法、カスタマイズ方法について詳しく解説しています。
初心者の方でも実装が進められるように、ディレクトリの役割やコードの書き方を丁寧に説明します。

---

## 1. 環境構築と実行 (Quick Start)

Dockerを使用して環境を構築します。

### 起動コマンド
プロジェクトのルートディレクトリで以下のコマンドを実行してください。

```powershell
# コンテナのビルドと起動（バックグラウンド）
docker-compose up --build -d
```

### アクセスURL
*   **Flutter Web アプリ**: [http://localhost:8080](http://localhost:8080)
*   **API ドキュメント (Swagger)**: [http://localhost:8000/docs](http://localhost:8000/docs)
    *   ここでAPIのテスト実行が可能です。

### テストアカウント
開発用のテストアカウントが用意されています。パスワードはすべて `password` です。

| ロール | メールアドレス | パスワード |
|--------|----------------|------------|
| 依頼者 | user1@test.com | password |
| 店舗 | store1@test.com | password |
| 配達員 | deliverer1@test.com | password |
| 管理者 | admin@stellar.local | password |

### 停止コマンド
```powershell
docker-compose down
```

---

## 2. プロジェクト構成 (Directory Structure)

主なディレクトリとファイルの役割です。

```
Project/
├── backend/                        # Python (FastAPI) バックエンド
│   ├── app/
│   │   ├── main.py                 # アプリの起動ファイル・CORS設定
│   │   ├── database.py             # DB接続設定
│   │   ├── models.py               # ★重要: データベースのテーブル定義 (SQLAlchemy)
│   │   ├── schemas.py              # ★重要: データの送受信ルール (Pydantic)
│   │   └── routers/                # ★重要: APIのエンドポイント (URLごとの処理)
│   │       ├── auth.py             # 認証API (ログイン・登録・JWT)
│   │       ├── profile.py          # プロフィールAPI (依頼者・配達員・店舗)
│   │       ├── orders.py           # 注文API
│   │       ├── products.py         # 商品API
│   │       ├── stores.py           # 店舗API
│   │       ├── delivery.py         # 配達API
│   │       └── notifications.py    # 通知API
│   ├── Dockerfile
│   └── requirements.txt            # Pythonライブラリ一覧
│
├── docker/
│   ├── db/
│   │   └── init.sql                # ★重要: データベース初期化SQL
│   └── flutter/
│       └── Dockerfile
│
├── src/                            # Flutter (Dart) フロントエンド
│   ├── lib/
│   │   ├── main.dart               # アプリの入り口・Provider登録
│   │   │
│   │   ├── config/                 # 設定関連
│   │   │   ├── routes.dart         # 画面遷移の定義
│   │   │   └── theme.dart          # ★デザイン: 色やフォントの定義
│   │   │
│   │   ├── models/                 # データ型定義
│   │   │   └── database_models.dart # バックエンドのschemasに対応するクラス
│   │   │
│   │   ├── services/               # ★通信: APIと通信する処理
│   │   │   ├── api_service.dart    # HTTP通信の基底クラス
│   │   │   ├── auth_service.dart   # 認証API呼び出し
│   │   │   ├── order_service.dart  # 注文API呼び出し
│   │   │   ├── product_service.dart # 商品API呼び出し
│   │   │   ├── store_service.dart  # 店舗API呼び出し
│   │   │   ├── delivery_service.dart # 配達API呼び出し
│   │   │   ├── profile_service.dart # プロフィールAPI呼び出し
│   │   │   └── notification_service.dart # 通知API呼び出し
│   │   │
│   │   ├── provider/               # ★状態管理: データを保持・更新
│   │   │   ├── provider.dart       # エクスポート用
│   │   │   ├── change_user_role.dart # ユーザーロール・認証情報管理
│   │   │   ├── cart_provider.dart  # カート状態管理
│   │   │   ├── order_provider.dart # 注文状態管理
│   │   │   ├── store_provider.dart # 店舗状態管理
│   │   │   ├── delivery_provider.dart # 配達状態管理
│   │   │   ├── notification_provider.dart # 通知状態管理
│   │   │   └── over_screen_controller.dart # オーバーレイ制御
│   │   │
│   │   ├── page/                   # ★画面: 各ページのUI実装
│   │   │   ├── login_page.dart     # ログイン画面
│   │   │   ├── new_member.dart     # 新規登録画面
│   │   │   ├── mypage.dart         # マイページ（共通）
│   │   │   │
│   │   │   ├── requester/          # 依頼者用画面 (c_プレフィックス)
│   │   │   │   ├── c_root_page.dart       # ナビゲーション制御
│   │   │   │   ├── c_home.dart            # ホーム（店舗一覧）
│   │   │   │   ├── c_product_list.dart    # 商品一覧
│   │   │   │   ├── c_cart.dart            # カート
│   │   │   │   ├── c_order_history.dart   # 注文履歴
│   │   │   │   ├── c_order_tracking.dart  # 注文追跡
│   │   │   │   ├── c_store_search.dart    # 店舗検索
│   │   │   │   ├── c_notifications.dart   # 通知一覧
│   │   │   │   ├── c_address_management.dart # 住所管理
│   │   │   │   ├── c_review.dart          # レビュー投稿
│   │   │   │   └── c_mypage.dart          # マイページラッパー
│   │   │   │
│   │   │   ├── deliverer/          # 配達員用画面 (d_プレフィックス)
│   │   │   │   ├── d_root_page.dart       # ナビゲーション制御
│   │   │   │   ├── d_home.dart            # ホーム
│   │   │   │   ├── d_job_select.dart      # 仕事選択
│   │   │   │   ├── d_map.dart             # 配達マップ
│   │   │   │   ├── d_delivery_history.dart # 配達履歴
│   │   │   │   ├── d_notice.dart          # お知らせ
│   │   │   │   ├── d_payslip.dart         # 給与明細
│   │   │   │   ├── d_banking_information.dart # 口座情報
│   │   │   │   ├── d_resume_detail.dart   # 履歴書詳細
│   │   │   │   └── d_mypage.dart          # マイページラッパー
│   │   │   │
│   │   │   └── store/              # 店舗用画面 (s_プレフィックス)
│   │   │       ├── s_root_page.dart       # ナビゲーション制御
│   │   │       ├── s_home.dart            # ホーム
│   │   │       ├── s_order_list.dart      # 注文一覧
│   │   │       ├── s_menu_edit.dart       # メニュー編集
│   │   │       ├── s_inventory_status.dart # 在庫状況
│   │   │       ├── s_sales.dart           # 売上管理
│   │   │       ├── s_info.dart            # 店舗情報
│   │   │       ├── s_banking_info.dart    # 口座情報
│   │   │       └── s_mypage.dart          # マイページラッパー
│   │   │
│   │   ├── component/              # ★部品: 再利用可能なUIコンポーネント
│   │   │   ├── component.dart      # エクスポート用
│   │   │   ├── title_appbar.dart   # 共通AppBar
│   │   │   ├── normal_bottom_appbar.dart # 共通BottomNavigation
│   │   │   ├── general_form.dart   # 汎用フォーム
│   │   │   ├── button_set.dart     # ボタンセット
│   │   │   ├── password_input.dart # パスワード入力
│   │   │   ├── number_count.dart   # 数量カウンター
│   │   │   ├── finish_screen.dart  # 完了画面
│   │   │   ├── d_job.dart          # 配達ジョブカード
│   │   │   └── d_notice_change.dart # 通知変更
│   │   │
│   │   ├── widgets/                # 小さなUI部品
│   │   │   ├── widgets.dart        # エクスポート用
│   │   │   ├── buttons.dart        # ボタン集
│   │   │   ├── custom_button.dart  # カスタムボタン
│   │   │   ├── text_fields.dart    # テキストフィールド
│   │   │   ├── rating_widget.dart  # 星評価
│   │   │   ├── loading_overlay.dart # ローディング表示
│   │   │   ├── error_dialog.dart   # エラーダイアログ
│   │   │   └── state_widgets.dart  # 空状態・エラー状態
│   │   │
│   │   ├── overlay/                # オーバーレイUI（モーダル等）
│   │   │   ├── overlay.dart        # エクスポート用
│   │   │   ├── logout.dart         # ログアウト確認
│   │   │   ├── withdraw.dart       # 退会確認
│   │   │   └── ...
│   │   │
│   │   └── utils/                  # ユーティリティ
│   │       ├── constants.dart      # 定数定義（API URL等）
│   │       └── helpers.dart        # ヘルパー関数（日付フォーマット等）
│   │
│   └── pubspec.yaml                # Dartライブラリ一覧
│
└── docker-compose.yml              # Docker構成
```

### ファイル命名規則
| プレフィックス | 意味 | 例 |
|--------------|------|-----|
| `c_` | 依頼者 (Customer/Consumer) | `c_home.dart`, `c_cart.dart` |
| `d_` | 配達員 (Deliverer) | `d_home.dart`, `d_job_select.dart` |
| `s_` | 店舗 (Store) | `s_home.dart`, `s_order_list.dart` |

---

## 3. バックエンド開発 (Python/FastAPI & DB)

データベースとAPIサーバーの変更方法です。

### データベース (DB) の書き方

データベースの構造を変更・追加したい場合は、以下の2箇所を編集します。

1.  **`docker/db/init.sql`**
    *   SQL言語でテーブル作成コマンド (`CREATE TABLE`) を書きます。
    *   初期データを投入する (`INSERT INTO`) 場合もここに書きます。
    *   **注意**: ここを変更したら、一度 `docker-compose down -v` (ボリューム削除) してデータをリセットしないと反映されません。

2.  **`backend/app/models.py`**
    *   Pythonのコードでテーブル定義を書きます（ORMと言います）。
    *   `init.sql` の内容と一致させる必要があります。

**例: 「お知らせ (News)」テーブルを追加したい場合**

`models.py` に以下のように追記します。

```python
class News(Base):
    __tablename__ = "news"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    content = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
```

### API の作り方

新しい機能（例: お知らせ一覧を取得する）を追加する手順です。

1.  **`backend/app/schemas.py` を編集**
    *   データの「型」を定義します。
    *   入力用（Create）と出力用（Response）を作ると便利です。

2.  **`backend/app/routers/` にファイルを作成または追記**
    *   例: `news.py` を作成。
    *   `@router.get("/news")` のようにURLを定義し、DBからデータを取得して返します。

3.  **`backend/app/main.py` に登録**
    *   新しく作ったルーターを `app.include_router(news.router)` のように登録します。

---

## 4. フロントエンド開発 (Flutter/Dart)

画面やアプリの動きを変更する方法です。

### Dart の書き方・データの流れ

このプロジェクトでは、以下の流れでデータが動きます。

1.  **Model (`lib/models/database_models.dart`)**
    *   バックエンドのデータ構造 (`schemas.py`) と対になるクラスです。
    *   APIから受け取ったJSONデータをDartのオブジェクトに変換 (`fromMap`) したり、その逆 (`toMap`) を行います。
    *   **重要**: バックエンドのDB定義を変更したら、ここも合わせて修正する必要があります。

2.  **Service (`lib/services/`)**
    *   バックエンドのAPIを呼び出す通信部分です。
    *   例: `OrderService.createOrder()` → `http.post(...)`
    *   データの加工はせず、APIとのやり取りに専念します。

3.  **Provider (`lib/provider/`)**
    *   アプリ全体の「状態（データ）」を管理します。
    *   Serviceを使ってデータを取得し、リストや変数に保存します。
    *   `notifyListeners()` を呼ぶことで、画面に変更を通知します。
    *   **設定場所**: `lib/main.dart` の `MultiProvider` で登録されています。新しいProviderを作ったらここに追加してください。

4.  **Page/Screen (`lib/page/`)**
    *   Providerのデータを監視 (`Consumer` や `context.watch`) して画面に表示します。
    *   ユーザーの操作（ボタン押下など）をProviderのメソッド呼び出しとして伝えます。

### 新しい画面を追加したい場合

1.  **`lib/page/` にファイルを作成**
    *   `StatelessWidget` または `StatefulWidget` で画面を作ります。
    *   `Scaffold` ウィジェットを使うのが基本です。

2.  **`lib/config/routes.dart` に登録**
    *   画面に名前（パス）を付けます。例: `'/news': (context) => NewsPage(),`

3.  **画面遷移**
    *   `Navigator.pushNamed(context, '/news');` で移動できます。

---

## 5. デザイン・カスタマイズガイド (Design Customization)

「デザインを変えたい」「見た目を良くしたい」ときはここを触ります。

### 色やフォントを一括で変えたい
**`lib/config/theme.dart`** を編集します。
アプリ全体のテーマカラーやフォント設定が集まっています。

*   `primaryColor`: メインの色（ボタンやヘッダーなど）
*   `scaffoldBackgroundColor`: 背景色
*   `textTheme`: 文字の大きさや太さ

### ボタンや入力フォームのデザインを変えたい
**`lib/component/`** を確認してください。
ここにあるファイル（例: `custom_button.dart` や `general_form.dart`）を変更すると、アプリ全体で使われているボタンのデザインが一括で変わります。

*   **角を丸くしたい**: `borderRadius` を調整。
*   **影をつけたい**: `BoxShadow` を追加。

### レイアウトを調整したい
各 `page` ファイル内の `build` メソッドを編集します。

*   **余白を開けたい**: `Padding` や `SizedBox(height: 20)` を使います。
*   **横に並べたい**: `Row` を使います。
*   **縦に並べたい**: `Column` を使います。
*   **中央に寄せたい**: `Center` を使います。

---

## 6. トラブルシューティング

*   **DB接続エラーになる**:
    *   Dockerが起動しているか確認 (`docker ps`)。
    *   `backend/app/database.py` の接続URLが正しいか確認。
*   **コードを変えたのに反映されない**:
    *   Flutter: 画面の「リロード」ボタンを押すか、ターミナルで `R` を押してホットリスタート。
    *   Backend: ファイル保存で自動リロードされますが、ダメなら `docker-compose restart backend`。
    *   DBスキーマ変更: `docker-compose down -v` でボリューム削除が必要な場合があります。

---

## 7. データベースの確認方法

開発中にデータベースの中身を確認したい場合の接続情報です。

### 接続情報
*   **Host**: `localhost`
*   **Port**: `5432`
*   **Database**: `university_app`
*   **User**: `student`
*   **Password**: `password123`

### 確認方法
1.  **VS Code拡張機能**: "Database Client" などをインストールして接続。
2.  **GUIツール**: DBeaverやpgAdminなどを使用。
3.  **コマンドライン**: 以下のコマンドで直接SQLを実行できます。

```powershell
# テーブル一覧を表示
docker exec postgres_db psql -U student -d university_app -c "\dt"

# ユーザー一覧を表示
docker exec postgres_db psql -U student -d university_app -c "SELECT * FROM users;"
```

---

## 8. 今回の開発で実装した機能・修正内容

### 実装した主な機能

#### フロントエンド (Flutter)

| 機能 | ファイル | 説明 |
|------|----------|------|
| 通知機能 | `provider/notification_provider.dart` | 通知の取得・既読管理 |
| 通知画面 | `page/requester/c_notifications.dart` | 通知一覧の表示UI |
| 住所管理 | `page/requester/c_address_management.dart` | 配達先住所の追加・編集・削除 |
| 店舗検索 | `page/requester/c_store_search.dart` | 店舗名・カテゴリで検索 |
| 注文追跡 | `page/requester/c_order_tracking.dart` | リアルタイム配達状況確認 |
| レビュー機能 | `page/requester/c_review.dart` | 注文後のレビュー投稿 |
| 評価ウィジェット | `widgets/rating_widget.dart` | 星評価の入力・表示 |
| ローディング | `widgets/loading_overlay.dart` | 処理中のオーバーレイ表示 |
| エラーダイアログ | `widgets/error_dialog.dart` | 統一されたエラー表示 |
| 状態表示 | `widgets/state_widgets.dart` | 空状態・エラー状態の表示 |
| ユーティリティ | `utils/helpers.dart` | 日付フォーマット・価格表示等 |
| 定数定義 | `utils/constants.dart` | API URL・色定義等 |

#### バックエンド (FastAPI)

| 機能 | ファイル | 説明 |
|------|----------|------|
| 店舗プロフィールAPI | `routers/profile.py` | GET/PUT `/profile/store` 追加 |
| 認証API拡張 | `routers/auth.py` | プロフィール情報取得の追加 |

### 修正したバグ・エラー

| 問題 | 原因 | 解決策 |
|------|------|--------|
| `Notification`クラス名衝突 | FlutterのビルトインNotificationと名前が重複 | `AppNotification`にリネーム |
| ログインできない (401) | パスワードハッシュが不正な形式 | Pythonで正しいbcryptハッシュを生成・更新 |
| フォームデータ送信失敗 | `x-www-form-urlencoded`のエンコード不正 | `Uri.encodeComponent`で正しくエンコード |
| プロフィール情報が表示されない | ログイン後にプロフィールを取得していない | `login_page.dart`でプロフィール取得処理を追加 |
| マイページにダミーデータ表示 | UserRoleProviderを使用していない | Provider経由で実データを表示するよう修正 |

---

## 9. 学習ポイント・コード解説

### 1. Provider状態管理パターン

```dart
// provider/change_user_role.dart
class UserRoleProvider extends ChangeNotifier {
  String? _userName;
  
  String? get userName => _userName;  // ゲッター
  
  void login({required String name, ...}) {
    _userName = name;
    notifyListeners();  // ★これでUIに変更を通知
  }
}

// 使用例（画面側）
// 値を取得するだけ（再描画なし）
context.read<UserRoleProvider>().login(...);

// 値を監視（変更時に再描画）
final userName = context.watch<UserRoleProvider>().userName;
```

**ポイント:**
- `ChangeNotifier`を継承してProviderを作成
- `notifyListeners()`を呼ぶとUIが自動更新される
- `read`は1回だけ取得、`watch`は監視して再描画

---

### 2. REST API通信 (OAuth2フォーム形式)

```dart
// services/api_service.dart
Future<dynamic> post(String endpoint, Map<String, dynamic> data, 
    {bool isFormData = false}) async {
  
  dynamic body;
  if (isFormData) {
    // OAuth2ログイン用のフォーム形式
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    body = data.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  } else {
    // 通常のJSON形式
    body = jsonEncode(data);
  }
  
  final response = await http.post(Uri.parse(url), headers: headers, body: body);
  return _handleResponse(response);
}
```

**ポイント:**
- ログインAPIは`application/x-www-form-urlencoded`形式が必要
- `username=xxx&password=yyy`のような形式にエンコード

---

### 3. FastAPI JWT認証

```python
# routers/auth.py
from fastapi.security import OAuth2PasswordRequestForm
from jose import jwt

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # 1. ユーザーを検索
    user = db.query(User).filter(User.email == form_data.username).first()
    
    # 2. パスワード検証（bcryptハッシュと比較）
    if not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=401)
    
    # 3. JWTトークン生成
    token = jwt.encode({"sub": user.email, "role": user.role}, SECRET_KEY)
    return {"access_token": token}

# 認証が必要なエンドポイントでの使用
@router.get("/me")
def get_me(current_user = Depends(get_current_user)):
    return current_user  # トークンから自動でユーザー取得
```

**ポイント:**
- `OAuth2PasswordRequestForm`で標準的なログインフォームを処理
- パスワードは平文保存禁止、bcryptでハッシュ化
- JWTトークンにユーザー情報を埋め込む

---

### 4. 名前衝突の解決方法

```dart
// ❌ 問題: FlutterのNotificationと衝突
import 'package:flutter/material.dart';  // Notification がある
import '../models/database_models.dart';  // 自作Notification もある

// ✅ 解決策1: 自作クラスをリネーム
class AppNotification {  // Notification → AppNotification
  final int? id;
  final String title;
  ...
}

// ✅ 解決策2: インポート時にエイリアスを使う
import '../models/database_models.dart' as models;
// 使用時: models.Notification
```

---

### 5. SQLAlchemy カラム名マッピング

```python
# models.py
class User(Base):
    __tablename__ = "users"
    
    # Pythonでは hashed_password、DBでは password カラム
    hashed_password = Column("password", String(255), nullable=False)
```

**ポイント:**
- `Column("実際のカラム名", ...)` でマッピング可能
- Python側とDB側で異なる命名規則を使える

---

## 10. よくあるエラーと解決法

### CORS エラー
```
Access to XMLHttpRequest has been blocked by CORS policy
```
**原因**: ブラウザがバックエンドへのアクセスをブロック

**解決**: `backend/app/main.py` でCORS設定を確認
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

### パスワードハッシュエラー
```
passlib.exc.UnknownHashError: hash could not be identified
```
**原因**: DBに保存されたハッシュが不正な形式

**解決**: 正しいハッシュを生成して更新
```powershell
# 正しいハッシュを生成
docker exec fastapi_backend python -c "
from passlib.context import CryptContext
pwd = CryptContext(schemes=['bcrypt'], deprecated='auto')
print(pwd.hash('password'))
"

# DBを更新
docker exec fastapi_backend python -c "
import psycopg2
from passlib.context import CryptContext
pwd = CryptContext(schemes=['bcrypt'], deprecated='auto')
hashed = pwd.hash('password')
conn = psycopg2.connect(host='db', database='university_app', user='student', password='password123')
cur = conn.cursor()
cur.execute('UPDATE users SET password = %s', (hashed,))
conn.commit()
"
```

---

### 401 Unauthorized
**原因**: 
- JWTトークンの有効期限切れ
- トークンがヘッダーに含まれていない

**解決**: 再ログインするか、`Authorization: Bearer <token>` ヘッダーを確認

---

## 11. 参考リソース

### Flutter
- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Provider パッケージ](https://pub.dev/packages/provider)
- [http パッケージ](https://pub.dev/packages/http)

### FastAPI
- [FastAPI公式ドキュメント](https://fastapi.tiangolo.com/)
- [SQLAlchemy ORM チュートリアル](https://docs.sqlalchemy.org/en/20/tutorial/)
- [Pydantic ドキュメント](https://docs.pydantic.dev/)

### 認証
- [JWT.io - JWTデバッガー](https://jwt.io/)
- [OAuth2 仕様](https://oauth.net/2/)

### Docker
- [Docker Compose ドキュメント](https://docs.docker.com/compose/)

---

## 12. 今後の課題・拡張アイデア

- [ ] WebSocket によるリアルタイム通知
- [ ] Google Maps API による地図表示・位置追跡
- [ ] 決済機能（Stripe等）の連携
- [ ] プッシュ通知（Firebase Cloud Messaging）
- [ ] 画像アップロード機能
- [ ] 管理者用ダッシュボード
