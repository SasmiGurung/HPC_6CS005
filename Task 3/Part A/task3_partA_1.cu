#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime_api.h>
#include <time.h>

/********************************************************************************
  This CUDA program demonstrates how to crack an encrypted password using a simple
  "brute force" algorithm. In this program. In this program a password consisting
  of two uppercase letters and two digit integers are cracked.

  Compile with:

    nvcc task3_partA_1.cu -o task3_partA_1

  To run:
  
    ./task3_partA_1 "password"

  If you want to analyse the results then use the redirection operator to send
  output to a file that you can be viewed using an editor

    ./task3_partA_1 "password" > task3_partA_1_results.txt

  Author: Sasmita Gurung 
  University Email: S.Gurung12@wlv.ac.uk
**********************************************************************************/

__device__ char* EncryptPassword(char* rawPassword){

	char * newPassword = (char *) malloc(sizeof(char) * 11);

	newPassword[0] = rawPassword[0] + 2;  
	newPassword[1] = rawPassword[0] - 2;
	newPassword[2] = rawPassword[0] + 1;  
	newPassword[3] = rawPassword[1] + 3;
	newPassword[4] = rawPassword[1] - 3;
	newPassword[5] = rawPassword[1] - 1;
	newPassword[6] = rawPassword[2] + 2;
	newPassword[7] = rawPassword[2] - 2;
	newPassword[8] = rawPassword[3] + 4;
	newPassword[9] = rawPassword[3] - 4;
	newPassword[10] = '\0';

	for(int i =0; i<10; i++){
        //checking all upper case letter limits
        if(i >= 0 && i < 6){
			if(newPassword[i] > 90){
				newPassword[i] = (newPassword[i] - 90) + 65;
			}else if(newPassword[i] < 65){
				newPassword[i] = (65 - newPassword[i]) + 65;
			}
		}
        //checking number section
        else{
            if(newPassword[i] > 57){
				newPassword[i] = (newPassword[i] - 57) + 48;
			}else if(newPassword[i] < 48){
				newPassword[i] = (48 - newPassword[i]) + 48;
			}
		}
	}

    // Returns encyted password
	return newPassword; 
}

__device__ int compareStrings(char* stringOne, char* stringTwo){
	
    while(*stringOne)
    {
        //Comparing the two strings
        if (*stringOne != *stringTwo)
            break;
 
        //Changing Pointer location
        stringOne++;
        stringTwo++;
    }
 
    // Returing the 0 if the two strings matches 
    return *(const unsigned char*)stringOne - *(const unsigned char*)stringTwo;
}

int time_difference(struct timespec *start, struct timespec *finish, long long int *difference) {
    long long int ds =  finish->tv_sec - start->tv_sec; 
    long long int dn =  finish->tv_nsec - start->tv_nsec; 

    if(dn < 0 ) {
        ds--;
        dn += 1000000000; 
    } 
    *difference = ds * 1000000000 + dn;
    return !(*difference > 0);
}

__global__ void kernel(char * alphabet, char * numbers, char * rawPassword){

    char generatedRawPassword[4];

    generatedRawPassword[0] = alphabet[blockIdx.x];
    generatedRawPassword[1] = alphabet[blockIdx.y];

    generatedRawPassword[2] = numbers[threadIdx.x];
    generatedRawPassword[3] = numbers[threadIdx.y];

    //Raw Password being encrypted
    char *encPassword = EncryptPassword(rawPassword);
        
    //Comparing encrypted generated password with encrypted password 
    if(compareStrings(EncryptPassword(generatedRawPassword), encPassword) == 0){
        printf("Your password is cracked : %s = %s\n", generatedRawPassword, rawPassword);
        printf("Your password Encrypted password : %s = %s\n", encPassword);
        }
}

int main(int argc, char ** argv){

    char cpuAlphabet[26] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    char cpuNumbers[10] = {'0','1','2','3','4','5','6','7','8','9'};

    char * gpuAlphabet;
    cudaMalloc( (void**) &gpuAlphabet, sizeof(char) * 26); 
    cudaMemcpy(gpuAlphabet, cpuAlphabet, sizeof(char) * 26, cudaMemcpyHostToDevice);

    char * gpuNumbers;
    cudaMalloc( (void**) &gpuNumbers, sizeof(char) * 10); 
    cudaMemcpy(gpuNumbers, cpuNumbers, sizeof(char) * 10, cudaMemcpyHostToDevice);

    char * password;
    cudaMalloc( (void**) &password, sizeof(char) * 26); 
    cudaMemcpy(password, argv[1], sizeof(char) * 26, cudaMemcpyHostToDevice);

    struct timespec start, finish;
    long long int time_elapsed;
    clock_gettime(CLOCK_MONOTONIC, &start);
        
    kernel<<< dim3(26,26,1), dim3(10,10,1) >>>( gpuAlphabet, gpuNumbers, password);
    cudaDeviceSynchronize();

    clock_gettime(CLOCK_MONOTONIC, &finish);
    time_difference(&start, &finish, &time_elapsed);
    printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, (time_elapsed/1.0e9)); 

    return 0;
}