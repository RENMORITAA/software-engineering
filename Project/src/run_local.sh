#!/bin/bash

# Linux/Mac用 - Flutterローカル実行スクリプト

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║         Stellar Delivery - ローカル実行スクリプト          ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# スクリプトのディレクトリに移動
cd "$(dirname "$0")"

# 依存パッケージのインストール
echo "[1/3] 依存パッケージをインストール中..."
flutter pub get
if [ $? -ne 0 ]; then
    echo ""
    echo "エラーが発生しました。以下のコマンドを実行してください："
    echo "  flutter clean"
    echo "  flutter pub get"
    echo "  flutter run -d chrome"
    exit 1
fi

# 古いビルドをクリーンアップ（オプション）
if [ "$1" == "--clean" ]; then
    echo "[2/3] 古いビルドをクリーンアップ中..."
    flutter clean
    flutter pub get
fi

# アプリを起動
echo "[3/3] Flutterアプリを起動中..."
echo ""
echo "ブラウザが自動で開きます。開かない場合は以下のURLをアクセスしてください："
echo "  http://localhost:8080"
echo ""
echo "テストアカウント："
echo "  依頼者: requester@example.com / password123"
echo "  配達員: deliverer@example.com / password123"
echo "  店舗:   store@example.com / password123"
echo ""

flutter run -d chrome --web-port=8080

echo ""
echo "スクリプトを終了します。"
