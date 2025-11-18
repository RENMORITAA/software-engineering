FROM ghcr.io/cirruslabs/flutter:latest

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa && \
    apt-get clean

WORKDIR /app
