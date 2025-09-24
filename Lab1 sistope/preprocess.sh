#!/bin/bash
# Agrega timestamp ISO 8601 por línea si viene con --iso8601S
# Se asegura de que la salida se vea en pantalla inmediatamente
# Input: salida de generator.sh desde stdin
# Output: misma línea con un timestamp ISO 8601 al inicio

# Mensaje de inicio de proceso
echo "Starting preprocess..." >&2

ADD_TIMESTAMP=false

# Validar argumentos
if [[ $# -gt 1 ]]; then
  echo "Uso: $0 [--iso8601]" >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then
  if [[ "$1" == "--iso8601" ]]; then
    ADD_TIMESTAMP=true
  else
    echo "Error: opción no reconocida '$1'" >&2
    echo "Uso: $0 --iso8601" >&2
    exit 1
  fi
fi
# Lee línea por línea obviando la interpretación de backslash (parámetro -r)
while read -r line; do 
  # Si la línea está vacía, salta a la siguiente
  [[ -z "$line" ]] && continue
  
  # Verifica que tenga 5 columnas (pid uid comm pcpu pmem)
  NF=$(echo "$line" | awk '{print NF}')
  if [[ $NF -ge 5 ]]; then
    if $ADD_TIMESTAMP; then
      TS=$(date -Iseconds)
      echo "$TS $line"
    else
      echo "$line"
    fi
  fi
done
