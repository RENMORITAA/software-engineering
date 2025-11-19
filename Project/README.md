# Flutter開発環境(Dev Containers)

このプロジェクトは、DockerとVSCodeのDev Containersを使用したFlutter開発環境です。Mac/Windows両方で同じ環境で開発でき、**Webアプリとして実行することでiPhone/Android両方で確認できます**。

## 事前準備

### 1. VSCodeとDev Containers拡張機能のインストール
- [Visual Studio Code](https://code.visualstudio.com/)をインストール
- [Dev Containers拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)をインストール

### 2. Dockerのインストール


#### Windows
[Docker Desktop](https://www.docker.com/products/docker-desktop/)をインストール

## クイックスタート(自動セットアップ)

プロジェクトルートで以下のコマンドを実行するだけで、すべて自動でセットアップされます:

```powershell
# 1. Dev Containers拡張機能をインストール済みであることを確認
# 2. コンテナをビルド・起動
cd .devcontainer
docker-compose up -d --build
cd ..

# 3. ワークスペース権限を修正してFlutterプロジェクトを作成
docker exec -it devcontainer-flutter-1 bash -c "sudo chown -R developer:developer /home/developer/workspace && cd /home/developer/workspace && flutter create sample_app"

# 4. Gradle設定を追加してWebアプリを起動
docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && echo 'org.gradle.unsafe.watch-fs=false' >> android/gradle.properties && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080"
```

これでブラウザから `http://localhost:8080` にアクセスすると、Flutterアプリが表示されます!

## 詳細なセットアップ手順

### 1. コンテナのビルド

#### 方法A: VSCodeから(推奨)
1. VSCodeでこのプロジェクトを開く
2. コマンドパレットを開く
   - Mac: `Shift + Command + P`
   - Windows: `Shift + Ctrl + P`
3. `>Dev Containers: Reopen in Container` を選択
4. コンテナのビルドが開始されます(初回は10-15分程度)

#### 方法B: コマンドラインから
```powershell
cd .devcontainer
docker-compose up -d --build
cd ..
```

### 2. Flutter環境の確認

```powershell
docker exec -it devcontainer-flutter-1 bash -c "flutter doctor"
```

以下の出力が表示されればOKです:
```
[✓] Flutter (Channel stable, 3.24.4, ...)
[✓] Android toolchain - develop for Android devices (Android SDK version 33.0.1)
[✓] Connected device (1 available)
[✓] Network resources
```

### 3. Flutterプロジェクトの作成

```powershell
docker exec -it devcontainer-flutter-1 bash -c "sudo chown -R developer:developer /home/developer/workspace && cd /home/developer/workspace && flutter create sample_app"
```

### 4. Webアプリとして起動

```powershell
docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && echo 'org.gradle.unsafe.watch-fs=false' >> android/gradle.properties && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080"
```

## デバイスでの確認方法

### PCのブラウザで確認
- VSCodeのSimple Browserまたは通常のブラウザで `http://localhost:8080` にアクセス

### iPhoneで確認
1. PCとiPhoneを同じWi-Fiネットワークに接続
2. PCのローカルIPアドレスを確認:
   ```powershell
   ipconfig
   # IPv4 Address を確認 (例: 192.168.1.100)
   ```
3. iPhoneのSafariで `http://[PCのIPアドレス]:8080` にアクセス
   - 例: `http://192.168.1.100:8080`


### Hot Reload
- `lib/main.dart` などのコードを編集
- ターミナルで `r` キーを押下するとリアルタイムで変更が反映されます
- ブラウザをリロードすると最新の状態が表示されます

## 開発の進め方

- Flutterの開発は`lib`ディレクトリ以下の`.dart`ファイルを編集
- Hot Reloadを活用して変更を素早く確認
- コンテナ内の`/home/developer/workspace/sample_app`がプロジェクトディレクトリです

## トラブルシューティング

### コンテナが起動しない
```powershell
# 既存のコンテナを削除して再ビルド
docker ps -a  # コンテナIDを確認
docker rm [コンテナID]
cd .devcontainer
docker-compose up -d --build
```

### アプリにアクセスできない
1. コンテナが起動しているか確認:
   ```powershell
   docker ps
   # devcontainer-flutter-1 が Running になっているか確認
   ```
2. ポートが正しくマッピングされているか確認:
   ```powershell
   docker port devcontainer-flutter-1
   # 8080/tcp -> 0.0.0.0:8080 が表示されるはず
   ```

### Flutterアプリが起動しない
```powershell
# コンテナ内でFlutterの状態を確認
docker exec -it devcontainer-flutter-1 bash -c "flutter doctor -v"

# プロジェクトが存在するか確認
docker exec -it devcontainer-flutter-1 bash -c "ls -la /home/developer/workspace/"
```

### スマホからアクセスできない
1. PCとスマホが同じWi-Fiに接続されているか確認
2. PCのファイアウォールで8080ポートが許可されているか確認
3. `http://` を忘れずに入力 (`https://` ではない)

## プロジェクト構造

```
.
├── .devcontainer/          # Dev Containers設定
│   ├── Dockerfile          # Flutter開発環境のDockerイメージ
│   ├── docker-compose.yml  # Dev Containers用の設定
│   └── devcontainer.json   # VSCode Dev Containers設定
├── backend/                # バックエンドAPI(Node.js)
├── db/                     # データベース初期化スクリプト
├── frontend/               # Flutter既存ファイル(参考用)
└── docker-compose.yml      # バックエンド・DB用(Dev Containersとは別)
```

## Android/iOSネイティブアプリとして実行する場合

### Androidエミュレータで実行
1. Android Studioをインストールしてエミュレータをセットアップ
2. エミュレータを起動
3. コンテナ内からadbで接続:
   ```powershell
   docker exec -it devcontainer-flutter-1 bash -c "adb connect host.docker.internal:5555"
   ```
4. Flutterアプリを実行:
   ```powershell
   docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && flutter run"
   ```

### iOSシミュレータで実行
- **macOSが必要です**(WindowsではiOSアプリのビルドができません)
- macOSで同じDev Container環境を使用し、Xcodeをインストールすればビルド可能です

### おすすめの開発フロー
1. **開発時**: Webアプリとして実行し、PC/iPhone/Androidのブラウザで確認
2. **最終確認**: Android StudioのエミュレータやiOSシミュレータで実機確認
3. **リリース**: ストア公開用にネイティブビルド

## 注意事項

- Dev ContainersのFlutter環境は`linux/x86_64`アーキテクチャで動作します
- Appleシリコン(M1/M2/M3)の場合、Rosettaが必要です
- iOSアプリのビルドにはmacOSとXcodeが必要です
- Webアプリとして実行すれば、Windows環境でもiPhone/Androidで確認できます
