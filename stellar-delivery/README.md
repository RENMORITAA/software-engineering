# STELLAR-DELIVERY

README を読みやすく整理しました。以下は簡潔な概要と、開発時に使う主要コマンド（PowerShell 例）です。

## 目次
1. プロジェクト構成
2. 各ディレクトリの役割（要点）
3. Docker — よく使うコマンド（PowerShell）
4. フロントエンド開発の流れ（短縮）
5. トラブルシュートのポイント

---

## 1. プロジェクト構成（概観）
```
STELLAR-DELIVERY/
├─ backend/        # API サーバ (FastAPI など)
├─ db/             # 初期 SQL
├─ frontend/       # Flutter ウェブアプリ本体（lib/, web/, Dockerfile）
├─ infra/          # 図やドキュメント
├─ nginx/          # nginx 設定と Dockerfile
├─ .env
└─ docker-compose.yml
```

## 2. 各ディレクトリの役割（要点）
- backend/: サーバーコード（`app/main.py`）。依存は `requirements.txt`。
- db/: 初期化 SQL（`init.sql`）。
- frontend/: Flutter プロジェクト。`lib/` がアプリ本体、`build/web/` が `flutter build web` の出力。
- nginx/: 静的ファイル配信 / リバースプロキシ設定。

編集の影響（短く）:
- `lib/` を編集 → 再ビルドまたはホットリロードで確認 → コンテナへ反映するにはイメージを再ビルド
- `pubspec.yaml` を変更 → `flutter pub get` 実行後にビルド
- nginx を変えたら nginx コンテナを再起動または再ビルド

## 3. Docker — よく使うコマンド（PowerShell）
プロジェクトルートで実行してください。

- 全サービスをビルドして起動（バックグラウンド）:
```powershell
docker compose up -d --build
```

- frontend イメージだけビルド→起動:
```powershell
docker compose build frontend
docker compose up -d frontend
```

- サービス再起動（イメージ再ビルド不要）:
```powershell
docker compose restart backend
```

- 停止とクリーンアップ:
```powershell
docker compose stop
docker compose down
```

- ログやコンテナ状態の確認:
```powershell
docker ps
docker compose logs frontend --follow
docker logs -f stellar_backend
```

※ 環境によっては `docker-compose`（ハイフン）を使う場合があります。最近の Docker Desktop では `docker compose` を推奨します。

## 4. フロントエンド開発の基本フロー

- 既に `build/web` がある場合、素早く確認する:
```powershell
cd frontend\build\web
python -m http.server 8000
# ブラウザで http://localhost:8000 を開く
```

- Docker 内でビルド（Dockerfile の build ステージが Flutter SDK を使う設計）:
```powershell
cd <project-root>
docker compose build frontend
docker compose up -d frontend
```

- コンテナ内で手動ビルド（開発向け）:
```powershell
cd frontend
docker run --rm -it -v "${PWD}:/app" -w /app ghcr.io/cirruslabs/flutter:3.19.0 bash
# コンテナ内で
flutter pub get
flutter build web --release
```

注意: `docker compose run frontend` は Dockerfile の最終ステージ（nginx）からコンテナを作るため、そのコンテナには `flutter` が入っていません。SDK を使うときは `ghcr.io/cirruslabs/flutter` イメージを直接使ってください。

### Docker とビルド時の重要な注意点

- このリポジトリはフロントエンドのビルドを Docker イメージ内の Flutter SDK で行う設計です。したがってソースを編集した場合は、ホスト側で単にファイルを保存してもコンテナ内の配信イメージに自動反映されません。必ずフロントエンドのイメージを再ビルドしてコンテナを再起動してください。推奨コマンド:
```powershell
# 変更を取り込んで frontend を再ビルドして起動
docker compose build frontend
docker compose up -d frontend
```

- Dockerfile や Flutter SDK バージョンを変更した場合は、依存イメージが差し替わるためフルビルドが必要です（安全のため一度 down してから再ビルド/起動することを推奨します）:
```powershell
docker compose down
docker compose up -d --build
```

- Docker デスクトップや Docker デーモン自体を再起動したい場合（例: Docker を更新した、または環境に変化があった場合）は、GUI の Docker Desktop を再起動するか、必要に応じて `docker compose down` → `docker compose up -d` を行ってください。Windows のサービスを直接操作するより、Compose でコンテナを再作成する方法が確実です。

- 配信先ポートの注意:
	- `docker-compose.yml` では `frontend` サービスをホストのポート `5173` にマップしています（`5173:80`）。そのためビルド済みの静的ファイルを直接確認する場合は `http://localhost:5173` を開いてください。
	- 一方で `nginx` サービス（もし起動している場合）はホストの `80` ポートを使っており、プロキシ設定や追加のルールが適用された状態で配信されます。開発時はどちらのサービスを使うか意識して開いてください（`nginx` 経由 = `http://localhost`、`frontend` 直接 = `http://localhost:5173`）。

---

## 5. トラブルシュート（よくある点）
- ホストに `flutter` が無いエラー → Docker ビルド設計なので、Docker を使ってビルドすればよい。
- PowerShell で角括弧を入れたコマンド（例: `flutter run -d <device>`）は構文エラーになる → 実際は `flutter run -d chrome` のように実デバイス名を使う。
- ボリュームマウントのパス問題 → PowerShell では `"${PWD}:/app"` の形式が安全。

---

今後の改善案（任意）:
- 開発用の Dockerfile（ホットリロード対応）を追加
- CI で `flutter build web` → イメージ作成 → レジストリへ push するワークフローを整備
- README に `docker compose` と `docker-compose` の互換メモを追加

必要なら私が上のどれか（例: 開発用 Dockerfile の追加）を作成します。指定してください。
