# Multi-Proxy Sandbox

2つのNginxコンテナ間の通信動作をテスト・分析するためのサンドボックス環境です。

## 概要

このプロジェクトは、以下のようなプロキシ通信パターンを検証するためのDockerベースの環境を提供します：
- リバースプロキシ設定
- ロードバランシング戦略
- ヘッダーの伝播と変更
- タイムアウト動作
- SSL/TLS終端
- キャッシュメカニズム

## 前提条件

- Docker Engine 20.10以上
- Docker Compose v2.0以上
- curl（テスト用）
- Apache Bench (ab) 負荷テスト用（オプション）

## クイックスタート

1. リポジトリをクローン：
```bash
git clone https://github.com/yourusername/multi-proxy-sandbox.git
cd multi-proxy-sandbox
```

2. コンテナを起動：
```bash
docker compose up -d
```

3. セットアップを確認：
```bash
curl http://localhost:8080
```

4. ログを表示：
```bash
docker compose logs -f
```

## プロジェクト構造

```
multi-proxy-sandbox/
├── docker/              # Dockerコンテナ設定
│   ├── nginx1/         # 1つ目のNginxコンテナ設定
│   └── nginx2/         # 2つ目のNginxコンテナ設定
├── compose.yml         # Docker Compose設定
├── configs/            # Nginx設定ファイル
├── logs/               # ログファイル
├── scripts/            # テスト・ユーティリティスクリプト
├── docs/               # 追加ドキュメント
└── README.md           # このファイル
```

## 設定

### Nginx設定

Nginx設定は`configs/`ディレクトリに保存されています。変更方法：

1. `configs/`内の設定ファイルを編集
2. コンテナを再起動： `docker compose restart`
3. 設定を検証： `docker compose exec nginx1 nginx -t`

### ネットワークアーキテクチャ

```
[クライアント] --> [Nginx1:8080] --> [Nginx2:8081] --> [バックエンドサービス]
```

## テスト

### 基本的な接続テスト
```bash
curl -v http://localhost:8080
```

### ヘッダー検査
```bash
curl -I http://localhost:8080
```

### 負荷テスト
```bash
ab -n 1000 -c 10 http://localhost:8080/
```

### カスタムテストスクリプト
```bash
./scripts/test-headers.sh
./scripts/test-load-balancing.sh
```

## よく使うコマンド

- コンテナ起動： `docker compose up -d`
- コンテナ停止： `docker compose down`
- コンテナ再起動： `docker compose restart`
- ログ表示： `docker compose logs -f [サービス名]`
- コンテナ内でコマンド実行： `docker compose exec nginx1 [コマンド]`
- Nginx設定チェック： `docker compose exec nginx1 nginx -t`
- Nginx設定リロード： `docker compose exec nginx1 nginx -s reload`

## トラブルシューティング

### コンテナが起動しない場合
- ポート8080と8081が利用可能か確認
- Dockerデーモンが実行中か確認
- ログを確認： `docker compose logs nginx1`

### 設定エラー
- Nginx構文を検証： `docker compose exec nginx1 nginx -t`
- 設定ファイルの権限を確認
- `logs/`ディレクトリのエラーログを確認

## コントリビューション

1. リポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## ライセンス

このプロジェクトはMITライセンスの下でライセンスされています。詳細はLICENSEファイルを参照してください。

## 謝辞

- Nginxドキュメントとコミュニティ
- DockerおよびDocker Composeチーム