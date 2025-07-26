@echo off
chcp 65001 >nul

REM K6負荷テスト実行スクリプト（Windows用）
REM 事前にDockerコンテナを起動してから実行してください: docker compose up -d

REM バッチファイルのディレクトリを取得
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%~dp0.."

REM プロジェクトルートに移動
cd /d "%PROJECT_ROOT%"

echo ===== K6負荷テスト開始 =====
echo テスト設定: VU=2, 実行時間=2分, RPS=10
echo スクリプトディレクトリ: %SCRIPT_DIR%
echo プロジェクトルート: %PROJECT_ROOT%
echo 現在のディレクトリ: %CD%
echo.

REM Dockerコンテナの状態確認
echo 1. Dockerコンテナの状態確認...
docker compose ps
echo.

REM テスト結果保存ディレクトリ作成
if not exist "%SCRIPT_DIR%results" mkdir "%SCRIPT_DIR%results"


REM タイムスタンプ生成
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
    set "datestr=%%c%%a%%b"
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set "timestr=%%a%%b"
)
set "timestr=%timestr: =0%"
set "TIMESTAMP=%datestr%_%timestr%"

echo 2. ダウンロードテスト実行中...
echo    2-1. nginx1経由でのダウンロードテスト
k6 run --out json="%SCRIPT_DIR%results\download_nginx1_%TIMESTAMP%.json" "%SCRIPT_DIR%download-nginx1.js"

echo    2-2. nginx2直接でのダウンロードテスト
k6 run --out json="%SCRIPT_DIR%results\download_nginx2_%TIMESTAMP%.json" "%SCRIPT_DIR%download-nginx2.js"

echo.
echo 3. アップロードテスト実行中...
echo    3-1. nginx1経由でのアップロードテスト
k6 run --out json="%SCRIPT_DIR%results\upload_nginx1_%TIMESTAMP%.json" "%SCRIPT_DIR%upload-nginx1.js"

echo    3-2. nginx2直接でのアップロードテスト
k6 run --out json="%SCRIPT_DIR%results\upload_nginx2_%TIMESTAMP%.json" "%SCRIPT_DIR%upload-nginx2.js"

echo.
echo ===== K6負荷テスト完了 =====
echo 結果ファイルは%SCRIPT_DIR%results\ディレクトリに保存されました
echo タイムスタンプ: %TIMESTAMP%

REM 簡単な結果比較を表示
echo.
echo ===== テスト結果サマリー =====
echo 詳細な結果は各JSONファイルを参照してください

pause