#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

#define MAT_SIZE 50
#define MAT1_ROW 50
#define MAT1_COL 50 // matrix multiplication: mxn nxp (column of 1st matrix should be same as row of second matrix) 
#define MAT2_COL 50

#define MAX_THREADS 10000 // each row and column are multiplied. 
 
int matrix1[MAT_SIZE][MAT_SIZE]; //First Matrix
int matrix2[MAT_SIZE][MAT_SIZE]; //Second Matrix
int result [MAT_SIZE][MAT_SIZE]; // Resultant Matrix

//Type Defining For Passing Function Argumnents
typedef struct parameters {
    int x,y;
}args;

//Function For Calculate Each Element in Result Matrix Used By Threads
void *mult(void* arg){
    
    args* p = arg;
    
    //Calculating Each Element in Result Matrix Using Passed Arguments
    for(int a=0; a<MAT1_COL; a++){
        result[p->x][p->y] += matrix1[p->x][a]*matrix2[a][p->y];
    }
    sleep(3);
    
    //End Of Thread
    pthread_exit(0);
}


int main(){

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

    //Multiply Matrices Using Threads - - - - - - - - - - - - - - - - - - - -//
    
    //Defining Threads
    pthread_t thread[MAX_THREADS];
    
    //Counter For Thread Index
    int thread_number = 0;
    
    //Defining p For Passing Parameters To Function As Struct
    args p[MAT1_ROW*MAT2_COL];
    
    //Start Timer
    time_t start = time(NULL);

    for(int x=0; x<MAT1_ROW; x++){
        for(int y=0; y<MAT2_COL; y++){
            
            //Initializing Parameters For Passing To Function
            p[thread_number].x=x;
            p[thread_number].y=y;
            
            //Status For Checking Errors
            int status;
            
            //Create Specific Thread For Each Element In Result Matrix
            status = pthread_create(&thread[thread_number], NULL, mult, (void *) &p[thread_number]);
            
            //Check For Error
            if(status!=0){
                printf("Error In Threads");
                exit(0);
            }
            
            thread_number++;
        }
    }

    //Wait For All Threads Done - - - - - - - - - - - - - - - - - - - - - - //
    for(int z=0; z<(MAT1_ROW * MAT2_COL); z++)
        pthread_join(thread[z], NULL);

    //Print Multiplied Matrix (Result) - - - - - - - - - - - - - - - - - - -//
    printf(" --- Multiplied Matrix ---\n\n");
    for(int x=0; x<MAT1_ROW; x++){
        for(int y=0; y<MAT2_COL; y++){
            printf("%5d",result[x][y]);
        }
        printf("\n\n");
    }

     //Total Threads Used In Process - - - - - - - - - - - - - - - - - - - -//
    printf(" ---> Used Threads : %d \n\n",thread_number);
    for(int z=0;z<thread_number;z++)
        printf(" - Thread %d ID : %d\n",z+1,(int)thread[z]);
    
    //Calculate Total Time Including 3 Soconds Sleep In Each Thread - - - -//
    printf(" !!! Time Elapsed : %.2f Sec\n\n", (double)(time(NULL) - start));

    return 0;
}
