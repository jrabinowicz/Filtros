
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>

#include "tp2.h"
#include "helper/tiempo.h"
#include "helper/libbmp.h"
#include "helper/utils.h"
#include "helper/imagenes.h"

// ~~~ seteo de los filtros ~~~

extern filtro_t Rombos;
extern filtro_t Bordes;
extern filtro_t Nivel;

filtro_t filtros[3];

// ~~~ fin de seteo de filtros ~~~

int main( int argc, char** argv ) {

    filtros[0] = Rombos; 
    filtros[1] = Bordes;
    filtros[2] = Nivel;

    configuracion_t config;
    config.dst.width = 0;
    config.bits_src = 32;
    config.bits_dst = 32;

    procesar_opciones(argc, argv, &config);
    
    // Imprimo info
    if (!config.nombre) {
        printf ( "Procesando...\n");
        printf ( "  Filtro             : %s\n", config.nombre_filtro);
        printf ( "  Implementación     : %s\n", C_ASM( (&config) ) );
        printf ( "  Archivo de entrada : %s\n", config.archivo_entrada);
    }

    snprintf(config.archivo_salida, sizeof  (config.archivo_salida), "%s/%s.%s.%s%s.bmp",
            config.carpeta_salida, basename(config.archivo_entrada),
            config.nombre_filtro,  C_ASM( (&config) ), config.extra_archivo_salida );

    if (config.nombre) {
        printf("%s\n", basename(config.archivo_salida));
        return 0;
    }

    filtro_t *filtro = detectar_filtro(&config);

    filtro->leer_params(&config, argc, argv);
    correr_filtro_imagen(&config, filtro->aplicador);
    filtro->liberar(&config);

    return 0;
}

filtro_t* detectar_filtro(configuracion_t *config) {
    for (int i = 0; filtros[i].nombre != 0; i++) {
        if (strcmp(config->nombre_filtro, filtros[i].nombre) == 0)
            return &filtros[i];
    }
    perror("Filtro desconocido\n");
    return NULL; // avoid C warning
}

void imprimir_tiempos_ejecucion(float *ciclos_de_cada, float varianza, unsigned long long int start, unsigned long long int end, int cant_iteraciones) {
    unsigned long long int cant_ciclos = end-start;

    printf("Tiempo de ejecución:\n");
    printf("  Comienzo                          : %llu\n", start);
    printf("  Fin                               : %llu\n", end);
    printf("  # iteraciones                     : %d\n", cant_iteraciones);
    
    ///// PRINTEAR LO QUE TARDA CADA ITERACION EN CICLO DE CLOCKS, RENGLON POR RENGLON
    // for (int i = 0; i < (float)cant_iteraciones; ++i){
    // 	printf("# ciclos del llamado %i 	: %.3f\n", (i + 1), ciclos_de_cada[i]);
    // }

    printf("  promedio de ciclos por llamada	: %.3f\n", (float)cant_ciclos/(float)cant_iteraciones);
    // printf("  varianza de ciclos por llamada	: %.3f\n", varianza);
    printf("  # de ciclos insumidos totales     : %llu\n", cant_ciclos);
    
    /////PRINTEAR LO QUE TARDA CADA ITERACION EN CICLO DE CLOCKS, COMO LISTA
    // for (int i = 0; i < (float)cant_iteraciones; ++i){
    //     printf("%.3f,", ciclos_de_cada[i]);
    //     if (i == ((float)cant_iteraciones) - 1){
    //         printf("%.3f", ciclos_de_cada[i]);
    //     }
    // }
}

void correr_filtro_imagen(configuracion_t *config, aplicador_fn_t aplicador) {
    imagenes_abrir(config);

    unsigned long long start, end, startLlamado, endLLamado;

    imagenes_flipVertical(&config->src, src_img);
    imagenes_flipVertical(&config->dst, dst_img);

    float ciclos_de_cada[config->cant_iteraciones];

    MEDIR_TIEMPO_START(start)
    for (int i = 0; i < config->cant_iteraciones; i++) {
    		MEDIR_TIEMPO_START(startLlamado)
            aplicador(config);
    		MEDIR_TIEMPO_STOP(endLLamado)
    		ciclos_de_cada[i] = (float)(endLLamado - startLlamado);
    }
    MEDIR_TIEMPO_STOP(end)

    float varianza = 0;
    float aux = 0;
    float media = (float)(end - start)/(float)(config->cant_iteraciones);

    for (int i = 0; i < config->cant_iteraciones; i++) {
    		aux = ciclos_de_cada[i] - media;
    		aux = aux * aux;
    		varianza = varianza + aux;
    }

    varianza = varianza / (float)(config->cant_iteraciones);

    imagenes_flipVertical(&config->dst, dst_img);

    imagenes_guardar(config);
    imagenes_liberar(config);
    imprimir_tiempos_ejecucion((float*)&ciclos_de_cada, varianza, start, end, config->cant_iteraciones);
}