# トラブルシューティングガイド・障害処理表

**作成日**: 2026年1月14日  
**最終更新**: 2026年1月14日  
**対象システム**: Stellar Delivery アプリケーション（Docker/Flutter/FastAPI）

---

## 概要

本ドキュメントは、Stellar Delivery アプリケーション運用中に発生する可能性のある障害とその対処方法を記載しています。

---

## 障害処理表

### INF-001: Flask/FastAPI サーバーが起動しない

| 項目 | 内容 |
|------|------|
| **障害ID** | INF-001 |
| **優先度** | 🔴 **高** |
| **症状** | `docker compose up` 実行時に FastAPI バックエンドが起動しない、または起動直後にクラッシュする |
| **エラーメッセージ例** | `ERROR: for fastapi_backend Cannot assign requested address` / `Traceback (most recent call last)...` |
| **原因** | 1. ポート 8000 がすでに使用中<br>2. `requirements.txt` の依存関係が破損<br>3. Python インタプリタの問題<br>4. 環境変数の不足（DATABASE_URL 未設定） |
| **対処方法** | **手順 1**: ポート確認<br>`netstat -ano \| findstr :8000` でプロセス確認<br>**手順 2**: ポートがふさがっている場合<br>`docker compose down` で完全停止<br>**手順 3**: イメージ再構築<br>`docker compose build --no-cache backend`<br>**手順 4**: ログ確認<br>`docker compose logs backend --tail=50`<br>**手順 5**: 環境変数確認<br>`docker compose config` で DATABASE_URL が設定されているか確認<br>**手順 6**: 起動<br>`docker compose up -d` |
| **予防策** | ・起動前に既存コンテナを確認: `docker ps -a`<br>・定期的にイメージを削除: `docker image prune -a`<br>・ログを監視: `docker compose logs -f backend` |
| **参考コマンド** | `docker compose logs backend --tail=100` |

---

### INF-002: PostgreSQL データベース接続エラー

| 項目 | 内容 |
|------|------|
| **障害ID** | INF-002 |
| **優先度** | 🔴 **高** |
| **症状** | FastAPI がデータベースに接続できず、すべての API リクエストが失敗する |
| **エラーメッセージ例** | `psycopg2.OperationalError: could not connect to server: Connection refused` / `FATAL: database does not exist` |
| **原因** | 1. PostgreSQL コンテナが起動していない<br>2. DATABASE_URL が間違っている<br>3. ポート 5432 が塞がっている<br>4. データベース初期化スクリプトが実行されていない |
| **対処方法** | **手順 1**: データベース接続確認<br>`docker compose exec db psql -U postgres -c "SELECT 1"`<br>**手順 2**: 初期化スクリプト実行<br>`docker compose exec db psql -U postgres < docker/db/init.sql`<br>**手順 3**: バックエンド再起動<br>`docker compose restart backend`<br>**手順 4**: API テスト<br>`curl http://localhost:8000/docs` でSwagger UI が表示されるか確認<br>**手順 5**: 最後の手段 - 完全リセット<br>`docker compose down -v` (全データ削除)<br>`docker compose up -d` |
| **予防策** | ・`docker-compose.yml` の `depends_on` で backend が db に依存していることを確認<br>・DB ヘルスチェック設定を確認: `healthcheck` セクション<br>・初期化スクリプトを確認: `docker/db/init.sql` が存在するか確認 |
| **参考コマンド** | `docker compose logs db --tail=50` |

---

### INF-003: Flutter Web アプリが起動しない

| 項目 | 内容 |
|------|------|
| **障害ID** | INF-003 |
| **優先度** | 🔴 **高** |
| **症状** | `docker compose up` 実行時に Flutter コンテナが起動しない、または `http://localhost:8080` にアクセスできない |
| **エラーメッセージ例** | `Error: unable to locate asset entry in pubspec.yaml` / `Failed to compile application` / `Connection refused` |
| **原因** | 1. `pubspec.yaml` に存在しないアセットが参照されている<br>2. Flutter SDK のダウンロード失敗<br>3. ポート 8080 がすでに使用中<br>4. ブラウザキャッシュの問題 |
| **対処方法** | **手順 1**: コンテナログ確認<br>`docker compose logs flutter --tail=100`<br>**手順 2**: `pubspec.yaml` の確認<br>`src/pubspec.yaml` でフォント参照を確認（存在しないフォントを削除）<br>**手順 3**: キャッシュクリア<br>`docker compose down`<br>`docker system prune -a`<br>**手順 4**: 再構築<br>`docker compose build --no-cache flutter`<br>**手順 5**: 起動<br>`docker compose up -d flutter`<br>**手順 6**: ブラウザ再起動<br>Ctrl+Shift+Delete でブラウザキャッシュクリア |
| **予防策** | ・`pubspec.yaml` の assets セクションを定期的に確認<br>・フォント追加時は実際にファイルが存在することを確認<br>・ブラウザのデベロッパーツール (F12) でコンソールエラーを監視 |
| **参考コマンド** | `docker compose logs flutter -f` (ログ監視) |

---

### INF-004: ポートがすでに使用中

| 項目 | 内容 |
|------|------|
| **障害ID** | INF-004 |
| **優先度** | 🟡 **中** |
| **症状** | `docker compose up` 実行時に「Port already in use」エラーが発生 |
| **エラーメッセージ例** | `listen tcp 0.0.0.0:8080: bind: address already in use` |
| **原因** | 1. 前回のコンテナが完全に停止していない<br>2. 他のアプリケーションがポートを使用している<br>3. Windows の Time-Wait 状態のソケットが残っている |
| **対処方法** | **手順 1**: 全コンテナ確認<br>`docker ps -a`<br>**手順 2**: 全停止<br>`docker compose down`<br>**手順 3**: ポート確認（Windows）<br>`netstat -ano \| findstr :8080`<br>**手順 4**: プロセス終了（必要に応じて）<br>`taskkill /PID <PID> /F`<br>**手順 5**: 少し待機<br>`Start-Sleep -Seconds 5`<br>**手順 6**: 再起動<br>`docker compose up -d` |
| **予防策** | ・終了時に必ず `docker compose down` を使用<br>・複数のプロジェクトを同時に実行しない<br>・定期的に `docker container prune` を実行 |
| **参考コマンド** | `docker ps -a` / `netstat -ano` |

---

### APP-001: ログイン失敗 - ユーザーが見つからない

| 項目 | 内容 |
|------|------|
| **障害ID** | APP-001 |
| **優先度** | 🟡 **中** |
| **症状** | ログイン画面で正しいメールアドレスとパスワードを入力しても「ログインに失敗しました」と表示される |
| **エラーメッセージ例** | `ログインに失敗しました: User not found` / `Invalid credentials` |
| **原因** | 1. ユーザーアカウントがデータベースに存在しない<br>2. メールアドレスが大文字小文字で異なる<br>3. パスワードのハッシュ化に失敗している<br>4. データベースが初期化されていない |
| **対処方法** | **手順 1**: テストユーザーが存在するか確認<br>`docker compose exec db psql -U postgres -d stellar -c "SELECT id, email, role FROM users LIMIT 10;"`<br>**手順 2**: テストユーザーが存在しない場合、新規登録<br>アプリの「新規会員登録」から依頼者として登録<br>メール: `test@example.com`<br>パスワード: `password123`<br>**手順 3**: 登録がうまくいかない場合、手動で INSERT<br>`docker compose exec db psql -U postgres -d stellar -c "INSERT INTO users (email, role, password_hash) VALUES ('test@example.com', 'requester', 'hash');"` (注: ハッシュ化が必要)<br>**手順 4**: キャッシュクリア<br>ブラウザの LocalStorage をクリア<br>**手順 5**: ログイン再試行 |
| **予防策** | ・新規登録フロー完成させる<br>・メール大文字小文字を統一：登録時に `toLowerCase()` を使用<br>・パスワード検証ログを記録 |
| **参考コマンド** | `docker compose exec db psql -U postgres -d stellar -c "\\dt"` (テーブル確認) |

---

### APP-002: 認証トークンの有効期限切れ

| 項目 | 内容 |
|------|------|
| **障害ID** | APP-002 |
| **優先度** | 🟡 **中** |
| **症状** | ログイン後、しばらく使用していないと突然ログイン画面に戻される |
| **エラーメッセージ例** | `Unauthorized: Token expired` / 401 Unauthorized |
| **原因** | 1. JWT トークンの有効期限が切れている（デフォルト: 24時間）<br>2. トークンのリフレッシュ機構が実装されていない<br>3. SharedPreferences に保存されたトークンが古い |
| **対処方法** | **手順 1**: トークン有効期限確認<br>`backend/app/config.py` の `TOKEN_EXPIRE_MINUTES` を確認<br>**手順 2**: 開発環境では有効期限を延長<br>`.env` ファイルで `TOKEN_EXPIRE_MINUTES=1440` (24時間) に設定<br>**手順 3**: リフレッシュトークン機構の実装を検討<br>API エンドポイント `POST /auth/refresh` を追加<br>**手順 4**: フロントエンド側でリフレッシュ処理を実装<br>API レスポンスが 401 の場合、リフレッシュトークンで新しいトークンを取得<br>**手順 5**: テスト<br>ログイン後、有効期限を待たずに再ログイン |
| **予防策** | ・リフレッシュトークン機構を実装<br>・トークン有効期限をアプリで事前に確認<br>・定期的にトークンを自動リフレッシュ（5分ごと） |
| **参考コマンド** | `docker compose logs backend -f --tail=50` |

---

### APP-003: API が 404 エラーを返す

| 項目 | 内容 |
|------|------|
| **障害ID** | APP-003 |
| **優先度** | 🟡 **中** |
| **症状** | API リクエストが `404 Not Found` エラーを返す |
| **エラーメッセージ例** | `GET http://localhost:8000/api/stores 404 Not Found` |
| **原因** | 1. API エンドポイントが実装されていない<br>2. ベース URL が間違っている<br>3. バージョンプレフィックスが異なる（`/api/v1/` vs `/api/`）<br>4. FastAPI ルーターが正しく登録されていない |
| **対処方法** | **手順 1**: FastAPI Swagger UI で利用可能なエンドポイントを確認<br>`http://localhost:8000/docs`<br>**手順 2**: エンドポイント一覧から必要なパスを確認<br>（例: `/stores/` が実装されているか）<br>**手順 3**: ベース URL を確認<br>`src/lib/config/env_config.dart` で API_BASE_URL が正しいか確認<br>（開発: `http://localhost:8000`、本番: 本番 URL）<br>**手順 4**: エンドポイントが実装されていない場合<br>`backend/app/routers/` に新しいルーターファイルを作成<br>例: `stores.py` に `GET /stores` を実装<br>`app.include_router(stores.router, prefix="/stores")`<br>**手順 5**: バックエンド再起動<br>`docker compose restart backend` |
| **予防策** | ・エンドポイント追加時に Swagger UI で確認<br>・API ドキュメントを最新に保つ<br>・ルーターの登録順序を確認 |
| **参考コマンド** | `curl http://localhost:8000/docs` / `docker compose logs backend` |

---

### APP-004: CORS エラーが発生

| 項目 | 内容 |
|------|------|
| **障害ID** | APP-004 |
| **優先度** | 🟡 **中** |
| **症状** | ブラウザコンソールに `CORS error` が表示され、API リクエストがブロックされる |
| **エラーメッセージ例** | `Access to XMLHttpRequest at 'http://localhost:8000/auth/login' from origin 'http://localhost:8080' has been blocked by CORS policy` |
| **原因** | 1. FastAPI の CORS 設定が不正<br>2. オリジン（origin）がホワイトリストに登録されていない<br>3. 環境（Docker vs ローカル）で URL が異なる |
| **対処方法** | **手順 1**: FastAPI CORS 設定確認<br>`backend/app/main.py` の CORSMiddleware 設定を確認<br>**手順 2**: CORS 設定を更新<br>```python<br>from fastapi.middleware.cors import CORSMiddleware<br><br>app.add_middleware(<br>    CORSMiddleware,<br>    allow_origins=["http://localhost:8080", "http://0.0.0.0:8080"],<br>    allow_credentials=True,<br>    allow_methods=["*"],<br>    allow_headers=["*"],<br>)<br>```<br>**手順 3**: バックエンド再起動<br>`docker compose restart backend`<br>**手順 4**: ブラウザキャッシュクリア<br>Ctrl+Shift+Delete<br>**手順 5**: API 再試行 |
| **予防策** | ・Docker 内での通信: `http://flutter:8080` / `http://backend:8000`<br>・ホスト側の通信: `http://localhost:8080` / `http://localhost:8000`<br>・本番環境では明確なドメインを指定 |
| **参考コマンド** | `docker compose logs backend --tail=50` |

---

### APP-005: ユーザー名が表示されない

| 項目 | 内容 |
|------|------|
| **障害ID** | APP-005 |
| **優先度** | 🟢 **低** |
| **症状** | ログイン後、ホーム画面にユーザー名が表示されず、「名前不明」と表示される |
| **エラーメッセージ例** | ホーム画面: 「こんにちは、名前不明 さん」 |
| **原因** | 1. ログイン時に `/auth/me` エンドポイントが正しいデータを返していない<br>2. UserRoleProvider に name が正しく渡されていない<br>3. SharedPreferences に名前が保存されていない<br>4. プロフィール取得が失敗している |
| **対処方法** | **手順 1**: ブラウザ DevTools で LocalStorage 確認<br>F12 > Application > Local Storage<br>**手順 2**: `user_name` キーが存在するか確認<br>存在しない場合、ログイン時にプロフィール取得が失敗している<br>**手順 3**: API ログを確認<br>`docker compose logs backend --tail=50`<br>**手順 4**: ユーザーテーブルが正しく登録されているか確認<br>`docker compose exec db psql -U postgres -d stellar -c "SELECT id, email, name, role FROM users WHERE email = 'requester@test.com';"`<br>**手順 5**: `/auth/me` エンドポイントをテスト<br>`curl -H "Authorization: Bearer <TOKEN>" http://localhost:8000/auth/me`<br>**手順 6**: ユーザー名が返されない場合、バックエンドの実装を確認<br>`backend/app/routers/auth.py` の `/auth/me` を確認<br>**手順 7**: キャッシュクリア<br>ブラウザ LocalStorage をクリア + ページリロード |
| **予防策** | ・ユーザー登録時に name フィールドを必須化<br>・ログイン後に `/auth/me` が正しいデータを返すことを確認<br>・Provider の値をデバッグプリント |
| **参考コマンド** | `docker compose logs backend -f` |

---

### DB-001: データベーステーブルが存在しない

| 項目 | 内容 |
|------|------|
| **障害ID** | DB-001 |
| **優先度** | 🔴 **高** |
| **症状** | API リクエスト時に `relation "users" does not exist` エラーが発生 |
| **エラーメッセージ例** | `ProgrammingError: relation "users" does not exist` |
| **原因** | 1. 初期化スクリプト（init.sql）が実行されていない<br>2. データベースが新しく作成されたが、初期化されていない<br>3. マイグレーション処理が実行されていない |
| **対処方法** | **手順 1**: テーブル一覧確認<br>`docker compose exec db psql -U postgres -d stellar -c "\\dt"`<br>**手順 2**: テーブルが存在しない場合、init.sql を実行<br>`docker compose exec db psql -U postgres -d stellar < docker/db/init.sql`<br>**手順 3**: 実行権限エラーが出た場合<br>`docker compose exec db psql -U postgres -d stellar -f /docker-entrypoint-initdb.d/init.sql`<br>**手順 4**: 完全リセット（データベースごと削除）<br>`docker compose down -v`<br>`docker compose up -d`<br>**手順 5**: テーブル再確認<br>`docker compose exec db psql -U postgres -d stellar -c "\\dt"` |
| **予防策** | ・`docker-compose.yml` の `postgres` サービスで initdb スクリプトを確認<br>・`docker/db/init.sql` が存在することを確認<br>・コンテナ起動時にログを監視: `docker compose logs db` |
| **参考コマンド** | `docker compose exec db psql -U postgres -d stellar -c "\\dt"` |

---

### DB-002: データベース接続プール枯渇

| 項目 | 内容 |
|------|------|
| **障害ID** | DB-002 |
| **優先度** | 🟡 **中** |
| **症状** | 複数の API リクエストを送信すると、接続がタイムアウトし始める |
| **エラーメッセージ例** | `QueuePool timeout of 30.00 seconds exceeded` / `connection pool is exhausted` |
| **原因** | 1. SQLAlchemy の接続プール設定が不適切<br>2. 接続がクローズされていない（リソースリーク）<br>3. 同時リクエスト数が多すぎる |
| **対処方法** | **手順 1**: SQLAlchemy プール設定確認<br>`backend/app/database.py` の engine 設定を確認<br>**手順 2**: プール設定を調整<br>```python<br>engine = create_engine(<br>    DATABASE_URL,<br>    poolclass=StaticPool,  # SQLite の場合<br>    pool_size=20,          # PostgreSQL の場合<br>    max_overflow=0,<br>    pool_pre_ping=True,    # 接続確認<br>)<br>```<br>**手順 3**: セッションがクローズされていることを確認<br>すべてのルーターで `try-finally` または `with` ステートメントを使用<br>**手順 4**: バックエンド再起動<br>`docker compose restart backend`<br>**手順 5**: ロードテスト<br>複数リクエストを送信: `ab -n 100 -c 10 http://localhost:8000/stores/` |
| **予防策** | ・接続プーイングを設定<br>・各ルートで必ずセッションをクローズ<br>・ロードテストを定期的に実施 |
| **参考コマンド** | `docker compose logs backend -f` |

---

## クイック実行コマンド集

### よく使う コマンド

```bash
# ==================== コンテナ管理 ====================
# 全コンテナ起動
docker compose up -d

# 全コンテナ停止
docker compose down

# 全コンテナ停止 + ボリューム削除（データベース初期化）
docker compose down -v

# コンテナ一覧表示
docker compose ps

# イメージ再構築
docker compose build --no-cache

# ==================== ログ確認 ====================
# Flask/FastAPI ログ
docker compose logs backend --tail=50

# Flutter ログ
docker compose logs flutter --tail=50

# PostgreSQL ログ
docker compose logs db --tail=50

# すべてのログ（リアルタイム）
docker compose logs -f

# ==================== データベース操作 ====================
# PostgreSQL に接続
docker compose exec db psql -U postgres -d stellar

# テーブル一覧表示
docker compose exec db psql -U postgres -d stellar -c "\dt"

# ユーザー一覧表示
docker compose exec db psql -U postgres -d stellar -c "SELECT id, email, name, role FROM users LIMIT 10;"

# 初期化スクリプト実行
docker compose exec db psql -U postgres -d stellar < docker/db/init.sql

# ==================== API テスト ====================
# Swagger UI を開く
# http://localhost:8000/docs

# ログインテスト
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"requester@test.com","password":"password123"}'

# 認証付きリクエスト
curl -H "Authorization: Bearer <TOKEN>" http://localhost:8000/auth/me

# ==================== ブラウザアクセス ====================
# Flutter Web アプリ
# http://localhost:8080

# FastAPI Swagger
# http://localhost:8000/docs

# FastAPI ReDoc
# http://localhost:8000/redoc

# ==================== システムクリーニング ====================
# 未使用イメージ削除
docker image prune -a

# 未使用コンテナ削除
docker container prune

# すべてクリーンアップ（危険）
docker system prune -a --volumes
```

---

## トラブルシューティング フローチャート

```
アプリケーションが起動しない
│
├─ ポート使用中エラー？
│  └─ YES → docker compose down & netstat -ano | findstr :8080 で確認 → コマンド参照: INF-004
│
├─ Flask エラー？
│  └─ YES → docker compose logs backend --tail=100 で確認 → コマンド参照: INF-001
│
├─ PostgreSQL エラー？
│  └─ YES → docker compose logs db --tail=50 で確認 → コマンド参照: INF-002
│
├─ Flutter エラー？
│  └─ YES → docker compose logs flutter --tail=100 で確認 → コマンド参照: INF-003
│
└─ その他 → docker compose logs -f で全ログ確認

ログイン/認証の問題
│
├─ ログイン失敗？
│  └─ YES → テストユーザーが存在するか確認 → コマンド参照: APP-001
│
├─ トークン有効期限？
│  └─ YES → TOKEN_EXPIRE_MINUTES を確認 → コマンド参照: APP-002
│
└─ その他 → API ログを確認

API の問題
│
├─ 404 Not Found？
│  └─ YES → http://localhost:8000/docs で利用可能なエンドポイント確認 → コマンド参照: APP-003
│
├─ CORS エラー？
│  └─ YES → FastAPI CORS 設定確認 → コマンド参照: APP-004
│
└─ その他 → curl でエンドポイントテスト

表示の問題
│
└─ ユーザー名が表示されない？
   └─ YES → LocalStorage で user_name を確認 → コマンド参照: APP-005
```

---

## よくある質問（FAQ）

### Q1: 「docker-compose: command not found」と表示される

**A**: Docker Compose がインストールされていないか、パスが設定されていません。

```powershell
# インストール確認
docker compose version

# Docker Desktop 内に Compose が含まれているはずです
# 再インストールしてください
```

### Q2: Windows Subsystem for Linux (WSL) でエラーが出る

**A**: Docker Desktop の統合設定を確認してください。

```powershell
# Docker が WSL に接続されているか確認
wsl -l -v

# Docker Desktop Settings > Resources > WSL Integration で有効化
```

### Q3: アプリケーションが遅い/レスポンスが遅い

**A**: 以下を確認してください：

```bash
# Docker メモリ使用状況確認
docker stats

# CPU 使用率が高い場合、Docker Desktop の リソース設定を増加
# Docker Desktop Settings > Resources > CPU/Memory を増やす
```

### Q4: 定期的にログイン状態が失われる

**A**: トークン有効期限の問題です。

```python
# backend/app/config.py
TOKEN_EXPIRE_MINUTES = 1440  # 24時間に変更
```

### Q5: 新しい API エンドポイントが反映されない

**A**: バックエンドの再起動またはホットリロードを確認してください。

```bash
# バックエンド再起動
docker compose restart backend

# または
docker compose up -d --force-recreate backend
```

---

## エスカレーション手順

### レベル 1 - 自己復旧（オペレータ）

1. ログを確認
2. 関連ドキュメントを参照
3. クイックコマンドで対応
4. 解決しない場合 → レベル 2 へ

### レベル 2 - 開発チーム対応

1. 詳細ログを収集
2. Git で最新版にアップデート
3. イメージ再構築
4. 完全リセット（down -v → up）
5. 解決しない場合 → レベル 3 へ

### レベル 3 - 運用チーム対応

1. インフラ設定確認（ファイアウォール、ネットワーク）
2. リソース（CPU/メモリ）確認
3. 本番環境との差分確認
4. バックアップからの復旧

---

## 障害報告フォーマット

問題が発生した場合、以下の情報を記載してください：

```
【発生日時】
2026年1月14日 18:30

【障害ID】
（該当する場合のみ）

【症状】
何が起こったのか

【エラーメッセージ】
コンソールに表示されたエラー内容

【環境情報】
- OS: Windows 11
- Docker Version: 4.26.0
- Flutter Version: 3.10.1

【再現手順】
1. ...
2. ...
3. ...

【ログ】
docker compose logs --tail=100

【トライ済みの対処】
- ...
- ...

【現在のステータス】
- 未解決 / 部分的に解決 / 完全解決
```

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-01-14 | 初版作成 |
| | - INF: インフラ関連障害（4件） |
| | - APP: アプリケーション障害（5件） |
| | - DB: データベース障害（2件） |
| | - クイックコマンド集 |
| | - トラブルシューティング フローチャート |

---

## 関連ドキュメント

- [TEST_RESULTS.md](TEST_RESULTS.md) - テスト結果
- [FUTURE_FEATURES_PLAN.md](FUTURE_FEATURES_PLAN.md) - 今後の実装予定
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) - 開発計画

