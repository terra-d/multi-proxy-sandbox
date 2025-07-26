@echo off
chcp 65001 >nul

echo ===== K6負荷テスト開始 =====
echo.

echo 現在のディレクトリを確認中...
echo %CD%
echo.

echo K6テストファイル確認中...
dir k6-tests\*.js
echo.

echo 1. ダウンロードテスト（nginx1経由）
k6 run k6-tests\download-nginx1.js

echo.
echo 2. ダウンロードテスト（nginx2直接）
k6 run k6-tests\download-nginx2.js

echo.
echo 3. アップロードテスト（nginx1経由）
k6 run k6-tests\upload-nginx1.js

echo.
echo 4. アップロードテスト（nginx2直接）
k6 run k6-tests\upload-nginx2.js

echo.
echo ===== テスト完了 =====
pause