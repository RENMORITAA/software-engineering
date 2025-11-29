# 開発環境のセットアップと実行手順

このプロジェクトは Docker を使用して開発環境を構築しています。

## 1. 前提条件
*   Docker Desktop がインストールされ、起動していること。

## 2. 環境の起動 (初回・通常時)
プロジェクトのルートディレクトリで以下のコマンドを実行し、すべてのコンテナを起動します。

```powershell
docker-compose up -d
```
※ 初回はイメージのビルドや依存関係の取得が行われるため、時間がかかります。

起動が完了すると、以下のURLでアプリにアクセスできます。
*   **Flutter Web アプリ**: [http://localhost:8080](http://localhost:8080)
*   **API サーバー**: [http://localhost:3000](http://localhost:3000)

## 3. コンテナの状態確認
コンテナが正しく動いているか確認するには、以下のコマンドを使用します。

```powershell
docker ps
```

## 4. 特定のコンテナの再起動
もし `flutter` コンテナなどが停止してしまった場合や、個別に再開したい場合は以下のコマンドを実行します。

```powershell
docker-compose start flutter
```

## 5. ログの確認
起動しない場合やエラーを確認したい場合は、ログを表示します。

```powershell
# Flutterコンテナのログを見る
docker-compose logs -f flutter
```

## 6. 環境の停止
開発を終了し、コンテナを削除する場合は以下のコマンドを実行します。

```powershell
docker-compose down
```
