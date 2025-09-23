#!/bin/bash
# filter.sh - Filtra procesos según CPU, MEM y nombre de comando
# Input: salida de preprocess.sh (timestamp pid uid comm pcpu pmem) desde stdin
# Output: solo las líneas que cumplen con los filtros de CPU, MEM y REGEX

# Uso: ./filter.sh -c CPU_MIN -m MEM_MIN -r REGEX

# Valores por defecto
CPU_MIN=0  # % mínimo de CPU
MEM_MIN=0  # % mínimo de Memoria
REGEX=".*"  # Filtro nombre de comando

# Parseo de flags
# -c : CPU mínima
# -m : memoria mínima
# -r : expresión regular para el comando
while getopts "c:m:r:" opt; do
  case $opt in
    c) CPU_MIN=$OPTARG ;;  # Asigna cpu mínima
    m) MEM_MIN=$OPTARG ;;  # Asigna memoria mínima
    r) REGEX=$OPTARG ;;    # Asigna regex
    *) echo "Uso: $0 -c CPU_MIN -m MEM_MIN -r REGEX"; exit 1 ;;  # En caso de error de flags finaliza
  esac
done

# Leer stdin línea por línea
while read -r line; do
  [[ -z "$line" ]] && continue  # Ignora líneas vacías

  # Separar columnas: timestamp, pid, uid, comm, pcpu, pmem
  TS=$(echo "$line" | awk '{print $1}')
  PID=$(echo "$line" | awk '{print $2}')
  User_ID=$(echo "$line" | awk '{print $3}')
  COMM=$(echo "$line" | awk '{print $4}')
  PCPU=$(echo "$line" | awk '{print $5}')
  PMEM=$(echo "$line" | awk '{print $6}')

  # Verifica que pcpu y pmem sean valores numéricos válidos
  [[ ! $PCPU =~ ^[0-9.]+$ ]] && continue
  [[ ! $PMEM =~ ^[0-9.]+$ ]] && continue

  # Aplica filtros:
  # CPU mayor o igual al mínimo
  CPU_OK=$(awk -v c="$PCPU" -v min="$CPU_MIN" 'BEGIN{if(c>=min) print 1; else print 0}')
  # Memoria mayor o igual al mínimo
  MEM_OK=$(awk -v m="$PMEM" -v min="$MEM_MIN" 'BEGIN{if(m>=min) print 1; else print 0}')
  # Nombre de comando coincidente con el regex
  REGEX_OK=$(echo "$COMM" | grep -E -q "$REGEX" && echo 1 || echo 0)

# Si se cumplen todas las condiciones de los filtros, se imprime la línea completa
  if [[ $CPU_OK -eq 1 && $MEM_OK -eq 1 && $REGEX_OK -eq 1 ]]; then
    echo "$line"
  fi

done
