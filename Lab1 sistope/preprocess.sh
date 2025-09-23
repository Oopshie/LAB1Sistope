#!/bin/bash
# Agrega timestamp ISO 8601 por línea
# Se asegura de que la salida se vea en pantalla inmediatamente
# Input: salida de generator.sh desde stdin
# Output: misma línea con un timestamp ISO 8601 al inicio

# Mensaje de inicio de proceso
echo "Starting preprocess..." >&2

# Lee línea por línea obviando la interpretación de backslash (parámetro -r)
while read -r line; do 
  # Si la línea está vacía, salta a la siguiente
  [[ -z "$line" ]] && continue
  
  # Verifica que tenga 5 columnas (pid uid comm pcpu pmem)
  NF=$(echo "$line" | awk '{print NF}')  # awk '{print NF}' devuelve el número de columnas contadas
  if [[ $NF -eq 5 ]]; then
    TS=$(date -Iseconds)             # Obtiene timestamp por línea
    echo "$TS $line"  # Imprime el timestamp junto a la línea original
  fi
done
