#include <stdio.h>
#include <stdlib.h>

int main()
{
    int Value;
    printf("\n Enter the size of Matrix \n");
    scanf("%d", &Value);

    int a[Value][Value], b[Value][Value], c[Value][Value];
    int i, j, k;

    for(i=0; i<Value; i++){
        for(j=0; j<Value; j++){
            a[i][j] = rand() % 50;
        }
    }

    for(i=0; i<Value; i++) {
        for(j=0; j<Value; j++) {
	        b[i][j]=rand() % 50;
        }
	}

    // Matrix multiplication of a and b. Then store them in c
    for(i=0; i<Value; i++){
        for(j=0; j<Value; j++){
            c[i][j] = 0;
            for(k=0; k<Value; k++){
                c[i][j] = c[i][j] + a[i][k] * b[k][j];
            }
        }
    }

    printf("\n The results is: \n");
    for(i=0; i<Value; i++){
        for(j=0; j<Value; j++){
            printf("%d ", c[i][j]);
        }
        printf("\n");
    }

    return 0;


}