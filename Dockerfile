# syntax=docker/dockerfile:1
# ---------------------------------------------------------------------------
# WAWUBasket — Flutter Web build, served by nginx (for Railway).
#
# Railway auto-detects this Dockerfile. It injects $PORT at runtime; nginx is
# templated to listen on it. API base URLs default to the production Railway
# services (see lib/core/network/api_config.dart); override at build time with
#   --build-arg API_BASE_URL=... --build-arg WAWU_ID_BASE_URL=...
# ---------------------------------------------------------------------------

# ---- Build stage ----------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Optional API overrides (empty → app falls back to its built-in prod URLs).
ARG API_BASE_URL=""
ARG WAWU_ID_BASE_URL=""

WORKDIR /app

# Resolve dependencies first so this layer caches across source-only changes.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Build the web bundle.
COPY . .
RUN flutter build web --release \
    --dart-define=API_BASE_URL="${API_BASE_URL}" \
    --dart-define=WAWU_ID_BASE_URL="${WAWU_ID_BASE_URL}"

# ---- Serve stage ----------------------------------------------------------
FROM nginx:alpine AS serve

# SPA config template — nginx substitutes ${PORT} from the environment on start.
COPY docker/nginx.conf.template /etc/nginx/templates/default.conf.template

# Static web bundle.
COPY --from=build /app/build/web /usr/share/nginx/html

# Railway provides $PORT; default for local runs.
ENV PORT=8080
EXPOSE 8080
