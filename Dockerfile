# Stage 1: Build
FROM ubuntu:20.04 AS build-env

RUN apt-get update
RUN apt-get install -y bash curl file git unzip xz-utils zip libglu1-mesa
RUN apt-get clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set Flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web
RUN flutter pub global activate webdev

RUN mkdir /app/
COPY . /app/
WORKDIR /app/

RUN flutter pub get

RUN flutter build web --release




# Stage 2: Serve
FROM nginx:stable-alpine

# update OS packages to pick up security fixes
RUN apk update && apk upgrade --no-cache

COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]