/*
 * Provides methods to process and filter .wav audio files, including reversing the file and
 * changing its speed. Called with an input filename, an output filename, and a filter, the code will
 * make the modifications on the input file and copy the resulting .wav file to the output file.
 *
 * RUNNING THE CODE:
 * 
 * The first argument when the code is run represents the input file name. If no arguments are given, the
 * default filename of WELCOME8.wav will be used. Similarly, if a single dash (-) is used in place of the
 * argument, that same default filename will be used.
 *
 * The second argument represents the output file name. If no second argument exists (or the argument simply
 * consists of a single dash -), the prefix "OUT_" will be appended to the front of the input file name and that
 * will be used. If the file already exists, it will be overwritten. If not, a new file with the name will be 
 * created.
 *
 * The third argument represents the filter to be used. Any string beginning with 'S' (case-independent) will 
 * represent changing the sample rate (speed). Any string beginning with 'R' (case-independent) will 
 * represent reversing the wav file. Any other third argument (or none at all) will lead to the input file being
 * copied over onto the output file. 
 *
 * The fourth argument will only be relevant if the Sample Rate filter is selected. In that case, this argument 
 * will be a floating-point positive numerical value representing the factor by which the sample rate is to be 
 * changed. For instance, "2.0" would represent the file being played at twice its normal speed, while "0.5" would
 * represent the file being slowed down to half its current speed. This argument will be ignored for any other filter.
 *
 * NOTE: Some wav files are structured slightly differently from the specification within this program, with another subchunk 
 *       appearing before the data subchunk that contains additional information about the file. In this case, the reverse 
 *        filter will not work as intended.
 *
 * This project is part of the ATCS: Programming Languages class at The Harker School with Dr. Eric Nelson in Fall 2020.
 *
 * Aditya Singhvi
 * January 4, 2021
 * 
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h> 
#include <sys/stat.h> 
#include <sys/types.h>
#include <string.h>

#include "atcs.h"

//manifest constants
#define DEFAULT_INPUT_FILE "WELCOME8.wav"
#define DEFAULT_OUTPUT_PREFIX "OUT_"

//Unions
union longToString {char arr[4]; LONG val;};

//Structures 
struct intro 
   {
   union longToString chunkID;
   LONG chunkSize;
   union longToString format;
   };

struct subchunk1
   {
   union longToString id;
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
   union longToString id;
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
LONG getFileLength(int fileHandle);
void *createFilePointer(char *filename);
void printWavStruct(struct wav *wavPointer);
void changeSampleRate(struct wav *wavPointer, float coeff);
void reverseData(struct wav *wavPointer);
void writeToFile(struct wav *wavPointer, char *filename);
int main(int argc, char *argv[]);


/**
* --------------FUNCTION BODIES BEGIN HERE----------------------------
*
* Given a file handle for an already-opened file with reading enabled, function 
* getFileLength() returns the length of the file in bytes as a LONG (defined in atcs.h 
* as a four-byte int). Does not change the position of seek-arm. 
* 
* PARAMS: 
*  fileHandle, the handle of the already-opened file which must be able to be read
*
* RETURN: 
*  The length of the file as a LONG (4-byte int)
*/ 
LONG getFileLength(int fileHandle)
   {
   LONG fileLength;  
   int currentPos;    

   currentPos = lseek(fileHandle, (size_t)0, SEEK_CUR);  // Stores the current position of the seek-arm

   lseek(fileHandle, (size_t)0, SEEK_SET);   //Sets seek-arm to the beginning of the file
   fileLength = lseek(fileHandle, (size_t)0, SEEK_END);  // Number of bytes read to the end is the length
   lseek(fileHandle, currentPos, SEEK_SET);  //Restores seek-arm to previous position

   return fileLength;
   }


/**
* Given a valid file name, reads the file and creates and returns a pointer to memory 
* storing the contents of the file. If the file name is not valid, returns NULL and prints
* error message. 
* 
* PARAMS: 
*  filename, the name of the file to be read 
* 
* RETURNS:
*  pointer of type void to contents of file in memory
*/ 
void *createFilePointer(char *filename)
   {
   int fileHandle;
   LONG fileLength;
   void *filePointer;

   int readCheck; //stores number of bytes read to be printed 

   fileHandle = open(filename, O_RDONLY);
   if (fileHandle != -1)
      {
      fileLength = getFileLength(fileHandle);
      filePointer = malloc(fileLength);
      
      readCheck = read(fileHandle, filePointer, fileLength);
      printf("Reading in File %s\n", filename);
      printf("File Length: %d\tBytes Read: %d\n", fileLength, readCheck);
      
      close(fileHandle);
      }
   else
      {
      printf("Error %d while creating File %s\n", errno, filename);
      filePointer = NULL;
      }
      
   return filePointer;
   }


/**
* A function, giving a pointer of a struct of type wav, prints the contents
* of the memory with the appropriate labels. Does not print any of the actual 
* wav file data. 
* 
* NOTE: The struct (and the program as a whole) ignores the possibility of the 
* second subchunk containing additional information about the wav file and 
* assumes it contains the sound data. 
*
* PARAMS: 
*  wavPointer, a pointer of type struct wav to where the contents of the wav file
*              are stored.
* 
*/ 
void printWavStruct(struct wav *wavPointer)
   {
   printf("\nPrinting Intro:\n");
   printf("ChunkID: %.4s\n", (*wavPointer).riff.chunkID.arr);
   printf("ChunkSize: %d\n", (*wavPointer).riff.chunkSize);
   printf("Format: %.4s\n", (*wavPointer).riff.format.arr);

   printf("\nPrinting Subchunk 1:\n");
   printf("SC1_ID: %.4s\n", (*wavPointer).fmt.id.arr);
   printf("SC1_Size: %d\n", (*wavPointer).fmt.size);
   printf("AudioFormat: %d\n", (*wavPointer).fmt.audioFormat);
   printf("NumChannels: %d\n", (*wavPointer).fmt.numChannels);
   printf("SampleRate: %d\n", (*wavPointer).fmt.sampleRate);
   printf("ByteRate: %d\n", (*wavPointer).fmt.byteRate);
   printf("BlockAlign: %d\n",(*wavPointer).fmt.blockAlign);
   printf("BitsPerSample: %d\n", (*wavPointer).fmt.bitsPerSample);

   printf("\nPrinting Subchunk 2:\n");
   printf("SC2_ID: %.4s\n", (*wavPointer).data.id.arr);
   printf("SC2_Size: %d\n", (*wavPointer).data.size);
   //printf("Data: %s\n", (*wavPointer).data.data);
   return;
   }


/**
* Given a pointer to a struct of type wav containing the contents of a wav file and a 
* floating-point coefficient, modifies the sample rate (and, consequently, the byte rate) 
* stored in memory by multiplying it by the coefficient. The sample rate of a wav file specifies 
* its speed. 
*  
* PARAMS:
*  wavPointer: a pointer of type struct wav to where the contents of the wav file
*              are stored.
*  coeff: the coefficient that the sample rate is to be multiplied by.
*         must be a positive floating-point number. Numbers less than 1 will
*         decrease the speed, while greater will increase the speed. 
*/
void changeSampleRate(struct wav *wavPointer, float coeff)
   {
   (*wavPointer).fmt.sampleRate = (LONG) (coeff * ((float) (*wavPointer).fmt.sampleRate)); 
   (*wavPointer).fmt.byteRate = (LONG) (coeff * ((float) (*wavPointer).fmt.byteRate)); 
   return;
   }

/**
* Given a pointer to a struct of type wav containing the contents of a wav file, reverses 
* the order of the sound data stored in memory block-by-block, maintaining the channels.
*
* Reverses the data by repeatedly swapping blocks from the start and the end. 
*
* PARAMS:
*  wavPointer: a pointer of type struct wav to where the contents of the wav file
*              are stored.
*/
void reverseData(struct wav *wavPointer)
   {
   int blockSize;
   int dataSize;
   int startPos1; //start from beginning
   int startPos2; //start from end

   int i;

   char temp; //for swaps

   blockSize = (*wavPointer).fmt.blockAlign;
   dataSize = (*wavPointer).data.size;

   for(startPos1 = 0; startPos1 < dataSize/2; startPos1 += blockSize) //iterates through first half of data
      {
      startPos2 = dataSize - startPos1 - blockSize;   

      for(i = 0; i < blockSize; i++) //maintains order of each data block
         {
         temp = (*wavPointer).data.data[startPos1 + i];
         (*wavPointer).data.data[startPos1 + i] = (*wavPointer).data.data[startPos2 + i];
         (*wavPointer).data.data[startPos2 + i] = temp;
         }
      }
   return;
   }

/**
* Given a pointer to a struct of type wav wavPointer and an output filename, 
* writes the contents of the memory at wavPointer to the given file. If the file
* does not already exist, a new file will be created. If it does exist, its contents
* will be overwritten. 
*
* PARAMS:
*  wavPointer: a pointer of type struct wav to where the contents of the wav file
*              are stored.
*  filename: char * to the name of the output file to be written to 
*/
void writeToFile(struct wav *wavPointer, char *filename)
   {
   int existCheck;   //store int indicating if file exists
   int fileHandle;

   int writeCheck;   //store number of bytes read

   existCheck = open(filename, O_EXCL); //set to -1 if file already exists, fine otherwise
   //DEBUG printf("exist check: %d\n", existCheck);
   
   if (existCheck == -1) //File does not exist
      {
      fileHandle = open(filename, O_RDWR | O_CREAT | O_EXCL, S_IWRITE | S_IREAD);
      printf("\nNew file %s created.\n", filename);
      }
   else  //File already exists
      {
      fileHandle = open(filename, O_RDWR | O_CREAT | O_TRUNC);
      printf("\nFile %s already exists. Its contents will be overwritten.\n", filename);
      }

   if (fileHandle != -1) //File created properly
      {
      writeCheck = write(fileHandle, wavPointer, (*wavPointer).riff.chunkSize + sizeof((*wavPointer).riff.chunkID));
      printf("%d Bytes written to file %s;\n", writeCheck, filename);
      close(fileHandle);
      }
   else
      printf("Error %d while creating File %s\n", errno, filename);
   
   return;
   }

/**
* The main entry function.
* 
* Reads in given file, performs filter (none, changing sample rate, or reversing), 
* and copies modified output to output file. Prints info about input file as it reads.
* 
* PARAMS: See top-level comment for details on each argument and behavior
*  argc, the number of arguments
*  argv, the array of arguments
*     pos 0: input file name, defaults to WELCOME8.wav if blank or dash (-)
*     pos 1: output file name, defaults "OUT_" + inputFileName if blank or dash (-)
*     pos 2: filter name. 
*        Starts with S --> Sample Rate (Speed)
*        Starts with R --> Reverse 
*        Otherwise, no filter applied before copying file
*     pos 3: Only used if Sample Rate filter used, specifying positive float coefficient. 
*
* RETURNS:
*  Always exits with code zero. 
*/
int main(int argc, char *argv[])
   {
   int fileHandle;
   void *filePointer;

   /*
   * Set to filter number when processing user arguments
   * 0: no filter
   * 1: Sample Rate
   * 2: Reverse
   */
   int filterNumber; 
   const int noFilter = 0;
   const int sampleFilter = 1;
   const int reverseFilter = 2;

   float rateCoefficient;
   const float defaultRateCoefficient = 2.0;

   char *inputFilename;
   char *outputFilename;

   struct wav *wavPointer;

   //THIS FOLLOWING SECTION HANDLES THE USER ARGUMENTS WHEN MAIN IS CALLED

   //Handles input file name
   if (argc > 1 && strcmp(argv[1], "-") != 0)   //Argument neither blank nor a dash
      inputFilename = argv[1];
   else
      {
      inputFilename = DEFAULT_INPUT_FILE;
      }
    printf("\nInput Filename set to filename %s\n", inputFilename);

   //Handles output file name
   if (argc > 2 && strcmp(argv[2], "-") != 0) //Argument neither blank nor a dash
      outputFilename = argv[2];
   else
      {
      outputFilename = malloc(strlen(DEFAULT_OUTPUT_PREFIX) + strlen(inputFilename) + 1); //extra 1 needed for string termination char /0

      outputFilename = strcat(outputFilename, DEFAULT_OUTPUT_PREFIX);
      outputFilename = strcat(outputFilename, inputFilename);
      }
   printf("Output Filename set to filename %s\n", outputFilename);

   //Name of filter
   if (argc > 3 && (argv[3][0] == 's' || argv[3][0] == 'S')) //Sample Rate Filter
      {
      filterNumber = sampleFilter;  

      rateCoefficient = defaultRateCoefficient; //default val
      if (argc > 4) 
         {
         rateCoefficient = strtof(argv[4], NULL);
         }
      printf("The sample rate of file %s will be changed by a factor of %f and output to %s\n", inputFilename, rateCoefficient, outputFilename);
      }
   else if (argc > 3 && (argv[3][0] == 'r' || argv[3][0] == 'R')) //Reverse Filter
      {
      filterNumber = reverseFilter;
      printf("File %s will be reversed, with the output in %s.\n", inputFilename, outputFilename);
      } 
   else
      {
      filterNumber = noFilter;
      printf("No filter will be used on %s. It shall simply be copied over to %s.\n", inputFilename, outputFilename);
      }
   
   //Open file and load into memory
   fileHandle = open(inputFilename, O_RDONLY);
   filePointer = createFilePointer(inputFilename);

   if (filePointer != NULL) //File pointer must be valid for code to proceed
   {
      printf("\nInput file %s read and returned valid file pointer\n", inputFilename);

      wavPointer = (struct wav *) filePointer;

      printf("\nPrinting contents of input .wav file:\n");
      printWavStruct(wavPointer); 

      switch(filterNumber) //Switch-case depending on which filter.
         {
         case sampleFilter:
            changeSampleRate(wavPointer, rateCoefficient);
            break;

         case reverseFilter: 
            reverseData(wavPointer);
            break;
         } 

      writeToFile(wavPointer, outputFilename);
      free(wavPointer);
   }
   else
      printf("Invalid File Pointer Returned\n");
   
   exit(0);
   }
