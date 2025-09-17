#!/bin/bash
# Entradas: stdin con formato: timestamp pid uid comm pcpu pmem
# Salidas: stdout con formato: comm count avg_pcpu avg_pmem pcpumax pmemmax
# Descripcion: agrupa por comando (comm), muestra promedios y máximos de CPU y MEM

declare -A count sum_cpu sum_mem max_cpu max_mem

while read -r _ _ _ comm pcpu pmem; do
    [[ -z "$comm" ]] && continue

    # Convertir CPU y MEM a float
    pcpu=$(printf "%.2f" "$pcpu")
    pmem=$(printf "%.2f" "$pmem")

    ((count[$comm]++))
    sum_cpu[$comm]=$(echo "${sum_cpu[$comm]:-0} + $pcpu" | bc)
    sum_mem[$comm]=$(echo "${sum_mem[$comm]:-0} + $pmem" | bc)

    # Máximos
    if [[ -z "${max_cpu[$comm]}" || $(echo "$pcpu > ${max_cpu[$comm]}" | bc) -eq 1 ]]; then
        max_cpu[$comm]=$pcpu
    fi
    if [[ -z "${max_mem[$comm]}" || $(echo "$pmem > ${max_mem[$comm]}" | bc) -eq 1 ]]; then
        max_mem[$comm]=$pmem
    fi
done

# Imprimir resultados
for c in "${!count[@]}"; do
    avg_cpu=$(echo "${sum_cpu[$c]} / ${count[$c]}" | bc -l)
    avg_mem=$(echo "${sum_mem[$c]} / ${count[$c]}" | bc -l)
    printf "%s\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n" "$c" "${count[$c]}" "$avg_cpu" "${max_cpu[$c]}" "$avg_mem" "${max_mem[$c]}"
done
