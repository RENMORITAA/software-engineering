FROM nginx:alpine
ARG MODE=dev
# copy both configs then pick one based on build-arg
COPY dev.conf /etc/nginx/conf.d/dev.conf
COPY prod.conf /etc/nginx/conf.d/prod.conf
RUN if [ "$MODE" = "prod" ]; then cp /etc/nginx/conf.d/prod.conf /etc/nginx/conf.d/default.conf; else cp /etc/nginx/conf.d/dev.conf /etc/nginx/conf.d/default.conf; fi
