#!/usr/bin/env bash
#
# Sobe o servidor local e expõe por HTTPS (Cloudflare Quick Tunnel)
# para testar o WebAR no celular.
#
#   ./start.sh            # porta 8000
#   PORT=8080 ./start.sh  # outra porta
#
set -euo pipefail

cd "$(dirname "$0")"

PORT="${PORT:-8000}"
ARQUIVO="ombrelone.glb"

if ! command -v python3 >/dev/null 2>&1; then
  echo "✖ python3 não encontrado." >&2
  exit 1
fi

if [ ! -f "$ARQUIVO" ]; then
  echo "✖ $ARQUIVO não encontrado nesta pasta." >&2
  echo "  Gere com: npx --yes @gltf-transform/cli metalrough ombrelone_lateral_octo_tecido_tidelli_agave_casa.glb ombrelone.glb" >&2
  exit 1
fi

echo "▸ Servindo $(pwd) em http://localhost:$PORT"
python3 -m http.server "$PORT" --bind 127.0.0.1 >/tmp/mvp-ar-http.log 2>&1 &
SERVIDOR=$!

limpar() {
  echo
  echo "▸ Encerrando servidor local (pid $SERVIDOR)…"
  kill "$SERVIDOR" 2>/dev/null || true
}
trap limpar EXIT INT TERM

# Espera o servidor responder antes de abrir o túnel.
for _ in $(seq 1 25); do
  if curl -sf -o /dev/null "http://localhost:$PORT/"; then break; fi
  sleep 0.2
done

echo "▸ Criando túnel HTTPS (o download do cloudflared pode demorar na 1ª vez)…"
echo

npx --yes cloudflared@latest tunnel --no-autoupdate --url "http://localhost:$PORT"
