STELLAR-DELIVERY
=================

目次

1. プロジェクト構成（簡潔版）
2. 各ディレクトリ / ファイルの役割（詳細）
3. Docker — よく使うコマンド
4. フロントエンド開発（どのファイルを変えると何が起きるか）
5. 開発時の便利なコマンド / ログの見方 / トラブル対処

1. プロジェクト構成（簡潔版）
```
STELLAR-DELIVERY/
├─ backend/
│  ├─ app/
│  │  └─ main.py
│  ├─ Dockerfile
│  └─ requirements.txt
├─ db/
│  └─ init.sql
├─ frontend/
│  ├─ lib/            # Flutter/Dart アプリ本体（ロジック・ウィジェット）
│  ├─ web/            # web 用のエントリ / index.html 等
│  ├─ build/web/      # ビルド出力（生成される）
│  ├─ pubspec.yaml
│  └─ Dockerfile
├─ infra/
│  └─ er_diagram.mmd
├─ nginx/
│  ├─ default.conf
│  ├─ dev.conf
│  ├─ prod.conf
│  └─ Dockerfile
├─ .env
└─ docker-compose.yml
```

2. 各ディレクトリ / ファイルの役割（詳細）

backend/

app/main.py

FastAPI（例）等のサーバアプリ本体。API エンドポイント、起動設定などが書かれる場所。

Dockerfile

バックエンド用のイメージを作る定義。Python 環境や依存のインストール、uvicorn 実行コマンドなどが書かれる。

requirements.txt

Python パッケージ一覧（pip install -r requirements.txt）。

→ 編集の影響：main.py を編集したら（ソース修正）コンテナを再ビルド／再起動する必要があります（後述）。

db/

init.sql

初期テーブル作成や初期データ挿入など。MySQL コンテナ起動時に適用される（docker compose のボリューム / 初期化で使う想定）。

frontend/

lib/

Flutter/Dart のメインコード（ウィジェット、画面、ビジネスロジック）。

ここを編集するとアプリの見た目・挙動が変わります。

web/

Web ビルド用のエントリ（index.html など）。Web 固有の meta や JS ラッパーなど。

build/web/

flutter build web で生成される静的ファイル群（この出力を nginx や静的サーバで配る）。

pubspec.yaml / pubspec.lock

依存パッケージ、アセット指定など。

Dockerfile

フロントをビルドして静的ファイルを出力し（またはサーバを立て）コンテナに組み込むための定義。

→ 編集の影響：

lib/ を編集 → UI/ロジックが変わる → ローカル開発サーバで hot-reload または flutter build web → コンテナに反映するには再ビルド/再デプロイが必要。

web/index.html を編集 → HTML の <head> や meta を変えられる（タイトルやタグ、外部スクリプトの挿入等）。

pubspec.yaml を更新 → 依存を追加したら flutter pub get 実行後、再ビルドが必要。

nginx/

default.conf, dev.conf, prod.conf

nginx の設定ファイル。リバースプロキシ設定（どのパスを backend に飛ばすか）、静的ファイルのルート、キャッシュ設定など。

dev.conf はローカル開発向け、prod.conf は本番向けの想定。

Dockerfile

nginx イメージのカスタム化（設定ファイルをコピーしたり、証明書を入れたり）。

→ 編集の影響：nginx 設定を変えたら nginx コンテナを再起動（または再ビルド）して設定を反映する必要があります。

ルートの docker-compose.yml

サービス群（frontend, backend, nginx, db）を定義。ポートや環境変数、ボリューム、依存関係を書いているファイル。

注意：スクショで出ていたけど version: 行は最新の docker compose では不要という警告が出ます。削除しても動作します。

3. Docker — よく使うコマンド

前提：プロジェクトルート（docker-compose.yml がある場所）で実行してください。Windows PowerShell の例を示します。

全部起動（ビルドも含む）
```powershell
docker compose up -d --build
```

一つだけ再起動（コードを直したとき等）

変更しただけでイメージを再ビルドしたい場合（ソースを Docker イメージに取り込む構成のとき）：
```powershell
docker compose up -d --build backend
```

ただ単にサービスを再起動（イメージ再ビルドは不要）したいとき：
```powershell
docker compose restart backend
```

（backend の代わりに frontend / nginx / db を指定してください）

停止（コンテナを停止する）
```powershell
# 停止する（コンテナは残る）
docker compose stop

# 停止してコンテナ／ネットワークを削除する（クリーン）
docker compose down
```

補助コマンド

```powershell
# コンテナ一覧（起動中）
docker ps

# 任意サービスのログを追う
docker logs -f <コンテナ名またはID>
# 例
docker logs -f stellar_backend

# コンテナの再ビルド（個別）
docker compose build <service>
```
