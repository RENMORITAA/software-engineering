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
├── backend/                # Python (FastAPI) バックエンド
│   ├── app/
│   │   ├── models.py       # ★重要: データベースのテーブル定義 (SQLAlchemy)
│   │   ├── schemas.py      # ★重要: データの送受信ルール (Pydantic)
│   │   ├── main.py         # アプリの起動ファイル
│   │   ├── database.py     # DB接続設定
│   │   └── routers/        # ★重要: APIのエンドポイント (URLごとの処理)
│   │       ├── auth.py     # ログイン・登録関連
│   │       ├── orders.py   # 注文関連
│   │       └── ...
│   ├── Dockerfile          # バックエンドの環境定義
│   └── requirements.txt    # Pythonライブラリ一覧
│
├── docker/
│   └── db/
│       └── init.sql        # ★重要: データベースの初期化SQL (テーブル作成)
│
└── src/                    # Flutter (Dart) フロントエンド
    ├── lib/
    │   ├── main.dart       # アプリの入り口
    │   ├── config/         # 設定関連
    │   │   ├── routes.dart # 画面遷移の定義
    │   │   └── theme.dart  # ★デザイン: 色やフォントの定義
    │   ├── models/         # データ型定義 (バックエンドのschemasに対応)
    │   ├── services/       # ★通信: APIと通信する処理
    │   ├── provider/       # ★状態管理: データを保持・更新して画面に伝える
    │   ├── page/           # ★画面: 各ページのUI実装
    │   ├── component/      # ★部品: ボタンや入力フォームなどの共通部品
    │   └── widgets/        # 小さなUI部品
    └── pubspec.yaml        # Dartライブラリ一覧
```

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
