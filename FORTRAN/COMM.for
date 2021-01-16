      PROGRAM COMM
C
C Aditya Singhvi
C Dec 7, 2020
C
C The COMM program creates a histogram of INTEGER*4 values on
C being given a text file containing two values per line: an 
C INTEGER*8 value followed by an INTEGER*4 value, separated by
C a space. 
C
C The number of "bins" (divisions) in the histogram
C is retrieved from user input, while the name of the file is
C loaded through a data statement in the main program block. 
C IO device #15 is used to load the file. 
C
C The file is opened within the main program module.
C The number of lines in the file is first counted by calling 
C function COUNTL from the main program module. Control is then passed to 
C Subroutine FILEPR, called with the result of COUNTL and the FILEID.
C
C FILEPR processes the file, creating two arrays to store both the 8-byte
C and the 4-byte integer values from the file. The values are loaded into
C these arrays by calling subroutine FILELD. The minimum and maximum values
C of the INTEGER*4 dataset is calculated with subroutine MINMAX and printed,
C at which point the user is asked to input a positive integer number of bins. 
C If the number of bins input is not an integer, the program will throw an 
C error. If the number is a negative integer, the program will run but not
C produce any output. 
C 
C After the number of bins is received, control is passed to subroutine HISTAL, 
C given the number of elements, the array of the INTEGER*4 values, the min value,
C the max value, and the number of bins. HISTAL allocates space for the histogram 
C array HARRAY of size BINS, after which it calls HISTLD to load the array with 
C the appropriate frequency values. The range MIN to MAX is divided into the
C specified number of bins, each equally sized. Each value in the INTEGER*4 dataset
C is sorted into one of these bins, increasing the count of values in that bin. 
C
C After HISTLD finishes loading the histogram array, HISTPR is called from HISTAL 
C to print the contents of the histogram array, including bin numbers, the minimum
C and maximum values for each bin, and the count of values in each bin. 
C
C The INTEGER*8 and INTEGER*4 arrays for the original data can hold as many elements
C as the maximum INTEGER*8 value. The INTEGER*8 histogram array can hold up to 
C the maximum INTEGER*4 value. The number of bins specified must fit inside a 4-byte
C integer. 

C 
C PARAMETERS
C
      INTEGER FILEID 
      PARAMETER (FILEID = 15)

C
C LOCAL VARIABLES
C 
      INTEGER*8 NUML
      CHARACTER*128 NAMEIN

C 
C FUNCTION DECLARATIONS
C 
      INTEGER*8 COUNTL

C
C COMMON DECLARATIONS
C
      REAL*8 CMEAN, CSTDEV
      INTEGER*4 CMIN, CMAX 

      COMMON /STATS/CMEAN, CSTDEV, CMIN, CMAX

C
C DATA STATEMENTS
C 
      CHARACTER*128 NAME
      DATA NAME / 'sample_data.txt'/

C
C MAIN PROGRAM MODULE
C
      CALL ZEROST()

      WRITE(*, 6) 'Current Data File:', NAME
    6 FORMAT(A, A)

      WRITE(*, 7) 'Enter new file name or enter N/A:'
        
      READ(*, 7) NAMEIN

      IF(NAMEIN(1:3) /= 'N/A') THEN
         NAME = NAMEIN
      END IF

      OPEN(UNIT=FILEID,FILE=NAME, ACTION='READ')

      NUML = COUNTL(FILEID)

      WRITE(*, 5) 'Num Lines: ', NUML
    5 FORMAT(A11, I8)
    7 FORMAT(A, A)

      CALL FILEPR(FILEID, NUML)

      CLOSE(UNIT=FILEID)

      RETURN
      END    



CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C 
C SUBROUTINES 
C


C Subroutine FILEPR, given the unit id INTEGER*4 FILEID for  
C a file and the number of lines in the file INTEGER*8 NUML, 
C calls subroutine FILELD to load two arrays of INTEGER*8 and 
C INTEGER*4 values from the file, with one pair of values 
C separated by whitespace per line. The minimum and maximum 
C values for the INTEGER*4 array are found using subroutine 
C MINMAX and printed. FILEPR passes control to HISTAL, which
C then creates a histogram with the INTEGER*4 data. 
C
C PRECONDITION: File corresponding to FILEID is open and 
C               contains two integers per line with
C               NUML lines. The first is an INTEGER*8 and the
C               second an INTEGER*4. 
C 
C POSTCONDITION: The first and last elements of the two arrays 
C                and the minimum and maximum values of the 
C                INTEGER*4 array have been printed. The user 
C                input for the number of bins has been collected.  
C
C ARGS: FILEID, the IO# of the opened file
C       NUML, the number of lines in the file 
C

      SUBROUTINE FILEPR(FILEID, NUML)
      INTEGER FILEID
      INTEGER*8 NUML

C
C LOCAL VARIABLES
C
      INTEGER*8 DATA8(NUML)
      INTEGER*4 DATA4(NUML)

      INTEGER*4 BINS
      
C
C FUNCTION DECLARATIONS
C
      REAL*8 MEAN
      REAL*8 SSDEV

C
C COMMON DECLARATIONS
C
      REAL*8 CMEAN, CSTDEV
      INTEGER*4 CMIN, CMAX 

      COMMON /STATS/CMEAN, CSTDEV, CMIN, CMAX

C
C CODE MODULE
C
      CALL FILELD(FILEID, NUML, DATA8, DATA4)

      WRITE(*, 10) 'First Element:', DATA8(1), DATA4(1)
      WRITE(*, 10) 'Last Element: ', DATA8(NUML), DATA4(NUML)

      CALL MINMAX(NUML, DATA4)
      WRITE(*, 15) 'MIN: ', CMIN
      WRITE(*, 15) 'MAX: ', CMAX

      CMEAN = MEAN(NUML, DATA4) 
      CSTDEV = SSDEV(CMEAN, NUML, DATA4) 

      WRITE(*, 20) 'MEAN:        ', CMEAN
      WRITE(*, 20) 'SAMPLE STDEV:', CSTDEV

      WRITE(*, 8) 'ENTER Number Of Bins. Suggested: ', (CMAX - CMIN + 1)
    8 FORMAT(A, I5)

      READ(*, *) BINS

      CALL HISTAL(NUML, DATA4, BINS)

      RETURN
   10 FORMAT(A, I12, I4)
   15 FORMAT(A, I12)
   20 FORMAT(A, F10.2)
 
      END SUBROUTINE


C------------------------------------------------
C Subroutine FILELD loads the values from open file
C with unit number FILEID and NUML lines into the
C INTEGER*8 and INTEGER*4 DATA8 and DATA4 arrays. 
C
C PRECONDITION: File corresponding to FILEID is open and 
C               contains two integers per line, with
C               an INTEGER*8 followed by an INTEGER*4 value.
C               NUML total lines. 
C 
C POSTCONDITION: The integers from the given file have been 
C                loaded into DATA.
C 
C ARGS: FILEID, the IO# of the opened file
C       NUML, the number of lines in the file 
C       DATA8, an array of size NUML storing INTEGER*8 values
C       DATA4, an array of size NUML storing INTEGER*4 values


      SUBROUTINE FILELD(FILEID, NUML, DATA8, DATA4)
      INTEGER FILEID
      INTEGER*8 NUML
      INTEGER*8 DATA8(NUML)
      INTEGER*4 DATA4(NUML)

C
C  LOCAL VARIABLES
C
      INTEGER*8 I

C
C  CODE MODULE
C
      DO I = 1, NUML
         READ(FILEID, *) DATA8(I), DATA4(I)
      END DO

      RETURN
      END SUBROUTINE



C-----------------------------------------------
C Subroutine MINMAX calculates the minimum and maximum values
C of an array DATA of INTEGER*4 values of length NUML. The 
C INTEGER*4 variables CMIN and CMAX are common variables 
C modified during the subroutine.
C 
C PRECONDITION: DATA is loaded with NUML INTEGER*4 values.
C
C POSTCONDIION: MIN, MAX have been set to the minimum and 
C               maximum values, respectively, appearing in array
C               DATA.
C
C ARGS: NUML, INTEGER*8 representing number of data values
C       DATA, array of INTEGER*4 values of size NUML
C
      SUBROUTINE MINMAX(NUML, DATA)
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML) 

C
C LOCAL VARIABLES
C
      INTEGER*8 I 

C
C COMMON DECLARATIONS
C
      REAL*8 CMEAN, CSTDEV
      INTEGER*4 CMIN, CMAX 

      COMMON /STATS/CMEAN, CSTDEV, CMIN, CMAX

C
C CODE MODULE
C 
      CMIN = DATA(1)
      CMAX = DATA(1)

      DO I = 2, NUML
         IF (DATA(I) < CMIN) THEN
            CMIN = DATA(I)
         END IF  

         IF (DATA(I) > CMAX) THEN
            CMAX = DATA(I)
         END IF 
      END DO

      RETURN
      END SUBROUTINE



C-----------------------------------------------
C Subroutine HISTAL handles the allocation of a histogram 
C array and loads and prints it using subroutines. Given an 
C array DATA of INTEGER*4 values of length NUML, and the number of 
C divisions BINS (INTEGER*4) in the histogram, will allocate an INTEGER*8 array
C HARRAY to store the histogram values. Each bin, which will be of 
C equal size, will keep track of how many values in data fall into 
C the specified range.
C
C PRECONDITION: DATA contains NUML INTEGER*4 values.
C               CMIN, CMAX contain the minimum and maximum values, respectively,
C               contained in DATA.
C               BINS is a positive INTEGER*4 value.
C
C POSTCONDITION: An array of INTEGER*8 values of size BINS has been 
C                allocated and loaded with the count of how many values
C                in DATA appear in each range of values, with each division 
C                of equal size and bins going from MIN to MAX.  
C  
C ARGS: NUML, an INTEGER*8 representing number of data values
C       DATA, the data array of INTEGER*4 values of size NUML
C       BINS, the number of bins to be allocated in the histogram.
C             Must be a positive INTEGER*4 value.
C
      SUBROUTINE HISTAL(NUML, DATA, BINS)
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML)
      INTEGER*4 BINS

C
C LOCAL VARIABLES
C
      INTEGER*8 HARRAY(BINS)

C
C CODE MODULE
C
      CALL HISTLD(NUML, DATA, BINS, HARRAY) 

      CALL HISTPR(BINS, HARRAY)

      RETURN 
      END SUBROUTINE



C-----------------------------------------------
C Subroutine HISTLD loads the given histogram array HARRAY of
C size BINS with the count of the number of values in given array 
C DATA of INTEGER*4 values of size NUML. Using the given MIN and MAX 
C values, which represent the minimum and maximum values appearing in 
C DATA, the range is divided into BIN equally sized divisions; the count
C of how many of values in DATA fall into each bin is calculated and 
C stored in HARRAY.
C
C PRECONDITION: DATA is filled with NUML INTEGER*4 values. 
C               CMIN, CMAX represent the minimum and maximum values
C               appearing in DATA.
C               HARRAY is an array of INTEGER*8 values of size BINS, 
C               an INTEGER*4. 
C               BINS is a positive integer. 
C
C POSTCONDITION: HARRAY has been loaded with the count of how many values in 
C                data appear in each bin, as defined above. 
C
C ARGS: NUML, INTEGER*8 representing number of data values.
C       DATA, array of size NUML containing INTEGER*4 values.
C       BINS, INTEGER*4 representing the number of bins in the histogram.  
C       HARRAY, allocated array of INTEGER*8 values of size BINS. 
C
      SUBROUTINE HISTLD(NUML, DATA, BINS, HARRAY)
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML)
      INTEGER*4 BINS
      INTEGER*8 HARRAY(BINS)

C
C LOCAL VARIABLES
C
      INTEGER*4 I
      INTEGER*8 J

C
C COMMON DECLARATIONS
C
      REAL*8 CMEAN, CSTDEV
      INTEGER*4 CMIN, CMAX 

      COMMON /STATS/CMEAN, CSTDEV, CMIN, CMAX

C
C CODE MODULE
C
      DO I = 1, BINS
         HARRAY(I) = 0
      END DO

      DO J = 1, NUML
         I = (((DATA(J) - CMIN) * BINS) / (CMAX - CMIN + 1)) + 1
         HARRAY(I) = HARRAY(I) + 1
      END DO

      RETURN 
      END SUBROUTINE



C-----------------------------------------------
C Subroutine HISTPR prints the values in HARRAY, along with the
C range that each frequency value corresponds to and the bin number.
C
C PRECONDITION: CMIN, CMAX represent the minimum and maximum values of 
C               the original data array. This represents the original range.
C               HARRAY has been loaded with the appropriate counts, as defined 
C               in subroutine HISTAL and HISTLD. 
C
C POSTCONDITION: The values contained in HARRAY have been printed along with
C                the range (min and max) for each bin and the bin numbers. 
C 
C ARGS: BINS, the number of bins in the data. Type INTEGER*4. 
C       HARRAY, an array containing INTEGER*8 values of size BINS.  
C
      SUBROUTINE HISTPR(BINS, HARRAY)
      INTEGER*4 BINS
      INTEGER*8 HARRAY(BINS)
C
C LOCAL VARIABLES
C
      INTEGER*4 I

      REAL*8 FACTOR
      REAL*8 MINBIN
      REAL*8 MAXBIN

C
C COMMON DECLARATIONS
C
      REAL*8 CMEAN, CSTDEV
      INTEGER*4 CMIN, CMAX 

      COMMON /STATS/CMEAN, CSTDEV, CMIN, CMAX

C
C CODE MODULE
C
      WRITE(*, 30) '    BIN#  ', '  MIN <= ', '    < MAX','      FREQ'
   30 FORMAT(A, A, A ,A) 
 

      FACTOR = DBLE(CMAX - CMIN + 1) / DBLE(BINS)

      DO I = 1, BINS
         MINBIN = DBLE(CMIN) + DBLE(I - 1) * FACTOR 
         MAXBIN = MINBIN + FACTOR
         WRITE(*, 35) I, MINBIN, MAXBIN, HARRAY(I)
   35    FORMAT(I8, F10.2, F10.2, I12)  
      END DO

      RETURN
      END SUBROUTINE 

C----------------------------------------------------------------
C Subroutine ZEROST initializes COMMON variables CMEAN, 
C CSTDEV, CMIN, CMAX to zero using an EQUIVALENCE statement with
C an array of zeroes. 
C
C POSTCONDITION: Common variables CMEAN, CSTDEV, CMIN, CMAX all
C                have value 0.
C
      SUBROUTINE ZEROST()

C
C PARAMETERS
C
      INTEGER ZSIZE 
      PARAMETER (ZSIZE = 3)


C
C LOCAL VARIABLES
C
      REAL*8 ZERO(ZSIZE)

C
C COMMON DECLARATIONS
C
      REAL*8 CMEAN, CSTDEV
      INTEGER*4 CMIN, CMAX 

      COMMON /STATS/CMEAN, CSTDEV, CMIN, CMAX

C
C CODE MODULE
C
            
      EQUIVALENCE(CMEAN, ZERO)

      DO 200 I=1,ZSIZE
         ZERO(I) = 0.0D0
  200 CONTINUE 

      END SUBROUTINE

C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C 
C FUNCTIONS
C

C 
C Function COUNTL counts lines in an opened file given the file 
C identifier number (ID). 
C
C PRECONDITION: File corresponding to ID is already open
C 
C ARGS: ID, the file identifier number of the file
C
C RETURN: the number of lines in the file as an INTEGER*8 value
C
      FUNCTION COUNTL(ID)
      INTEGER*8 COUNTL
      INTEGER ID

C
C LOCAL VARIABLES
C
      INTEGER*8 N

C
C CODE MODULE
C
      REWIND(UNIT=ID)

      N = 0

  100 READ(ID, *, END=200)
         N = N + 1
      GOTO 100

  200 COUNTL = N
      REWIND(UNIT=ID)

      RETURN
      END    

C -----------------------------------------------------
C Function MEAN calculates and returns the mean of an array 
C DATA of NUML INTEGER*4 values as a REAL. 
C
C PRECONDITION: DATA is an array loaded with NUML INTEGER*4 values.
C
C POSTCONDITION: The mean of the NUML values has been calculated and
C                returned.
C
C ARGS: NUML, the number of elements in the array as INTEGER*8
C       DATA, the array containing the INTEGER*4 values of size NUML
C               
      FUNCTION MEAN(NUML, DATA)
      REAL*8 MEAN
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML)

C
C LOCAL VARIABLES
C
      INTEGER*8 I

C
C CODE MODULE
C
      MEAN = 0.0D0

      DO I = 1, NUML
         MEAN = MEAN + DBLE(DATA(I))
      END DO

      MEAN = MEAN/DBLE(NUML)

      RETURN
      END FUNCTION

C-----------------------------------------------------
C Function SSDEV calculates the sample standard deviation 
C of an array DATA of NUML INTEGER*4 values, given the mean
C MN. 
C
C PRECONDITION: DATA is an array loaded with NUML INTEGER*4 values.
C
C POSTCONDITION: The sample standard dev of the NUML values has 
C                been calculated and returned.
C
C ARGS: MN, the mean of the elements in the array as a REAL
C       NUML, the number of elements in the array as INTEGER*8
C       DATA, the array containing the INTEGER*4 values of size NUML
C               

      FUNCTION SSDEV(MN, NUML, DATA)
      REAL*8 SSDEV
      REAL*8 MN
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML)

C
C LOCAL VARIABLES
C
      INTEGER*8 I

C
C CODE MODULE
C
      SSDEV = 0.0D0

      DO I = 1, NUML
         SSDEV = SSDEV + (DBLE(DATA(I)) - MN)**2.0
      END DO

      SSDEV = DSQRT(SSDEV/DBLE(NUML - 1))

      RETURN
      END FUNCTION

     



