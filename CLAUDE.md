# Multi-Proxy Sandbox プロジェクト

## 概要
このプロジェクトは、Nginxを2つのコンテナで接続した際の通信の挙動を検証するためのサンドボックス環境です。
プロキシサーバー間の通信パターン、負荷分散、フェイルオーバーなどの動作を検証することを目的としています。

## プロジェクト構造
```
multi-proxy-sandbox/
├── docker/              # Dockerコンテナ設定
│   ├── nginx1/         # 1つ目のNginxコンテナ設定
│   └── nginx2/         # 2つ目のNginxコンテナ設定
├── compose.yml          # Docker Compose設定
├── configs/            # Nginx設定ファイル
├── logs/               # ログファイル
├── scripts/            # 検証用スクリプト
└── docs/               # ドキュメント
```

## 検証項目
- Nginx間のリバースプロキシ動作
- ロードバランシングの挙動
- ヘッダーの伝播と変更
- タイムアウト設定の影響
- SSL/TLS終端の動作
- キャッシュの挙動

## 開発ガイドライン

### 環境構築
```bash
# Dockerコンテナの起動
docker compose up -d

# コンテナの停止
docker compose down

# ログの確認
docker compose logs -f
```

### Nginx設定の変更
1. `configs/`ディレクトリ内の設定ファイルを編集
2. コンテナを再起動: `docker compose restart`
3. 動作確認とログの検証

### 検証手順
```bash
# 通信テスト
curl -v http://localhost:8080

# ヘッダーの確認
curl -I http://localhost:8080

# 負荷テスト
ab -n 1000 -c 10 http://localhost:8080/
```

## よく使うコマンド
- `docker ps` - 実行中のコンテナを確認
- `docker compose logs nginx1` - nginx1のログを確認
- `docker compose exec nginx1 nginx -t` - nginx1の設定をテスト
- `docker compose exec nginx1 nginx -s reload` - nginx1の設定をリロード