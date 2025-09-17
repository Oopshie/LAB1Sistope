#!/bin/bash
# Preprocesa datos de procesos desde stdin, agregando timestamp ISO 8601 por línea
# Se asegura de que la salida se vea en pantalla inmediatamente

echo "Starting preprocess..." >&2
while read -r line; do 
  # Salta líneas vacías
  [[ -z "$line" ]] && continue
  
  # Verifica que tenga 5 columnas (pid uid comm pcpu pmem)
  NF=$(echo "$line" | awk '{print NF}')
  if [[ $NF -eq 5 ]]; then
    TS=$(date -Iseconds)             # timestamp por línea
    echo "$TS $line"  # salida con timestamp
  fi
done