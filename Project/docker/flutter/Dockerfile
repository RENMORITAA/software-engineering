# ベースイメージ
FROM ubuntu:22.04

# 必要なツールをインストール
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDKのインストール
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH=${FLUTTER_HOME}/bin:${PATH}

# Flutterの安定版をダウンロード
RUN git clone https://github.com/flutter/flutter.git ${FLUTTER_HOME} -b stable

# 権限設定（開発時のトラブル防止）
RUN git config --global --add safe.directory ${FLUTTER_HOME}

# Web開発用の設定を有効化
RUN flutter config --enable-web

# 作業ディレクトリ設定
WORKDIR /app

# エントリーポイントスクリプトをコピー
COPY docker/flutter/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]