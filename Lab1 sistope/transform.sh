#!/bin/bash
# Descripción: Transforma datos de procesos si se pasa --anon-uid anonimizando el UID por su hash SHA1
# Input: salida de filter.sh (timestamp pid uid comm pcpu pmem || pid uid comm pcpu pmem) desde stdin
# Output: mismas columnas, con UID anonimizado (hash SHA1) si se pasa --anon-uid

# Flag para la anonimización
ANON=false
if [[ "$1" == "--anon-uid" ]]; then  #Si se pasa --anon-uid se activa la anonimización
  ANON=true
  echo "Anonymizing UIDs" >&2  # Mensaje a stderr (>&2) indicando el proceso
fi

# Leer stdin línea por línea
while read -r line; do
  [[ -z "$line" ]] && continue  # Ignora líneas vacías

  NF=$(echo "$line" | awk '{print NF}')

  # Contar el número de campos en la línea para determinar si hay timestamp o no
  if [[ $NF -eq 6 ]]; then
    # Con timestamp - Se extraen los campos
    TS=$(echo "$line" | awk '{print $1}')
    PID=$(echo "$line" | awk '{print $2}')
    User_ID=$(echo "$line" | awk '{print $3}')
    COMM=$(echo "$line" | awk '{print $4}')
    PCPU=$(echo "$line" | awk '{print $5}')
    PMEM=$(echo "$line" | awk '{print $6}')
  elif [[ $NF -eq 5 ]]; then
    # Sin timestamp - Se extraen los campos
    TS=""  # No hay timestamp
    PID=$(echo "$line" | awk '{print $1}')
    User_ID=$(echo "$line" | awk '{print $2}')
    COMM=$(echo "$line" | awk '{print $3}')
    PCPU=$(echo "$line" | awk '{print $4}')
    PMEM=$(echo "$line" | awk '{print $5}')
  else
    continue  # Ignora líneas incorrectas (no cumplen formato de 5 o 6 campos)
  fi

# Procesamiento según modelo:
  if $ANON; then  # Si ANON está activado
    HASH=$(echo -n "$User_ID" | sha1sum | awk '{print $1}')  # Genera un hash SHA1 a partir del UID. sha1sum calcula el hash SHA1
    echo -e "$TS\t$PID\t$HASH\t$COMM\t$PCPU\t$PMEM"  # Imprime la línea reemplazando el UID por su hash.

# En caso de ANON desactivado se imprime la línea original sin cambios
  else
    echo "$line"

  fi
done

