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
# 1. バックエンドAPI + MySQLデータベースを起動
docker-compose up -d --build

# 2. Flutterコンテナをビルド・起動
cd .devcontainer
docker-compose up -d --build
cd ..

# 3. ワークスペース権限を修正してFlutterプロジェクトを作成
docker exec -it devcontainer-flutter-1 bash -c "sudo chown -R developer:developer /home/developer/workspace && cd /home/developer/workspace && flutter create sample_app"

# 4. httpパッケージを追加
docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && flutter pub add http"

# 5. Gradle設定を追加してWebアプリを起動
docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && echo 'org.gradle.unsafe.watch-fs=false' >> android/gradle.properties && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080"
```

これでブラウザから `http://localhost:8080` にアクセスすると、Flutterアプリが表示されます!

### よく使うコマンド

```powershell
# すべてのコンテナの状態を確認
docker ps

# バックエンドAPIのログを確認
docker logs api_server

# Flutterアプリを再起動
docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080"

# MySQLに接続
docker exec -it mysql_db mysql -u app -papppass appdb

# APIの動作確認
Invoke-WebRequest -Uri http://localhost:8001/users -UseBasicParsing | Select-Object -ExpandProperty Content

# すべてのコンテナを停止
docker-compose down
cd .devcontainer
docker-compose down
cd ..

# すべてのコンテナを再起動
docker-compose restart
cd .devcontainer
docker-compose restart
cd ..
```

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

## データベース連携

このプロジェクトには既にバックエンドAPI(Node.js + Express)とMySQL DBが設定されています。

### 1. バックエンドとDBを起動

```powershell
# プロジェクトルートで実行
docker-compose up -d
```

これで以下が起動します:
- **バックエンドAPI**: `http://localhost:8001`
- **MySQL DB**: `localhost:3307` (内部では3306)

### 2. APIの動作確認

ブラウザまたはコマンドで確認:
```powershell
# APIのヘルスチェック
curl http://localhost:8001

# ユーザー一覧を取得(DBから)
curl http://localhost:8001/users
```

### 3. FlutterアプリからAPIを呼び出す

#### pubspec.yamlにhttpパッケージを追加

コンテナ内で実行:
```powershell
docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && flutter pub add http"
```

#### lib/main.dartを編集してAPI呼び出し

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter DB Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> users = [];
  bool isLoading = false;

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ホストマシンのAPIにアクセス
      final response = await http.get(
        Uri.parse('http://host.docker.internal:8001/users'),
      );

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'データベースのユーザー一覧:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (users.isEmpty)
              const Text('ボタンを押してデータを取得')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${users[index]['id']}'),
                      ),
                      title: Text(users[index]['name']),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUsers,
        tooltip: 'Fetch Users',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### 4. アプリを再起動

```powershell
# Flutterアプリを再起動(既存のプロセスを停止してから)
docker exec -it devcontainer-flutter-1 bash -c "cd /home/developer/workspace/sample_app && flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080"
```

### 5. 動作確認

1. ブラウザで `http://localhost:8080` にアクセス
2. 右下の更新ボタン(🔄)をタップ
3. データベースから取得したユーザー一覧(Taro, Hanako)が表示されます!

### データベースの操作

#### MySQLに直接接続

```powershell
# MySQLコンテナに接続
docker exec -it mysql_db mysql -u app -papppass appdb

# SQL実行例
SELECT * FROM users;
INSERT INTO users (name) VALUES ('Jiro');
EXIT;
```

#### 新しいAPIエンドポイントを追加

`backend/src/index.js`を編集:
```javascript
// ユーザーを追加
app.post("/users", async (req, res) => {
  const { name } = req.body;
  const [result] = await pool.query("INSERT INTO users (name) VALUES (?)", [name]);
  res.json({ id: result.insertId, name });
});
```

バックエンドを再起動:
```powershell
docker-compose restart backend
```

## 開発の進め方

- Flutterの開発は`lib`ディレクトリ以下の`.dart`ファイルを編集
- Hot Reloadを活用して変更を素早く確認
- コンテナ内の`/home/developer/workspace/sample_app`がプロジェクトディレクトリです
- バックエンドAPIを通じてデータベースと連携できます

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
