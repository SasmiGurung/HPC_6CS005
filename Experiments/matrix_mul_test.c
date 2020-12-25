#include <stdio.h>
#include <stdlib.h>

int main()
{
    int a[3][3], b[3][3], c[3][3];
    int i, j, k;

    printf("\n Enter First Matrix \n");
    for(i=0; i<3; i++){
        for(j=0; j<3; j++){
            scanf("%d", &a[i][j]);
        }
    }

    printf("\n Enter Second Matrix \n");
    for(i=0; i<3; i++){
        for(j=0; j<3; j++){
            scanf("%d", &b[i][j]);
        }
    }

    // Matrix multiplication of a and b. Then store them in c
    for(i=0; i<3; i++){
        for(j=0; j<3; j++){
            c[i][j] = 0;
            for(k=0; k<3; k++){
                c[i][j] = c[i][j] + a[i][k] * b[k][j];
            }
        }
    }

    printf("\n The results is: \n");
    for(i=0; i<3; i++){
        for(j=0; j<3; j++){
            printf("%d ", c[i][j]);
        }
        printf("\n");
    }

    return 0;


}