#!/bin/bash
# report.sh - Genera reporte final con metadatos
# Entradas: stdin (salida de aggregate.sh), -o ARCHIVO
# Salidas: archivo CSV/TSV con metadatos y datos
# Descripción: escribe un reporte con fecha, usuario, host y métricas de procesos

# Parseo de flags
while getopts "o:" opt; do
  case $opt in
    o) ARCHIVO=$OPTARG ;;
    *) echo "Uso: $0 -o ARCHIVO" >&2; exit 1 ;;
  esac
done

# Validación
if [[ -z "$ARCHIVO" ]]; then
  echo "Error: debes indicar un archivo de salida con -o" >&2
  exit 1
fi

# Obtener metadatos
FECHA=$(date -Iseconds)
USUARIO=$(whoami)
HOST=$(hostname)

# Escribir encabezado de metadatos
{
  echo "# fecha: $FECHA"
  echo "# usuario: $USUARIO"
  echo "# host: $HOST"
  echo "comando,procesos,cpu_avg,cpu_max,mem_avg,mem_max"
  
  # Agregar contenido desde stdin
  cat -
} > "$ARCHIVO"
