#!/bin/bash
set -e

# pubspec.yamlがない場合、プロジェクトを初期化
if [ ! -f "pubspec.yaml" ]; then
    echo "pubspec.yaml not found. Initializing Flutter project..."
    
    # 既存のlibをバックアップ
    if [ -d "lib" ]; then
        echo "Backing up existing lib directory..."
        mv lib lib_backup
    fi

    # プロジェクト作成 (Webサポート有効)
    # --force は既存のファイルがあっても作成を続行するために使用（念のため）
    flutter create . --platforms web --org com.example

    # バックアップから復元
    if [ -d "lib_backup" ]; then
        echo "Restoring lib directory..."
        # flutter createで生成されたlib/main.dartなどを削除して、元のファイルを戻す
        rm -rf lib
        mv lib_backup lib
    fi
    
    # 必要なパッケージを追加
    echo "Adding dependencies..."
    flutter pub add http
fi

# 既存プロジェクトの場合でも http パッケージがない場合は追加
if [ -f "pubspec.yaml" ] && ! grep -q "http:" pubspec.yaml; then
    echo "Adding http dependency to existing project..."
    flutter pub add http
fi

# 依存関係の取得
flutter pub get

# 実行コマンドを組み立て（dart-defineを自動付与）
API_BASE_URL=${API_BASE_URL:-http://localhost:8000}
ENV=${ENV:-docker}
USE_MOCK_API=${USE_MOCK_API:-false}
WEB_PORT=${WEB_PORT:-8080}
WEB_HOSTNAME=${WEB_HOSTNAME:-0.0.0.0}

if [ "$1" = "flutter" ] && [ "$2" = "run" ]; then
        shift 2
        set -- flutter run \
            -d web-server \
            --web-port="${WEB_PORT}" \
            --web-hostname="${WEB_HOSTNAME}" \
            --dart-define="ENV=${ENV}" \
            --dart-define="API_BASE_URL=${API_BASE_URL}" \
            --dart-define="USE_MOCK_API=${USE_MOCK_API}" \
            "$@"
fi

exec "$@"
