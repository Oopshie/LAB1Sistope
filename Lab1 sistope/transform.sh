#!/bin/bash
# transform.sh Transforma datos de procesos si se pasa --anon-uid anonimizando el UID por su hash SHA1
# Input: salida de preprocess.sh o filter.sh (timestamp pid uid comm pcpu pmem) desde stdin
# Output: mismas columnas, con UID anonimizado (hash SHA1) si se pasa --anon-uid

# Flag para la anonimización
ANON=false
if [[ "$1" == "--anon-uid" ]]; then  #Si se pasa --anon-uid se activa la anonimización
  ANON=true
  echo "Anonymizing UIDs" >&2  # Mensaje a stderr (>&2) para no mezclar la salida
fi

# Leer stdin línea por línea
while read -r line; do
  [[ -z "$line" ]] && continue  #Ignora las líneas vacías
  # separar columnas:
  # Formato esperado: timestamp pid uid comm pcpu pmem
  TS=$(echo "$line" | awk '{print $1}')
  PID=$(echo "$line" | awk '{print $2}')
  User_ID=$(echo "$line" | awk '{print $3}')
  COMM=$(echo "$line" | awk '{print $4}')
  PCPU=$(echo "$line" | awk '{print $5}')
  PMEM=$(echo "$line" | awk '{print $6}')

# Procesamiento según modelo:
  if $ANON; then  # Si ANON está activado
    HASH=$(echo -n "$User_ID" | sha1sum | awk '{print $1}')  # Genera un hash SHA1 a partir del UID. sha1sum calcula el hash SHA1
    echo -e "$TS\t$PID\t$HASH\t$COMM\t$PCPU\t$PMEM"  # Imprime la línea reemplazando el UID por su hash.

# En caso de ANON desactivado se imprime la línea original sin cambios
  else
    echo "$line"

  fi
done

