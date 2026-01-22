@echo off
REM Windows用 - Flutterローカル実行スクリプト

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║         Stellar Delivery - ローカル実行スクリプト          ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM プロジェクトディレクトリに移動
cd /d "%~dp0"

REM 依存パッケージのインストール
echo [1/3] 依存パッケージをインストール中...
call flutter pub get
if errorlevel 1 goto error

REM 古いビルドをクリーンアップ（オプション）
if "%1"=="--clean" (
    echo [2/3] 古いビルドをクリーンアップ中...
    call flutter clean
    call flutter pub get
)

REM アプリを起動
echo [3/3] Flutterアプリを起動中...
echo.
echo ブラウザが自動で開きます。開かない場合は以下のURLをアクセスしてください：
echo   http://localhost:8080
echo.
echo テストアカウント：
echo   依頼者: requester@example.com / password123
echo   配達員: deliverer@example.com / password123
echo   店舗:   store@example.com / password123
echo.

call flutter run -d chrome --web-port=8080

goto end

:error
echo.
echo エラーが発生しました。以下のコマンドを実行してください：
echo   flutter clean
echo   flutter pub get
echo   flutter run -d chrome
echo.
pause
exit /b 1

:end
echo.
echo スクリプトを終了します。
pause
