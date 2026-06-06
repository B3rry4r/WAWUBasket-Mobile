# Deploying WAWUBasket Web to Railway

The web build is containerised: a multi-stage `Dockerfile` builds the Flutter
web bundle and serves it with nginx. Railway auto-detects the `Dockerfile`
(`railway.json` also pins the Dockerfile builder explicitly).

## Steps
1. Create a new Railway service from this repo (root directory = repo root).
2. Railway builds the `Dockerfile` and runs it. nginx listens on Railway's
   injected `$PORT` (templated in `docker/nginx.conf.template`), and the SPA
   fallback makes deep links / refreshes work.
3. (Optional) Override the API hosts at build time with Railway build args:
   - `API_BASE_URL` — the WAWUBasket API origin (no trailing `/v1`).
   - `WAWU_ID_BASE_URL` — the WAWU ID service origin.
   If unset, the app uses its built-in production defaults
   (see `lib/core/network/api_config.dart`).

## Local test
```bash
docker build -t wawubasket-web .
docker run -p 8080:8080 -e PORT=8080 wawubasket-web
# open http://localhost:8080
```
