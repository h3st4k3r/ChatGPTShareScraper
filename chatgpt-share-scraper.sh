#!/bin/bash

BASE_URL="https://chatgpt.com/share"
USER_AGENT="Mozilla/5.0 (h3st4k3r Scanner)"
TIMEOUT=10

read -p "¿Cuántos UUIDs quieres generar y probar? " TRIES
echo
echo "[*] Empezando escaneo de UUIDs contra Shared Links de ChatGPT..."
echo "[*] URL base: $BASE_URL"
echo "[*] Intentos: $TRIES"
echo

generate_id() {
  uuidgen | tr '[:upper:]' '[:lower:]'
}

for i in $(seq 1 "$TRIES"); do
  ID=$(generate_id)
  FULL_URL="$BASE_URL/$ID"

  # Usamos dos archivos temporales: uno para el contenido, otro para el código HTTP
  BODY_FILE=$(mktemp)
  CODE=$(curl -s -m $TIMEOUT -A "$USER_AGENT" -o "$BODY_FILE" -w "%{http_code}" "$FULL_URL")

  # Extraemos el título del HTML
  TITLE=$(sed -n 's:.*<title>\(.*\)</title>.*:\1:p' "$BODY_FILE")
  rm "$BODY_FILE"

  if [[ "$CODE" == "404" || "$TITLE" == "Not accessible" || -z "$TITLE" ]]; then
    echo "[$i] [-] Invalid: $ID => HTTP $CODE | Title: $TITLE"
  else
    echo "[$i] [+] POSIBLE VÁLIDO: $ID => HTTP $CODE | Title: $TITLE"
  fi
done
