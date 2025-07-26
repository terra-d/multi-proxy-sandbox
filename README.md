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

## システム構成図

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Docker Network                             │
│                         (proxy-network: 172.20.0.0/16)              │
│                                                                     │
│  ┌─────────────────────┐         ┌─────────────────────┐          │
│  │                     │         │                     │          │
│  │      Nginx1         │         │      Nginx2         │          │
│  │  (プロキシサーバー)   │ ──────▶ │ (バックエンドサーバー) │          │
│  │                     │         │                     │          │
│  │   Container Name:   │         │   Container Name:   │          │
│  │      nginx1         │         │      nginx2         │          │
│  │                     │         │                     │          │
│  │   Internal Port:    │         │   Internal Port:    │          │
│  │        80           │         │        80           │          │
│  │                     │         │                     │          │
│  └─────────────────────┘         └─────────────────────┘          │
│           ▲                                 ▲                       │
│           │                                 │                       │
└───────────┼─────────────────────────────────┼───────────────────────┘
            │                                 │
            │                                 │
     ┌──────┴──────┐                   ┌──────┴──────┐
     │   Host OS   │                   │   Host OS   │
     │  Port:8080  │                   │  Port:8081  │
     └──────┬──────┘                   └─────────────┘
            │
            │
     ┌──────┴──────┐
     │   Client    │
     │  (Browser)  │
     └─────────────┘

通信フロー:
1. クライアント → localhost:8080 (Nginx1)
2. Nginx1 → nginx2:80 (内部ネットワーク経由)
3. Nginx2 → レスポンスを返す
4. Nginx1 → クライアントへレスポンスを転送
```

## 前提条件

- Docker Engine 20.10以上
- Docker Compose v2.0以上
- curl（テスト用）
- K6（負荷テスト用）
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
├── configs/            # Nginx設定ファイル
│   ├── nginx1/        # nginx1（プロキシサーバー）設定
│   └── nginx2/        # nginx2（バックエンドサーバー）設定
├── html/              # 静的HTMLファイル
│   ├── nginx1/        # nginx1用HTML
│   └── nginx2/        # nginx2用HTML + テストファイル
├── k6-tests/          # K6負荷テストスクリプト
├── logs/              # ログファイル（自動生成）
├── compose.yml        # Docker Compose設定
└── README.md          # このファイル
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

### K6負荷テスト
事前にDockerコンテナを起動してから実行：
```bash
docker compose up -d
```

#### 一括テスト実行
**Linux/Mac:**
```bash
./k6-tests/run-tests.sh
```

**Windows (CMD):**
```cmd
k6-tests\run-tests.bat
```

#### 個別テスト実行
```bash
# ダウンロードテスト（nginx1経由）
k6 run k6-tests/download-nginx1.js

# ダウンロードテスト（nginx2直接）
k6 run k6-tests/download-nginx2.js

# アップロードテスト（nginx1経由）
k6 run k6-tests/upload-nginx1.js

# アップロードテスト（nginx2直接）
k6 run k6-tests/upload-nginx2.js
```

#### K6テスト設定
- **VU数**: 2（同時接続ユーザー）
- **実行時間**: 1分間
- **RPS**: 10（秒間リクエスト数）
- **ファイルサイズ**: 100KB固定
- **テスト結果**: `k6-tests/results/`に保存

### Apache Bench負荷テスト（オプション）
```bash
ab -n 1000 -c 10 http://localhost:8080/
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

このプロジェクトはMITライセンスの下でライセンスされています。