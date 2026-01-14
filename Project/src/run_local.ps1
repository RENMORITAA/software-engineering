#!/usr/bin/env pwsh

# PowerShell用 - Flutterローカル実行スクリプト

Write-Host "`n" -ForegroundColor White
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "║         Stellar Delivery - ローカル実行スクリプト          ║" -ForegroundColor Cyan
Write-Host "║                                                            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# スクリプトのディレクトリに移動
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# 依存パッケージのインストール
Write-Host "[1/3] 依存パッケージをインストール中..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "エラーが発生しました。以下のコマンドを実行してください：" -ForegroundColor Red
    Write-Host "  flutter clean" -ForegroundColor Red
    Write-Host "  flutter pub get" -ForegroundColor Red
    Write-Host "  flutter run -d chrome" -ForegroundColor Red
    exit 1
}

# 古いビルドをクリーンアップ（オプション）
if ($args -contains "--clean") {
    Write-Host "[2/3] 古いビルドをクリーンアップ中..." -ForegroundColor Yellow
    flutter clean
    flutter pub get
}

# アプリを起動
Write-Host "[3/3] Flutterアプリを起動中..." -ForegroundColor Yellow
Write-Host ""
Write-Host "ブラウザが自動で開きます。開かない場合は以下のURLをアクセスしてください：" -ForegroundColor Green
Write-Host "  http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "テストアカウント：" -ForegroundColor Green
Write-Host "  依頼者: requester@example.com / password123" -ForegroundColor White
Write-Host "  配達員: deliverer@example.com / password123" -ForegroundColor White
Write-Host "  店舗:   store@example.com / password123" -ForegroundColor White
Write-Host ""

flutter run -d chrome --web-port=8080

Write-Host "`nスクリプトを終了します。" -ForegroundColor Yellow
