La carpeta doc no fue modificada de la original. 

En la carpeta src, modificamos tp2.c y tp2.h para poder imprimir por consola cuánto tarda en ciclos de clock cada una de las ejecuciones del
filtro y la varianza, ya sea como una lista (es decir, separados por coma) o cada resultado en renglón distinto. Estas opciones estan comentadas
dejando el tp2.c como el original para que se puedan correr los tests. 

En la carpeta filters se encuentran los filtros implementados en ASM y dentro de la misma carpeta, en el directorio experimentos están las implementaciones 
modificadas que utilizamos para experimentar. También modificamos el makefile para cambiar el flag de optimización de la compilación de C.

En img agregamos imágenes que utilizamos en algunos experimentos.

Dentro de la carpeta helpers, en la carpeta Data texts agregamos archivos de texto en los que imprimimos información resultante de la ejecución de los
filtros mediante el ejecutable tp2. Esta información la utilizamos para armar los diagramas de caja que se encuentran en la carpeta boxplots.