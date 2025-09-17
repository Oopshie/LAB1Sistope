#!/bin/bash
# Entradas: stdin con formato: timestamp pid uid comm pcpu pmem
# Salidas: stdout con el mismo formato, pero con UID anonimizado 
# Descripcion: Si se pasa --anon-uid, reemplaza el UID por su hash SHA1

ANON=false
if [[ "$1" == "--anon-uid" ]]; then
  ANON=true
  echo "Anonymizing UIDs" >&2

fi

while read -r line; do
  [[ -z "$line" ]] && continue
  # separar columnas:
  # timestamp pid uid comm pcpu pmem
  TS=$(echo "$line" | awk '{print $1}')
  PID=$(echo "$line" | awk '{print $2}')
  User_ID=$(echo "$line" | awk '{print $3}')
  COMM=$(echo "$line" | awk '{print $4}')
  PCPU=$(echo "$line" | awk '{print $5}')
  PMEM=$(echo "$line" | awk '{print $6}')

  if $ANON; then
    HASH=$(echo -n "$User_ID" | sha1sum | awk '{print $1}')
    echo -e "$TS\t$PID\t$HASH\t$COMM\t$PCPU\t$PMEM"

  else
    echo "$line"

  fi
done

