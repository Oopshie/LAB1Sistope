#!/bin/bash
# filter.sh - Filtra procesos según CPU, MEM y nombre de comando
# Uso: ./filter.sh -c CPU_MIN -m MEM_MIN -r REGEX

# Valores por defecto
CPU_MIN=0
MEM_MIN=0
REGEX=".*"

# Parseo de flags
while getopts "c:m:r:" opt; do
  case $opt in
    c) CPU_MIN=$OPTARG ;;
    m) MEM_MIN=$OPTARG ;;
    r) REGEX=$OPTARG ;;
    *) echo "Uso: $0 -c CPU_MIN -m MEM_MIN -r REGEX"; exit 1 ;;
  esac
done

# Leer stdin línea por línea
while read -r line; do
  [[ -z "$line" ]] && continue

  # Separar columnas: timestamp pid uid comm pcpu pmem
  TS=$(echo "$line" | awk '{print $1}')
  PID=$(echo "$line" | awk '{print $2}')
  User_ID=$(echo "$line" | awk '{print $3}')
  COMM=$(echo "$line" | awk '{print $4}')
  PCPU=$(echo "$line" | awk '{print $5}')
  PMEM=$(echo "$line" | awk '{print $6}')

  # Verifica que pcpu y pmem sean números válidos
  [[ ! $PCPU =~ ^[0-9.]+$ ]] && continue
  [[ ! $PMEM =~ ^[0-9.]+$ ]] && continue

  # Aplica filtros
  CPU_OK=$(awk -v c="$PCPU" -v min="$CPU_MIN" 'BEGIN{if(c>=min) print 1; else print 0}')
  MEM_OK=$(awk -v m="$PMEM" -v min="$MEM_MIN" 'BEGIN{if(m>=min) print 1; else print 0}')
  REGEX_OK=$(echo "$COMM" | grep -E -q "$REGEX" && echo 1 || echo 0)

  if [[ $CPU_OK -eq 1 && $MEM_OK -eq 1 && $REGEX_OK -eq 1 ]]; then
    echo "$line"
  fi

done
