#!/bin/bash
# Input: cada x segundos (-i), durante el tiempo total (-t)
# Output: lista de procesos ordenada por uso de CPU, compatible con preprocess.sh

# Mensaje inicial comienzo de proceso
echo "Starting process generator..." >&2

# Parseo de flags
# -i : segundos del intervalo a capturar
# -t : tiempo total de ejecución en segundos
while getopts "i:t:" opt; do
  case $opt in
    i) INTERVALO=$OPTARG ;;    # guarda -i en INTERVALO
    t) TIEMPO=$OPTARG ;;      # guarda -t en TIEMPO
    *) echo "Uso: $0 -i INTERVALO -t TIEMPO"; exit 1 ;; # Si hay parámetros inválidos finaliza con error
  esac
done

# Validación de parámetros
if [[ -z "$INTERVALO" || -z "$TIEMPO" ]]; then    # Si alguno de los valores es vacío...
  echo "Error: debes indicar -i INTERVALO y -t TIEMPO"  # Muestra error
  exit 1
fi

# Reemplazar comas por puntos (1,5 -> 1.5)
INTERVALO=$(echo "$INTERVALO" | tr , .)

# Validación que sean número positivo entero o decimal
if ! [[ "$INTERVALO" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Error: el intervalo (-i) debe ser un número positivo (entero o decimal)" >&2
  exit 1
fi

if ! [[ "$TIEMPO" =~ ^[0-9]+?$ ]]; then
  echo "Error: el tiempo total (-t) debe ser un número positivo entero" >&2
  exit 1
fi

# Comprobar que sean mayores que 0 usando bc
if (( $(echo "$INTERVALO <= 0" | bc -l) )); then
  echo "Error: el intervalo debe ser mayor que 0" >&2
  exit 1
fi

if (( $(echo "$TIEMPO <= 0" | bc -l) )); then
  echo "Error: el tiempo total debe ser mayor que 0" >&2
  exit 1
fi

INICIO=$(date +%s) # Guarda la hora de inicio en segundos

# Loop principal
while [ $(( $(date +%s) - INICIO )) -lt $TIEMPO ]; do   # Se ejecuta hasta alcanzar el tiempo total
  # Genera lista de procesos ordenada por uso de CPU
  # Solo imprime las columnas necesarias (pid, uid, comm, pcpu, pmem)
  # ps -eo muestra las columnas personalizas
  # --sort=-%cpu ordena por consumo de CPU de mayor a menor
  ps -eo pid=,uid=,comm=,pcpu=,pmem= --sort=-%cpu
  sleep "$INTERVALO" # Espera los segundos indicados y luego vuelve al bucle
done
