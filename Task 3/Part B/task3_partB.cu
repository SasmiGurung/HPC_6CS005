#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>

/********************************************************************************
  This CUDA program demonstrates how do process image using CUDA. This program
  will take image and performs Gaussian Blur filtering then saves the blurred 
  image. 

  Compile with:

    nvcc task3_partB.cu -o task3_partB lodepng.cpp

  To run:
  
    ./task3_partB "input filename"

  Author: Sasmita Gurung 
  University Email: S.Gurung12@wlv.ac.uk
**********************************************************************************/

__device__ unsigned int deviceWidth;

//Getting Red pixels
__device__ unsigned char getRed(unsigned char *image, unsigned int row, unsigned int column)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4);

    return image[i];
}

//Getting Green pixels
__device__ unsigned char getGreen(unsigned char *image, unsigned int row, unsigned int column)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4) + 1;

    return image[i];
}

//Getting Blue  pixels
__device__ unsigned char getBlue(unsigned char *image, unsigned int row, unsigned int column)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4) + 2;

    return image[i];
}

//Getting Alpha pixels (transperancy)
__device__ unsigned char getAlpha(unsigned char *image, unsigned int row, unsigned int column)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4) + 3;

    return image[i];
}

//Setting Red value
__device__ void setRed(unsigned char *image, unsigned int row, unsigned int column, unsigned char red)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4);

    image[i] = red;
}

//Setting Green value
__device__ void setGreen(unsigned char *image, unsigned int row, unsigned int column, unsigned char green)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4) + 1;

    image[i] = green;
}

//Setting Blue value
__device__ void setBlue(unsigned char *image, unsigned int row, unsigned int column, unsigned char blue)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4) + 2;

    image[i] = blue;
}

//Setting Alpha value
__device__ void setAlpha(unsigned char *image, unsigned int row, unsigned int column, unsigned char alpha)
{
    unsigned int i = (row * deviceWidth * 4) + (column * 4) + 3;

    image[i] = alpha;
}


__global__ void applyGaussianBlurr(unsigned char* image, unsigned char* newImage, unsigned int *width){
    int row = blockIdx.x+1;
    int column = threadIdx.x+1;

    deviceWidth = *width;
    
    unsigned redTL, redTC, redTR;
    unsigned redL, redC, redR;
    unsigned redBL, redBC, redBR;
    unsigned newRed;

    unsigned greenTL, greenTC, greenTR;
    unsigned greenL, greenC, greenR;
    unsigned greenBL, greenBC, greenBR;
    unsigned newGreen;

    unsigned blueTL, blueTC, blueTR;
    unsigned blueL, blueC, blueR;
    unsigned blueBL, blueBC, blueBR;
    unsigned newBlue;
    
    setGreen(newImage, row, column, getGreen(image, row, column));
    setBlue(newImage, row, column, getBlue(image, row, column));
    setAlpha(newImage, row, column, 255);

    redTL = getRed(image, row - 1, column - 1);
    redTC = getRed(image, row - 1, column);
    redTR = getRed(image, row - 1, column + 1);

    redL = getRed(image, row, column - 1);
    redC = getRed(image, row, column);
    redR = getRed(image, row, column + 1);

    redBL = getRed(image, row + 1, column - 1);
    redBC = getRed(image, row + 1, column);
    redBR = getRed(image, row + 1, column + 1);

    newRed = (redTL+redTC+redTR+redL+redC+redR+redBL+redBC+redBR)/9;  //Bluring red columnor value

    setRed(newImage, row, column, newRed);

    greenTL = getGreen(image, row - 1, column - 1);
    greenTC = getGreen(image, row - 1, column);
    greenTR = getGreen(image, row - 1, column + 1);

    greenL = getGreen(image, row, column - 1);
    greenC = getGreen(image, row, column);
    greenR = getGreen(image, row, column + 1);

    greenBL = getGreen(image, row + 1, column - 1);
    greenBC = getGreen(image, row + 1, column);
    greenBR = getGreen(image, row + 1, column + 1);

    newGreen = (greenTL+greenTC+greenTR+greenL+greenC+greenR+greenBL+greenBC+greenBR)/9; //Bluring green columnor value

    setGreen(newImage, row, column, newGreen);

    blueTL = getBlue(image, row - 1, column - 1);
    blueTC = getBlue(image, row - 1, column);
    blueTR = getBlue(image, row - 1, column + 1);

    blueL = getBlue(image, row, column - 1);
    blueC = getBlue(image, row, column);
    blueR = getBlue(image, row, column + 1);

    blueBL = getBlue(image, row + 1, column - 1);
    blueBC = getBlue(image, row + 1, column);
    blueBR = getBlue(image, row + 1, column + 1);

    newBlue = (blueTL+blueTC+blueTR+blueL+blueC+blueR+blueBL+blueBC+blueBR)/9; //Bluring blue columnor value

    setBlue(newImage, row, column, newBlue);

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

int main(int argc, char **argv)
{
    unsigned char *image;
    const char *filename = argv[1];
    const char *newFileName = "blurred_image.png";
    unsigned char *newImage;
    unsigned int height = 0, width = 0;
        
    //Decoding Image	
    lodepng_decode32_file(&image, &width, &height, filename);
    newImage = (unsigned char *)malloc(height * width * 4 * sizeof(unsigned char));

    //Declaring gpuImage and setting the value
    unsigned char * gpuImage;
    cudaMalloc( (void**) &gpuImage, sizeof(char) * height*width*4); 
    cudaMemcpy(gpuImage, image, sizeof(char) *  height*width*4, cudaMemcpyHostToDevice);

    //Declaring gpuNewImage 
    unsigned char * gpuNewImage;
    cudaMalloc( (void**) &gpuNewImage, sizeof(char) * height*width*4);

    //Declaring gpuImageWidth and setting the value 
    unsigned int* gpuWidth; 
    cudaMalloc( (void**) &gpuWidth, sizeof(int));
    cudaMemcpy(gpuWidth, &width, sizeof(int), cudaMemcpyHostToDevice);

    struct timespec start, finish;
    long long int time_elapsed;
    clock_gettime(CLOCK_MONOTONIC, &start);

    applyGaussianBlurr<<<height-1,width-1>>>(gpuImage, gpuNewImage, gpuWidth);
    cudaDeviceSynchronize();

    printf("Image width = %d, height = %d\n", width, height);

    clock_gettime(CLOCK_MONOTONIC, &finish);
    time_difference(&start, &finish, &time_elapsed);
    printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, (time_elapsed/1.0e9)); 

    //Getting newImage data from gpu
    cudaMemcpy(newImage, gpuNewImage, sizeof(char) * height * width * 4, cudaMemcpyDeviceToHost);

    //Encoding image 
    lodepng_encode32_file(newFileName, newImage, width, height);
    return 0;
}
