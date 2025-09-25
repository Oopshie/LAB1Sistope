# LAB1Sistope

Para la correcta ejecución de los archivos, siga los siguientes pasos:
1- Abrir la terminar en la carpeta de los archivos
  1.1- Asegúrese de tener dentro los archivos: generator.sh – preprocess.sh – filter.sh – transform.sh – aggregate.sh – report.sh

2- Otorgar permisos a los scripts. Utilice el siguiente comando:
  $ chmod +x generator.sh preprocess.sh filter.sh transform.sh aggregate.sh report.sh

3- A continuación, los scripts se ejecutarán a partir de la siguiente línea de comando:

./generator.sh -i 1 -t 3 | ./preprocess.sh | ./filter.sh -c 1 -m 1 -r "^(spotify|firefox)$" | ./transform.sh --anon-uid | ./aggregate.sh | ./report.sh -o reporte.tsv
ó
./generator.sh -i 1 -t 3 | ./preprocess.sh | ./filter.sh -c 1 -m 1 -r "^(spotify|firefox)$" | ./transform.sh --anon-uid | ./aggregate.sh | ./report.sh -o reporte.csv

Recuerde que los valores
-i, -t, -c, -m, -r pueden ser modificados respetando el formato.

----------------------------------------
[**CONSIDERACIONES SCRIPTS**]

  --generator.sh--
- El valor ingresado en intervalo (-i) debe ser un número positivo entero o decimal.
- El valor ingresado en tiempo (-t) debe ser un número positivo entero.

  --preprocess.sh--
- Se tiene como opción añadir un timestamp ISO 8601, para ello, cambiar en la línea de ejecución de la siguiente manera:
  ./preprocess.sh --iso8601
- Si no se desea añadir timestamp, reemplazar la línea por:
  ./preprocess.sh
  
  --filter.sh--
- Los valores ingresados tanto en cpu_max como en mem_max deben ser números positivos enteros o decimales menores o iguales a 100.
  Formato de ejecución línea de filter:
  ./filter.sh -c CPU_MIN -m MEM_MIN -r REGEX

  --transform.sh--
- Se tiene como opción anonimizar el UID por un hash SHA1, para ello, cambiar en la línea de ejecución de la siguiente manera:
  ./transform.sh --anon-uid
- Si no se desea anonimizar, reemplazar la línea por:
  ./transform.sh

  --aggregate.sh--
- Sin consideraciones adicionales

  --report.sh--
- Se debe indicar correctamente un archivo de salida .tsv ó .csv para la generación del reporte.

----------------------------------------
[**NOTAS ADICIONALES**]

1. Los scripts deben ejecutarse en el orden correcto para garantizar que los datos fluyan correctamente.
2. Los valores numéricos (CPU, MEM, intervalos, tiempo) son validados para asegurar que sean positivos y dentro de los rangos válidos.
3. report.sh sobrescribirá el archivo de salida si ya existe.







