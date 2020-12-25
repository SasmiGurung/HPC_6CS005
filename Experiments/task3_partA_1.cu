#include <stdio.h>
#include <cuda_runtime_api.h>
#include <time.h>

/********************************************************************************
  This CUDA program demonstrates how to crack an encrypted password using a simple
  "brute force" algorithm. In this program. In this program a password consisting
  of two uppercase letters and two digit integers are cracked.

  Compile with:

    nvcc task3_partA_1.cu -o task3_partA_1

  To run:
  
    ./task3_partA_1

  If you want to analyse the results then use the redirection operator to send
  output to a file that you can be viewed using an editor

    ./task3_partA_1 > task3_partA_1_results.txt

  Author: Sasmita Gurung 
  University Email: S.Gurung12@wlv.ac.uk
**********************************************************************************/

__device__ int match(char *check) {
  char plainPassword_1[] = "BF9999";
  char plainPassword_2[] = "CN9898";
  char plainPassword_3[] = "BT9893";
  char plainPassword_4[] = "MA5369";

  char *a = check;
  char *b = check;
  char *c = check;
  char *d = check;
  char *p1 = plainPassword_1;
  char *p2 = plainPassword_2;
  char *p3 = plainPassword_3;
  char *p4 = plainPassword_4;

  while(*a == *p1) { 
   if(*a == '\0') 
    {
      printf("(Found) Password cracked is: %s\n",plainPassword_1);
      break;
    }

    a++;
    p1++;
  }
	
  while(*b == *p2) { 
   if(*b == '\0') 
    {
      printf("(Found) Password cracked is: %s\n",plainPassword_2);
      break;
    }

    b++;
    p2++;
  }

  while(*c == *p3) { 
   if(*c == '\0') 
    {
      printf("(Found) Password cracked is: %s\n",plainPassword_3);
      break;
    }

    c++;
    p3++;
  }

  while(*d == *p4) { 
   if(*d == '\0') 
    {
      printf("(Found) Password cracked is: %s\n",plainPassword_4);
      return 1;
    }

    d++;
    p4++;
  }
  return 0;

}


__global__ void  kernel() {
  char w,x,y,z;
  char password[7];
  password[6] = '\0';

  int i = blockIdx.x+65;
  int j = threadIdx.x+65;
  char firstValue = i; 
  char secondValue = j; 
    
password[0] = firstValue;
password[1] = secondValue;

for(w='0'; w<='9'; w++){
  for(x='0'; x<='9'; x++){
    for(y='0'; y<='9'; y++){
      for(z='0'; z<='9'; z++){
	  password[2] = w;
	  password[3] = x;
	  password[4] = y;
	  password[5] = z; 
	  if(match(password)) {
	    printf("password found: %s\n", password);  
	  } 
          else {
	     	  printf("(Processing) Brute Force Tried: %s\n", password); 
	      }
	   }
	}
    }
  }

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


int main() {

  struct  timespec start, finish;
  long long int time_elapsed;
  clock_gettime(CLOCK_MONOTONIC, &start);

  kernel <<<26,26>>>();
  cudaDeviceSynchronize();

  clock_gettime(CLOCK_MONOTONIC, &finish);
  time_difference(&start, &finish, &time_elapsed);
  printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, (time_elapsed/1.0e9)); 

  return 0;
}


