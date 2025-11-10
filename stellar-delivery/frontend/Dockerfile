# Flutterビルド用
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

WORKDIR /app
COPY . .
RUN flutter build web

# 配信用Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
