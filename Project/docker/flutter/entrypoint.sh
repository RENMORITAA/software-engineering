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

# コマンド実行
exec "$@"
