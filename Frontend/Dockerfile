FROM ghcr.io/cirruslabs/flutter:3.35.2 AS build

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build web

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80





COPY nginx.conf /etc/nginx/conf.d/default.conf   
