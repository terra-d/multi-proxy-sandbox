#!/bin/bash

# K6負荷テスト実行スクリプト
# 事前にDockerコンテナを起動してから実行してください: docker compose up -d

echo "=== K6負荷テスト開始 ==="
echo "テスト設定: VU=2, 実行時間=2分, RPS=10"
echo ""

# Dockerコンテナの状態確認
echo "1. Dockerコンテナの状態確認..."
docker compose ps
echo ""

# テスト結果保存ディレクトリ作成
mkdir -p results
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "2. ダウンロードテスト実行中..."
echo "   2-1. nginx1経由でのダウンロードテスト"
k6 run --out json=results/download_nginx1_${TIMESTAMP}.json k6-tests/download-nginx1.js

echo "   2-2. nginx2直接でのダウンロードテスト"
k6 run --out json=results/download_nginx2_${TIMESTAMP}.json k6-tests/download-nginx2.js

echo ""
echo "3. アップロードテスト実行中..."
echo "   3-1. nginx1経由でのアップロードテスト"
k6 run --out json=results/upload_nginx1_${TIMESTAMP}.json k6-tests/upload-nginx1.js

echo "   3-2. nginx2直接でのアップロードテスト"
k6 run --out json=results/upload_nginx2_${TIMESTAMP}.json k6-tests/upload-nginx2.js

echo ""
echo "=== K6負荷テスト完了 ==="
echo "結果ファイルはresults/ディレクトリに保存されました"
echo "タイムスタンプ: ${TIMESTAMP}"

# 簡単な結果比較を表示
echo ""
echo "=== テスト結果サマリー ==="
echo "詳細な結果は各JSONファイルを参照してください"