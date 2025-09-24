#!/bin/bash
# aggregate.sh Agrega estadísticas de procesos agrupados por comando, mostrando promedios y máximos de CPU y MEM
# Input:  stdin con formato: 
#         - con timestamp: timestamp pid uid comm pcpu pmem
#         - sin timestamp: pid uid comm pcpu pmem
# Output: tabla con formato: comm count avg_pcpu max_pcpu avg_pmem max_pmem

echo "Starting aggregation..." >&2

# Array asociativo:
# count -> ocurrencias por comando
# sum_cpu -> acumulador de cpu por comando
# sum_mem -> acumulador de memoria por comando
# max_cpu -> máximo valor de CPU por comando
# max_mem -> máximo valor de memoria por comando
declare -A count sum_cpu sum_mem max_cpu max_mem

# Leer la entrada ignorando las primeras 3 columnas (timestamp, pid, uid). Solo considera comm, pcpu y pmem
while read -r line; do
    [[ -z "$line" ]] && continue    # Si la línea está vacía ignora la línea

    # Reemplazar coma por punto en los números
    line=$(echo "$line" | tr , .)

    # Obtener la cantidad de columnas de la línea
    NF=$(echo "$line" | awk '{print NF}')

    # Asignación de variables según el número de columnas
    if [[ $NF -eq 6 ]]; then
        # Caso con timestamp
        comm=$(echo "$line" | awk '{print $4}')   # Columna 4 = comando
        pcpu=$(echo "$line" | awk '{print $5}')   # Columna 5 = uso CPU
        pmem=$(echo "$line" | awk '{print $6}')   # Columna 6 = uso MEM
    elif [[ $NF -eq 5 ]]; then
        # Caso sin timestamp
        comm=$(echo "$line" | awk '{print $3}')   # Columna 3 = comando
        pcpu=$(echo "$line" | awk '{print $4}')   # Columna 4 = uso CPU
        pmem=$(echo "$line" | awk '{print $5}')   # Columna 5 = uso MEM
    else
        continue  # Si no tiene 5 o 6 columnas, se ignora
    fi

    # Convertir CPU y MEM a float, quedando decimal de 2 cifras
    pcpu=$(printf "%.2f" "$pcpu")
    pmem=$(printf "%.2f" "$pmem")

    # Contador de procesos por comando
    ((count[$comm]++))

    # Acumulador de CPU
    sum_cpu[$comm]=$(echo "${sum_cpu[$comm]:-0} + $pcpu" | bc -l)

    # Acumulador de MEM
    sum_mem[$comm]=$(echo "${sum_mem[$comm]:-0} + $pmem" | bc -l)

    # Si el máximo cpu actual es 0 ó la cpu del proceso actual es mayor al máximo, se actualiza el valor de max_cpu por la cpu del proceso actual.
    if [[ -z "${max_cpu[$comm]}" || $(echo "$pcpu > ${max_cpu[$comm]}" | bc -l) -eq 1 ]]; then
        max_cpu[$comm]=$pcpu
    fi
    # Si el máximo mem actual es 0 ó la mem del proceso actual es mayor al máximo, se actualiza el valor de max_mem por la mem del proceso actual.
    if [[ -z "${max_mem[$comm]}" || $(echo "$pmem > ${max_mem[$comm]}" | bc -l) -eq 1 ]]; then
        max_mem[$comm]=$pmem
    fi
done

# Calculo de promedios
for c in "${!count[@]}"; do
    avg_cpu=$(echo "${sum_cpu[$c]} / ${count[$c]}" | bc -l) # Obtiene el promedio de CPU
    avg_mem=$(echo "${sum_mem[$c]} / ${count[$c]}" | bc -l) # Obtiene el promedio de MEM
    #Imprime los resultados con formato tabulado y el redondeo a 2 decimales
    printf "%s\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n" "$c" "${count[$c]}" "$avg_cpu" "${max_cpu[$c]}" "$avg_mem" "${max_mem[$c]}" 
done
