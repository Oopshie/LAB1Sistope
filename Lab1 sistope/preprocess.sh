#!/bin/bash
# Description: Añade un timestamp en formato ISO 8601 al inicio de cada línea de entrada si se utiliza la opción --iso8601.
# Además asegura que la salida se vea en pantalla inmediatamente.
# Input: salida de generator.sh desde stdin.
# Output: misma línea con un timestamp ISO 8601 al inicio (si aplica).

# Mensaje de inicio de proceso
echo "Starting preprocess..." >&2

#Flag para indicar caso de timestamp
ADD_TIMESTAMP=false

# Validar argumentos: permite añadir un argumento extra (--iso8601)
if [[ $# -gt 1 ]]; then
  echo "Uso: $0 [--iso8601]" >&2
  exit 1
fi

if [[ $# -eq 1 ]]; then #Si se recibió un argumento extra
  if [[ "$1" == "--iso8601" ]]; then  # Equivalente a --iso8601
    ADD_TIMESTAMP=true #Flag cambia a true
  else
    echo "Error: opción no reconocida '$1'" >&2  # Caso contrario, el argumento no es válido y muestra error
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
    if $ADD_TIMESTAMP; then  #Si se solicitó timestamp...
      TS=$(date -Iseconds)  #Genera el Timestamp en formato ISO 8601 con segundos
      echo "$TS $line"  # Imprime el Timestamp al inicio de la línea original
    else
      echo "$line"  #Caso contrario, se imprime la línea original sin cambios
    fi
  fi
done
