# デプロイメントガイド

## 概要

このドキュメントでは、Flutter Web + FastAPI + PostgreSQL アプリケーションを AWS EC2 インスタンスにデプロイする方法を説明します。

---

## 環境情報

| 項目 | 値 |
|------|-----|
| **EC2 Elastic IP** | `34.193.170.210` |
| **SSH接続** | `ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210` |
| **フロントエンド URL** | http://34.193.170.210/ |
| **API URL** | http://34.193.170.210/api/ |
| **API ドキュメント** | http://34.193.170.210/api/docs |

---

## 前提条件

### ローカル環境
- Flutter SDK がインストールされていること
- SSH キー (`~/.ssh/ZoneOil.pem`) があること

### EC2 インスタンス
- Docker と Docker Compose がインストールされていること
- セキュリティグループでポート 22, 80, 8000 が開いていること

---

## デプロイ手順

### 1. ローカルでFlutter Webをビルド

```bash
cd /home/morita/software-engineering/Project/src

flutter build web --release \
  --dart-define=API_BASE_URL=http://34.193.170.210/api \
  --dart-define=ENV=production \
  --pwa-strategy=none
```

**ビルド時間**: 約30秒

### 2. ビルドファイルをEC2に転送

```bash
scp -i ~/.ssh/ZoneOil.pem -r \
  /home/morita/software-engineering/Project/src/build/web/* \
  ubuntu@34.193.170.210:~/Project/src/build/web/
```

### 3. EC2でDockerコンテナを起動（初回のみ）

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210

cd ~/Project
docker compose -f docker-compose.simple.yml up -d
```

---

## クイックデプロイ（更新時）

コードを変更した後、以下のコマンドで素早くデプロイできます：

```bash
# 1. ビルド
cd /home/morita/software-engineering/Project/src
flutter build web --release \
  --dart-define=API_BASE_URL=http://34.193.170.210/api \
  --dart-define=ENV=production \
  --pwa-strategy=none

# 2. 転送
scp -i ~/.ssh/ZoneOil.pem -r \
  /home/morita/software-engineering/Project/src/build/web/* \
  ubuntu@34.193.170.210:~/Project/src/build/web/
```

**注意**: Nginxは静的ファイルをボリュームマウントしているため、コンテナの再起動は不要です。

---

## ワンライナーデプロイ

```bash
cd /home/morita/software-engineering/Project/src && \
flutter build web --release --dart-define=API_BASE_URL=http://34.193.170.210/api --dart-define=ENV=production --pwa-strategy=none && \
scp -i ~/.ssh/ZoneOil.pem -r build/web/* ubuntu@34.193.170.210:~/Project/src/build/web/
```

---

## EC2操作コマンド

### SSH接続

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210
```

### コンテナ状態確認

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker ps"
```

### コンテナ起動

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "cd ~/Project && docker compose -f docker-compose.simple.yml up -d"
```

### コンテナ停止

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "cd ~/Project && docker compose -f docker-compose.simple.yml down"
```

### コンテナ再起動

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "cd ~/Project && docker compose -f docker-compose.simple.yml restart"
```

### ログ確認

```bash
# バックエンドログ
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker logs fastapi_backend --tail 50"

# Nginxログ
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker logs flutter_web --tail 50"

# PostgreSQLログ
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker logs postgres_db --tail 50"
```

---

## バックエンド更新時

バックエンドのコードを変更した場合は、イメージを再ビルドする必要があります：

```bash
# 1. ローカルの変更をEC2に転送
rsync -avz --exclude='.git' --exclude='__pycache__' \
  -e "ssh -i ~/.ssh/ZoneOil.pem" \
  /home/morita/software-engineering/Project/backend/ \
  ubuntu@34.193.170.210:~/Project/backend/

# 2. EC2でイメージを再ビルド＆再起動
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "cd ~/Project && docker compose -f docker-compose.simple.yml up -d --build backend"
```

---

## データベース操作

### PostgreSQLに接続

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "docker exec -it postgres_db psql -U student -d university_app"
```

### テーブル一覧表示

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "docker exec postgres_db psql -U student -d university_app -c '\dt'"
```

### ユーザー一覧表示

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "docker exec postgres_db psql -U student -d university_app -c 'SELECT id, email, role FROM users;'"
```

---

## トラブルシューティング

### EC2に接続できない

```bash
# 疎通確認
ping 34.193.170.210

# AWSコンソールでインスタンスの状態を確認
# セキュリティグループでポート22が開いているか確認
```

### コンテナが起動しない

```bash
# エラーログを確認
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "cd ~/Project && docker compose -f docker-compose.simple.yml logs"
```

### APIが応答しない

```bash
# EC2内部からテスト
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 \
  "curl -s http://localhost/api/"

# 外部からテスト
curl -s http://34.193.170.210/api/
```

### ブラウザにキャッシュが残っている

- `Ctrl + Shift + R` でハードリロード
- または `Ctrl + Shift + N` でシークレットウィンドウを開く

---

## ファイル構成

```
Project/
├── docker-compose.simple.yml  # 本番用Docker Compose（シンプル版）
├── docker-compose.prod.yml    # 本番用Docker Compose（フルビルド版）
├── docker-compose.yml         # 開発用Docker Compose
├── .env                       # 環境変数
├── backend/                   # FastAPI バックエンド
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
├── docker/
│   ├── flutter/
│   │   ├── Dockerfile         # 開発用
│   │   └── Dockerfile.prod    # 本番用
│   ├── nginx/
│   │   └── nginx.conf         # Nginx設定
│   └── db/
│       └── init.sql           # DB初期化スクリプト
└── src/                       # Flutter ソースコード
    ├── build/web/             # ビルド済みWebファイル
    ├── lib/
    └── pubspec.yaml
```

---

## 注意事項

1. **HTTPSではない**: 現在HTTPで運用しているため、ブラウザでセキュリティ警告が出ます。本番運用にはHTTPS化が必要です。

2. **EC2インスタンスサイズ**: t2.micro（1GB RAM）では Flutter のビルドがメモリ不足で失敗するため、ローカルでビルドしてから転送しています。

3. **データ永続化**: PostgreSQLのデータは Docker Volume (`db_data`) に保存されています。コンテナを削除してもデータは保持されます。

---

## 今後の改善点

- [ ] HTTPS対応（Let's Encrypt + Certbot）
- [ ] CI/CD パイプライン構築（GitHub Actions）
- [ ] ログ監視・アラート設定
- [ ] バックアップ自動化

---

## コピペ用コマンド集

以下のコマンドをそのままコピー＆ペーストで使用できます。

### フロントエンドデプロイ（ワンライナー）

```bash
cd /home/morita/software-engineering/Project/src && flutter build web --release --dart-define=API_BASE_URL=http://34.193.170.210/api --dart-define=ENV=production --pwa-strategy=none && scp -i ~/.ssh/ZoneOil.pem -r build/web/* ubuntu@34.193.170.210:~/Project/src/build/web/
```

### SSH接続

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210
```

### コンテナ起動

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "cd ~/Project && docker compose -f docker-compose.simple.yml up -d"
```

### コンテナ停止

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "cd ~/Project && docker compose -f docker-compose.simple.yml down"
```

### コンテナ再起動

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "cd ~/Project && docker compose -f docker-compose.simple.yml restart"
```

### コンテナ状態確認

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker ps"
```

### バックエンドログ確認

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker logs fastapi_backend --tail 50"
```

### Nginxログ確認

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker logs flutter_web --tail 50"
```

### PostgreSQL接続

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker exec -it postgres_db psql -U student -d university_app"
```

### ユーザー一覧確認

```bash
ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "docker exec postgres_db psql -U student -d university_app -c 'SELECT id, email, role FROM users;'"
```

### バックエンド更新（ワンライナー）

```bash
rsync -avz --exclude='.git' --exclude='__pycache__' -e "ssh -i ~/.ssh/ZoneOil.pem" /home/morita/software-engineering/Project/backend/ ubuntu@34.193.170.210:~/Project/backend/ && ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "cd ~/Project && docker compose -f docker-compose.simple.yml up -d --build backend"
```

### 全体更新（フロント＋バックエンド）

```bash
cd /home/morita/software-engineering/Project/src && flutter build web --release --dart-define=API_BASE_URL=http://34.193.170.210/api --dart-define=ENV=production --pwa-strategy=none && scp -i ~/.ssh/ZoneOil.pem -r build/web/* ubuntu@34.193.170.210:~/Project/src/build/web/ && rsync -avz --exclude='.git' --exclude='__pycache__' -e "ssh -i ~/.ssh/ZoneOil.pem" /home/morita/software-engineering/Project/backend/ ubuntu@34.193.170.210:~/Project/backend/ && ssh -i ~/.ssh/ZoneOil.pem ubuntu@34.193.170.210 "cd ~/Project && docker compose -f docker-compose.simple.yml up -d --build backend"
```

### API動作確認

```bash
curl -s http://34.193.170.210/api/
```

### 登録テスト

```bash
curl -s -X POST http://34.193.170.210/api/auth/register -H "Content-Type: application/json" -d '{"email":"test@example.com","password":"password123","full_name":"Test User","role":"requester"}'
```
