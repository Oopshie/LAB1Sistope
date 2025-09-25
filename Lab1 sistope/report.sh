#!/bin/bash
# Descripción: Genera un reporte final con fecha, usuario, host y métricas de procesos
# Entradas: stdin (salida de aggregate.sh), -o ARCHIVO (archivo de salida)
# Salidas: archivo CSV/TSV con metadatos y datos


# Parseo de flags
# -o : nombre del archivo de salida
while getopts "o:" opt; do
  case $opt in
    o) ARCHIVO=$OPTARG ;;  # Guarda el archivo de salida
    *) echo "Uso: $0 -o ARCHIVO" >&2; exit 1 ;;  # En caso de error muestra el uso y finaliza
  esac
done

# Validación parámetro de salida
if [[ -z "$ARCHIVO" ]]; then  # Si no se indicó un archivo de salida...
  echo "Error: debes indicar un archivo de salida con -o" >&2  # Se muestra error y finaliza
  exit 1
fi

# Obtener metadatos
FECHA=$(date -Iseconds)  # Fecha y hora ISO 8601
USUARIO=$(whoami)  # Usuario actual
HOST=$(hostname)  # Nombre del host

# Escribir encabezado de metadatos y datos en el archivo
{
  echo "# fecha: $FECHA"  # Línea de metadato: fecha
  echo "# usuario: $USUARIO"  # Línea de metadato: usuario
  echo "# host: $HOST"  # Línea de metadato: host
  echo "comando,procesos,cpu_avg,cpu_max,mem_avg,mem_max"  # Encabezado de columnas del CSV
  
  # Agregar contenido desde stdin
  cat -  # cat- : inyección de entrada desde el stdin
} > "$ARCHIVO"  # Redirige toda la salida al archivo especificado
