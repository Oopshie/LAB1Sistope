# LAB1Sistope

Para la ejecución de los archivos, debe inicialmente darse permisos utilizando el comando 
chmod para cada archivo.
Ejemplo: $chmod +x archivo.sh

A continuación, deben ejecutarse los archivos como se indica en la siguiente línea:

CONSIDERACIONES

  --generator.sh--
- Para la ejecución del archivo generator, el valor ingresado en tiempo (-t) debe ser un número entero positivo
- El valor de intervalo debe ser un número positivo entero o decimal

  --filter.sh--
- Para la ejecución del archivo filter, los valores ingresados tanto en cpu_max como en mem_max deben ser números positivos enteros o decimales menores o iguales a 100.
  Ejemplo de ejecución línea de filter:
  ./filter.sh -c CPU_MIN -m MEM_MIN -r REGEX
