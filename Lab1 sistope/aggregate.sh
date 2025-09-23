#!/bin/bash
# aggregate.sh Agrega estadísticas de procesos agrupados por comando, mostrando promedios y máximos de CPU y MEM
# Input:  stdin con formato: timestamp pid uid comm pcpu pmem
# Output: tabla con formato: comm count avg_pcpu max_pcpu avg_pmem max_pmem

# Array asociativo:
# count -> ocurrencias por comando
# sum_cpu -> acumulador de cpu por comando
# sum_mem -> acumulador de memoria por comando
# max_cpu -> máximo valor de CPU por comando
# max_mem -> máximo valor de memoria por comando
declare -A count sum_cpu sum_mem max_cpu max_mem

# Leer la entrada ignorando las primeras 3 columnas (timestamp, pid, uid). Solo considera comm, pcpu y pmem
while read -r _ _ _ comm pcpu pmem; do
    [[ -z "$comm" ]] && continue    # Si comm está vacío ignora la línea

    # Convertir CPU y MEM a float, quedando decimal de 2 cifras
    pcpu=$(printf "%.2f" "$pcpu")
    pmem=$(printf "%.2f" "$pmem")

    # Contador de procesos por comando
    ((count[$comm]++))
    # Acumulador de CPU
    sum_cpu[$comm]=$(echo "${sum_cpu[$comm]:-0} + $pcpu" | bc)
    # Acumulador de MEM
    sum_mem[$comm]=$(echo "${sum_mem[$comm]:-0} + $pmem" | bc)

    # Si el máximo cpu actual es 0 ó la cpu del proceso actual es mayor al máximo, se actualiza el valor de max_cpu por la cpu del proceso actual.
    if [[ -z "${max_cpu[$comm]}" || $(echo "$pcpu > ${max_cpu[$comm]}" | bc) -eq 1 ]]; then
        max_cpu[$comm]=$pcpu
    fi
    # Si el máximo mem actual es 0 ó la mem del proceso actual es mayor al máximo, se actualiza el valor de max_mem por la mem del proceso actual.
    if [[ -z "${max_mem[$comm]}" || $(echo "$pmem > ${max_mem[$comm]}" | bc) -eq 1 ]]; then
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
