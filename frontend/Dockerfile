FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .

ARG API_BASE_URL=http://localhost:8080/api
ARG GOOGLE_CLIENT_ID=883824205385-182f65ondho5qnima9ladd5j7qk2b40h.apps.googleusercontent.com
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL} --dart-define=GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}

FROM nginx:1.27-alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
