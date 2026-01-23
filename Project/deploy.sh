#!/bin/bash
# ============================================
# AWS EC2 デプロイスクリプト
# ============================================

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  AWS EC2 デプロイを開始します${NC}"
echo -e "${GREEN}========================================${NC}"

# 環境変数ファイルの確認
if [ ! -f .env ]; then
    echo -e "${YELLOW}警告: .env ファイルが見つかりません${NC}"
    echo -e "${YELLOW}.env.example をコピーして設定してください${NC}"
    
    read -p ".env.example から .env を作成しますか? (y/n): " create_env
    if [ "$create_env" = "y" ]; then
        cp .env.example .env
        echo -e "${GREEN}.env ファイルを作成しました。必要に応じて編集してください。${NC}"
    else
        echo -e "${RED}デプロイを中止します${NC}"
        exit 1
    fi
fi

# .envファイルを読み込み
source .env 2>/dev/null || true

# EC2のパブリックIPを取得（IMDSv2対応）
echo -e "${YELLOW}EC2のパブリックIPを取得中...${NC}"
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null) || true
if [ -n "$TOKEN" ]; then
    EC2_PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null) || true
fi

if [ -n "$EC2_PUBLIC_IP" ]; then
    echo -e "${GREEN}EC2パブリックIP: ${EC2_PUBLIC_IP}${NC}"
    
    # API_BASE_URLを更新
    export API_BASE_URL="http://${EC2_PUBLIC_IP}:8000"
    echo -e "${GREEN}API_BASE_URL: ${API_BASE_URL}${NC}"
else
    echo -e "${YELLOW}EC2メタデータからIPを取得できませんでした${NC}"
    echo -e "${YELLOW}手動でAPI_BASE_URLを設定してください${NC}"
fi

# 古いコンテナを停止
echo -e "${YELLOW}既存のコンテナを停止中...${NC}"
docker-compose -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true

# 古いイメージを削除（オプション）
read -p "古いDockerイメージを削除しますか? (y/n): " remove_images
if [ "$remove_images" = "y" ]; then
    echo -e "${YELLOW}古いイメージを削除中...${NC}"
    docker image prune -f
fi

# 本番用イメージをビルド
echo -e "${YELLOW}本番用Dockerイメージをビルド中...${NC}"
docker-compose -f docker-compose.prod.yml build --no-cache

# コンテナを起動
echo -e "${YELLOW}コンテナを起動中...${NC}"
docker-compose -f docker-compose.prod.yml up -d

# 起動確認
echo -e "${YELLOW}コンテナの起動を確認中...${NC}"
sleep 5

docker-compose -f docker-compose.prod.yml ps

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  デプロイが完了しました！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
if [ -n "$EC2_PUBLIC_IP" ]; then
    echo -e "アプリケーション: ${GREEN}http://${EC2_PUBLIC_IP}${NC}"
    echo -e "API ドキュメント: ${GREEN}http://${EC2_PUBLIC_IP}:8000/docs${NC}"
else
    echo -e "アプリケーション: ${GREEN}http://YOUR_EC2_PUBLIC_IP${NC}"
    echo -e "API ドキュメント: ${GREEN}http://YOUR_EC2_PUBLIC_IP:8000/docs${NC}"
fi
echo ""
echo -e "${YELLOW}注意: EC2のセキュリティグループでポート80, 8000が開放されていることを確認してください${NC}"
