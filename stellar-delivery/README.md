Stellar Delivery
=================

このリポジトリは、簡易的なバックエンド（FastAPI/Python）とフロントエンド（Flutter Web）を Docker Compose で起動できるサンプルプロジェクトです。

この README には、セットアップ手順、開発フロー、Docker を使った起動方法、よくあるトラブルシュートを日本語でまとめています。

目次
--

- 前提
- リポジトリ構成
- ローカル開発（推奨）
  - バックエンドをローカルで動かす
  - フロントエンド（Flutter）をローカルで動かす
- Docker / Docker Compose を使った実行
  - 初回ビルド & 起動
  - 再ビルド（キャッシュ無視）
  - 停止・ログ確認
- 開発時のヒント（Windows / PowerShell）
- よくある問題と対処
- 変更履歴・次の作業

前提
--

- Docker Desktop（Windows なら WSL2 経由の設定を推奨）
- docker compose（Docker Desktop に同梱）
- （ローカルで Flutter を使う場合）Flutter SDK（`flutter` コマンドが使えること）
- Git

リポジトリ構成（重要ファイル）
--

- `docker-compose.yml` - サービス定義（db, backend, frontend, nginx）
- `backend/` - Python バックエンドと Dockerfile
  - `backend/app/main.py` など（FastAPI アプリケーション）
  - `backend/requirements.txt`
- `frontend/` - Flutter プロジェクトと Dockerfile
  - `frontend/pubspec.yaml`
  - `frontend/lib/` - Flutter のソース (`main.dart`)
  - `frontend/web/` - Flutter Web のソース/テンプレート
- `nginx/` - リバースプロキシ設定（`default.conf`）
- `db/init.sql` - DB 初期化 SQL

推奨プロジェクト構成（例）
```
project-root/
├─ docker-compose.yml        # 開発用
├─ .env                      # 開発用環境変数
├─ backend/
│   ├─ Dockerfile
│   ├─ app/
│   │   └─ main.py
│   └─ requirements.txt
├─ frontend/
│   ├─ Dockerfile
│   ├─ lib/
│   ├─ web/
│   └─ pubspec.yaml
├─ nginx/
│   ├─ dev.conf
│   ├─ prod.conf
│   └─ Dockerfile
├─ db/
│   └─ init.sql
└─ infra/
  ├─ terraform/            # (AWSデプロイ用)
  ├─ ecs-task-def.json
  └─ ecr-push.sh
```

ローカル開発（推奨）
--

目的に応じてバックエンド／フロントエンドをローカルで直接実行できます。開発ループが速くなります。

バックエンドをローカルで動かす（Python / FastAPI）

PowerShell 例:

```powershell
cd C:\Users\mrenk\software-engineering\stellar-delivery\backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
# uvicorn で起動（デバッグ用）
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API が起動したら http://localhost:8000/docs で OpenAPI ドキュメントが見えるはずです。

フロントエンド（Flutter）をローカルで動かす

ローカルで Flutter を使って編集 → ホットリロードする流れ:

```powershell
cd C:\Users\mrenk\software-engineering\stellar-delivery\frontend
# もしプロジェクトが未作成なら: flutter create . --platforms=web
flutter pub get
# Chrome で実行 (ホットリロード可能)
flutter run -d chrome
```

ビルドして静的ファイルを生成する（配布/コンテナ用）:

```powershell
cd frontend
flutter build web --release
# 成果物は frontend/build/web に生成されます
```

Docker / Docker Compose を使った実行
--

Docker を使うと、環境を揃えて一発で起動できます。以下は PowerShell 用のコマンド例です。

初回ビルド & 起動

```powershell
cd C:\Users\mrenk\software-engineering\stellar-delivery
# フロントやバックエンドの Docker イメージをビルドして起動（バックグラウンド）
docker compose up -d --build
# 起動中のサービス一覧を確認
docker compose ps
```

個別にフロントのみビルドしたい場合:

```powershell
docker compose build frontend
docker compose up -d frontend
```

再ビルド（キャッシュ無視）

変更がイメージに反映されない場合、キャッシュを無視して再ビルドします:

```powershell
docker compose build --no-cache frontend
docker compose up -d frontend
```

停止 & クリーン

```powershell
# 全サービス停止・削除（コンテナ・ネットワーク）
docker compose down
# イメージやボリュームも完全に消す場合（注意: データ消える）
docker compose down --rmi all --volumes --remove-orphans
```

ログ確認

```powershell
# 全サービスのログを追う
docker compose logs -f
# 特定サービスのログ（フロント）
docker compose logs -f frontend
```

コンテナ内コマンド実行

```powershell
# フロントコンテナに入ってファイルを確認する例
docker compose exec frontend sh
# 例: nginx が配信しているファイルをみる
docker compose exec frontend cat /usr/share/nginx/html/index.html
```

ポート割り当て

- フロント: ホスト 5173 -> コンテナ 80
- バックエンド: ホスト 8000 -> コンテナ 8000
- DB (MySQL): ホスト 3306 -> コンテナ 3306
- nginx (リバースプロキシ): ホスト 80 -> コンテナ 80

注意: どのサービスにアクセスするかによりポートを指定してください。フロントは http://localhost:5173 を開くのが直接的です。

開発時のヒント（Windows / PowerShell）
--

- PowerShell では `||` などのシェル演算子は使えません。複数コマンドを繋ぐ場合は `;` や `Start-Process` 等を使ってください。
- Docker のボリュームマウントで Windows のパスがうまく動かないことがあります（特に WSL2 と組み合わせたとき）。その場合は次のいずれかを試してください:
  - WSL2 の中で操作する（`wsl` を使ってリポジトリに移動して実行）。
  - ホストのビルド成果物を使う代わりに Dockerfile のマルチステージビルドでイメージに成果物を内包する。

よくある問題と対処
--

1) docker compose 実行時に出る警告: `the attribute 'version' is obsolete` 
   - 対処: `docker-compose.yml` の先頭にある `version: "3.9"` 行は無害ですが、警告を消したければ削除しても構いません。Compose v2/v3 の互換性に問題はありません。

2) Dockerfile の `COPY` で `"/frontend": not found` と言われる
   - 原因: Dockerfile の `COPY ./frontend /app` のように、ビルドコンテキストの外をコピーしようとした場合に発生します。
   - 対処: Dockerfile 側で `COPY . /app` のように書くか、`docker-compose.yml` の `build.context` を修正してビルドコンテキストを正しく設定します。

3) Flutter 実行時に `You appear to be trying to run flutter as root` の警告
   - 警告はビルドが止まる原因ではありません。気になる場合は Dockerfile 内で非 root ユーザーに切り替えることも可能です。

4) フロントがプレースホルダ（"Building Flutter web... (placeholder)"）を返す
   - 原因: `frontend/web/index.html` がプレースホルダのまま、あるいは nginx が古いファイルを配信している。
   - 対処: `flutter build web` を実行して `frontend/build/web` を作成し、Docker イメージを再ビルドする、またはホストの `build/web` をコンテナにマウントして nginx が正しいファイルを配信するようにします（開発用）。

5) マウントしたボリュームがコンテナ内で見えない・ファイルがない
   - Windows のファイル共有やパスの問題が多いです。WSL2 を利用している場合は WSL の中でコマンドを実行するほうが確実です。代替はイメージ内にビルド成果物を含める方法です。

その他のコマンド（便利）
--

```powershell
# 画像やアセットを再生成したいとき
cd frontend
flutter clean
flutter pub get
flutter build web --release

# Docker イメージをまとめて消す（注意）
docker system prune --all --volumes
```

将来の改善案 / 次の作業
--

- CI を導入して、`flutter build web` と `docker build` を自動化（GitHub Actions 等）。
- フロントとバックエンド間の API 契約を作成し、E2E テストを追加。 
- 開発向けに `docker-compose.override.yml` を用意し、ボリュームマウントとホットリロードをサポートする。 

サポート
--

問題が起きたら、以下情報を共有してください:
- 実行したコマンドとその出力（エラーメッセージ）
- `docker compose ps` と `docker compose logs <service>` の出力（該当サービス）
- 使用している OS（Windows の場合は PowerShell/WSL2 の有無）

---

README を作成しました。必要ならこの README にプロジェクト固有の追加情報（API エンドポイント一覧や DB スキーマの詳細など）を追記します。