#!/bin/bash
# filter.sh filtra procesos según uso mínimo de CPU, MEM y expresión regular en el nombre del comando
# Input: salida de preprocess.sh (con o sin timestamp: pid uid comm pcpu pmem / ts pid uid comm pcpu pmem)
# Output: solo las líneas que cumplen con los filtros de CPU, MEM y REGEX

# Uso: ./filter.sh -c CPU_MIN -m MEM_MIN -r REGEX

echo "Starting filter..." >&2

# Valores por defecto
CPU_MIN=0   # % mínimo de CPU
MEM_MIN=0   # % mínimo de Memoria
REGEX=".*"  # Filtro nombre de comando

# Parseo de flags
# -c : CPU mínima
# -m : Memoria mínima
# -r : Expresión regular para el comando
while getopts "c:m:r:" opt; do
  case $opt in
    c) CPU_MIN=$OPTARG ;;  # Asigna CPU mínima
    m) MEM_MIN=$OPTARG ;;  # Asigna Memoria mínima
    r) REGEX=$OPTARG ;;    # Asigna regex
    *) echo "Uso: $0 -c CPU_MIN -m MEM_MIN -r REGEX" >&2; exit 1 ;;  # En caso de error, finaliza
  esac
done

# Reemplazar comas por puntos en los parámetros
CPU_MIN=$(echo "$CPU_MIN" | tr , .)
MEM_MIN=$(echo "$MEM_MIN" | tr , .)

# Validación de parámetros: deben ser números positivos (enteros o decimales) entre 0 y 100
for value in "$CPU_MIN" "$MEM_MIN"; do
  if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: CPU_MIN y MEM_MIN deben ser números positivos (entero o decimal)" >&2
    exit 1
  fi
  if (( $(echo "$value < 0" | bc -l) )); then
    echo "Error: los valores no pueden ser negativos" >&2
    exit 1
  fi
  if (( $(echo "$value > 100" | bc -l) )); then
    echo "Error: los valores no pueden ser mayores que 100" >&2
    exit 1
  fi
done

# Procesar la entrada con awk
# NF == 6 -> con timestamp
# NF == 5 -> sin timestamp
awk -v cpu_min="$CPU_MIN" -v mem_min="$MEM_MIN" -v regex="$REGEX" '

# Reemplazar coma por punto en los valores decimales
gsub(",", ".", $0)

NF == 6 {
  ts=$1; pid=$2; uid=$3; comm=$4; pcpu=$5; pmem=$6
}
NF == 5 {
  ts=""; pid=$1; uid=$2; comm=$3; pcpu=$4; pmem=$5
}
{
  # Validar que CPU y MEM sean valores numéricos
  if (pcpu ~ /^[0-9.]+$/ && pmem ~ /^[0-9.]+$/) {
    # Aplicar filtros de CPU, MEM y regex
    if (pcpu >= cpu_min && pmem >= mem_min && comm ~ regex) {
      if (ts == "")
        print pid, uid, comm, pcpu, pmem
      else
        print ts, pid, uid, comm, pcpu, pmem
    }
  }
}'

