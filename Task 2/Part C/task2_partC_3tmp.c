#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <crypt.h>
#include <time.h>

/********************************************************************************
  This C program demonstrates how to crack an encrypted password using a simple
  "brute force" algorithm. In this program. In this program a password consisting
  of two uppercase letters and two digit integers are cracked.

  Compile with:

    gcc task2_partC_3.c -o task2_partC_3 -lcrypt

  To run:
  
    ./task2_partC_3 

  If you want to analyse the results then use the redirection operator to send
  output to a file that you can be viewed using an editor

    ./task2_partC_3 > task2_partC_3_results.txt

  Author: Sasmita Gurung 
  University Email: S.Gurung12@wlv.ac.uk
**********************************************************************************/


/**
 Required by lack of standard function in C.   
*/

void substr(char *dest, char *src, int start, int length){
  memcpy(dest, src + start, length);
  *(dest + length) = '\0';
}

int time_difference(struct timespec *start, 
                    struct timespec *finish, 
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



void crack(char *salt_and_encrypted){
  int w,x, y, z;     // Loop counters
  char salt[7];    // String used in hashing the password. Need space
  char plain[7];   // The combination of letters currently being checked
  char *enc;       // Pointer to the encrypted password
  int count = 0;   // The number of combinations explored so far

  substr(salt, salt_and_encrypted, 0, 6);

  for(w='A'; w<='Z'; w++){
    for(x='A'; x<='Z'; x++){
      for(y='A'; y<='Z'; y++){
        for(z=0; z<=99; z++){
          sprintf(plain, "%c%c%c%02d", w, x, y, z); 
          enc = (char *) crypt(plain, salt);
          count++;
          if(strcmp(salt_and_encrypted, enc) == 0){
            printf("#%-8d%s %s\n", count, plain, enc);
            //return; // stop when found the wright password without exploring all possibilities
          } else {
            printf(" %-8d%s %s\n", count, plain, enc);
         }
       }
     }
   }
 }
  printf("%d solutions explored\n", count);
}

int main(int argc, char *argv[]){

  struct timespec start, finish;   
  long long int time_elapsed;

  int i;
  
  clock_gettime(CLOCK_MONOTONIC, &start);

  crack("$6$KB$.gxHi53YhQucpKx7NZVSu6uYhqGZi9WBp7aWqJ9h5QajOJDX5TuMzmZvaP1Va8Ovd.gwiQbTqMsVkD9jrfCNz0");

  clock_gettime(CLOCK_MONOTONIC, &finish);
  time_difference(&start, &finish, &time_elapsed);
  printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed,
                                         (time_elapsed/1.0e9)); 

  return 0;
}







