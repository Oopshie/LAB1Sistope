#!/bin/bash
# generator.sh mejorado
# Input: cada x segundos (-i), durante el tiempo total (-t)
# Output: lista de procesos ordenada por uso de CPU, compatible con preprocess.sh

# Parseo de flags
echo "Starting process generator..." >&2
while getopts "i:t:" opt; do
  case $opt in
    i) INTERVALO=$OPTARG ;;
    t) TIEMPO=$OPTARG ;;
    *) echo "Uso: $0 -i INTERVALO -t TIEMPO"; exit 1 ;;
  esac
done

# Validación de parámetros
if [[ -z "$INTERVALO" || -z "$TIEMPO" ]]; then
  echo "Error: debes indicar -i INTERVALO y -t TIEMPO"
  exit 1
fi

INICIO=$(date +%s)

# Loop principal
while [ $(( $(date +%s) - INICIO )) -lt $TIEMPO ]; do 
  # Genera lista de procesos ordenada por uso de CPU
  # Solo imprime las columnas necesarias (pid, uid, comm, pcpu, pmem)
  ps -eo pid=,uid=,comm=,pcpu=,pmem= --sort=-%cpu
  sleep "$INTERVALO"
done