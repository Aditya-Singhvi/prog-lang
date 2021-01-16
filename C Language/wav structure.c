/*
 * 
 * Outlines structures used in decoding of .wav files: intro, 
 * subchunk1, subchunk2, and a wav structure that encompasses the
 * other three. 
 *
 * Aditya Singhvi
 * December 11, 2020
 * 
 */
#include <stdio.h>
#include <stdlib.h>

#include "atcs.h"

//Structures 
struct intro 
   {
   LONG chunkID;
   LONG chunkSize;
   LONG format;
   };

struct subchunk1
   {
   LONG id;
   LONG size;
   short audioFormat;
   short numChannels;
   LONG sampleRate;
   LONG byteRate;
   short blockAlign;
   short bitsPerSample;
   };

struct subchunk2
   {
   LONG id;
   LONG size;
   char data[1];
   };

struct wav
   {
   struct intro riff;
   struct subchunk1 fmt;
   struct subchunk2 data;
   };

//Function Declarations
int main(int argc, char* argv[]);

/**
* The main entry function.
* 
* Verifies accurate declaration of 4 wav file structures by printing size of each.
* Overall size should be 48 bytes, with 12 for the intro, 24 for subchunk1, and 12 for subchunk2.
* 
* Arguments are accepted but not used at this time.
* Always exits with code zero. 
*/
int main(int argc, char* argv[])
   {
   printf("\nSize Wav: %lu; \nSize Intro: %lu;\n", sizeof(struct wav), sizeof(struct intro));
   printf("Size Sub1: %lu; \nSize Sub2: %lu;\n", sizeof(struct subchunk1), sizeof(struct subchunk2));
   exit(0);
   }
