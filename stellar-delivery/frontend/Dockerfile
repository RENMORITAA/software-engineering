# Minimal static site served by nginx
# Flutter build image
FROM ghcr.io/cirruslabs/flutter:3.19.0 AS build

# Set workdir and copy project files
WORKDIR /app
COPY . /app

# Get packages and build web release
RUN flutter pub get
RUN flutter build web --release

# Nginx stage to serve built assets
FROM nginx:alpine
# Copy the contents of build/web into nginx html root
COPY --from=build /app/build/web/. /usr/share/nginx/html/
EXPOSE 80
