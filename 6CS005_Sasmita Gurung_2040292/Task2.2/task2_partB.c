#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <math.h>
#include <malloc.h>
#include "constants.h"

/********************************************************************************
  This C program demonstrates how to multiply matrix multiplication of given 
  dimensions

  Compile with:

    cc task2_partB.c -o task2_partB -lrt -pthread 

  To run:

    ./task2_partC_5 

  If you want to analyse the results then use the redirection operator to send
  output to a file that you can be viewed using an editor

    ./task2_partB  > task2_partB results.txt

  Author: Sasmita Gurung 
  University Email: S.Gurung12@wlv.ac.uk
**********************************************************************************/


int matrix1[MAT_SIZE][MAT_SIZE]; //First Matrix
int matrix2[MAT_SIZE][MAT_SIZE]; //Second Matrix
int result [MAT_SIZE][MAT_SIZE]; // Resultant Matrix

typedef struct arguments {
    int start;
    int stride;
} arguments_t;

void matrix_multiplication(){
    int i;
    pthread_t *t = malloc(sizeof(pthread_t) * n_threads);
    arguments_t *a = malloc(sizeof(arguments_t) * n_threads);

    for(int i=0; i<n_threads; i++){
        a[i].start = i;
        a[i].stride = n_threads;
    }

    void *multiply_matrix();

    for(i=0; i<n_threads; i++){
        pthread_create(&t[i], NULL, multiply_matrix, &a[i]);
    }

    for(i=0; i<n_threads; i++){
        pthread_join(t[i], NULL);
    }

    free(t);
    free(a);
}

void *multiply_matrix(arguments_t *args){

     for(int a=args->start; a<MAT1_COL; a+=args->stride){
        for(int x=0; x<MAT1_ROW; x++){
            for(int y=0; y<MAT2_COL; y++){
                result[x][y] += matrix1[x][a] * matrix2[a][y];
            }
        }
    }
}

int time_difference(struct timespec *start, struct timespec *finish, 
                              long long int *difference) {
  long long int ds =  finish->tv_sec - start->tv_sec; 
  long long int dn =  finish->tv_nsec - start->tv_nsec; 

  if(dn < 0 ) {
    ds--;
    dn += 1000000000; 
  } 
  *difference = ds * 1000000000 + dn;
  return !(*difference > 0);
}

int main(){

    struct timespec start, finish;   
    long long int time_elapsed;

    //Initializing All Defined Matrices By Zero
    for(int x=0; x<MAT_SIZE; x++){
        for(int y=0;y<MAT_SIZE; y++){
            matrix1[x][y] = 0;
            matrix2[x][y] = 0;
            result[x][y] = 0;
        }
    }
    
    printf("\n --- Initializing Matrix 1 of dimension %d x %d ---\n\n", MAT1_ROW, MAT1_COL);
    for(int x=0;x<MAT1_ROW; x++){
        for(int y=0;y<MAT1_COL; y++){
            matrix1[x][y] = rand() % 50;
        }
    }
    
    printf("\n --- Initializing Matrix 2 of dimension %d x %d ---\n\n", MAT1_COL, MAT2_COL);
    for(int x=0; x<MAT1_COL; x++){
        for(int y=0; y<MAT2_COL; y++){
            matrix2[x][y] = rand() % 50;
        }
    }

    //Printing Matrices - - - - - - - - - - - - - - - - - - - - - - - - - - -//
    
    printf("\n --- Matrix 1 ---\n\n");
    for(int x=0;x<MAT1_ROW;x++){
        for(int y=0;y<MAT1_COL;y++){
            printf("%5d",matrix1[x][y]);
        }
        printf("\n\n");
    }
    
    printf(" --- Matrix 2 ---\n\n");
    for(int x=0;x<MAT1_COL;x++){
        for(int y=0;y<MAT2_COL;y++){
            printf("%5d",matrix2[x][y]);
        }
        printf("\n\n");
    }   

    //Start Timer
    clock_gettime(CLOCK_MONOTONIC, &start);

    matrix_multiplication();

    //Print Multiplied Matrix (Result) - - - - - - - - - - - - - - - - - - -//
    printf(" --- Multiplied Matrix ---\n\n");
    for(int x=0; x<MAT1_ROW; x++){
        for(int y=0; y<MAT2_COL; y++){
            printf("%5d",result[x][y]);
        }
        printf("\n\n");
    }

    clock_gettime(CLOCK_MONOTONIC, &finish);
    time_difference(&start, &finish, &time_elapsed);
    printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, 
            (time_elapsed/1.0e9));

    return 0;
}
