# --- ステージ1: ビルド用 (重い環境) ---
FROM ubuntu:22.04 AS build-env

RUN apt-get update && apt-get install -y curl git unzip python3 xz-utils zip libglu1-mesa

# rootでの実行警告を抑制
ENV FORCE_COLOR=1
ENV CHROME_EXECUTABLE=/usr/bin/chromium-browser

WORKDIR /app

# Flutter SDKのインストール
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# プロジェクトファイルをコピーしてビルド
COPY . .

# Flutterのディレクトリ (src) に移動してビルド実行
WORKDIR /app/src
RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web --release

# --- ステージ2: 配信用 (軽量なNginx) ---
FROM nginx:stable-alpine
# ビルド済みの静的ファイルだけをNginxに持っていく
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]