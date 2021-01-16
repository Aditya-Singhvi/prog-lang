      PROGRAM DARRAY
C
C Aditya Singhvi
C November 17, 2020
C
C The DARRAY program dynamically loads an array of 
C integer values given a text file, with each value on 
C a separate line. The mean and standard deviation of 
C the array of integers are calculated and printed. 
C
C The name of the text file is loaded through a data statement
C within the main program block, with IO device #15 being used to 
C load the file. A separate function is used 
C to count the number of lines in the program, with another
C file processing subroutine FILEPR being called after to dynamically 
C allocate space for the array. The array is loaded in another
C subroutine FILELD, with the mean and sample standard deviation   
C calculated within separate functions MEAN and SSDEV. 
C
C The number of elements in the array is stored as an 8-byte INTEGER,
C with the mean and standard deviation returned as REAL values with
C four decimal digits of precision. 
   
C 
C PARAMETERS
C
      INTEGER FILEID 
      PARAMETER (FILEID = 15)

C
C LOCAL VARIABLES
C 
      INTEGER*8 NUML

C 
C FUNCTION DECLARATIONS
C 
      INTEGER*8 COUNTL

C
C DATA STATEMENTS
C 
      CHARACTER*13 NAME
      DATA NAME / 'ArrayFile.txt'/

C
C MAIN PROGRAM MODULE
C
      OPEN(UNIT=FILEID,FILE=NAME, ACTION='READ')

      NUML = COUNTL(FILEID)

      WRITE(*, 5) 'Num Lines: ', NUML
    5 FORMAT(A11, I8)

      CALL FILEPR(FILEID, NUML)

      CLOSE(UNIT=FILEID)

      RETURN
      END    

-------------------------------------------------
C SUBROUTINES 

C
C Subroutine FILEPR, given the unit id INTEGER*4 FILEID for  
C a file and the number of lines in the file INTEGER*8 NUML, 
C calls a subroutine to load an array of INTEGER*4 values 
C from the file, with one integer value per line. The array 
C is then passed to functions to calculate the mean and 
C standard deviation of the data, which are then printed. 
C
C PRECONDITION: File corresponding to FILEID is open and 
C               contains one integer*4 value per line, with
C               NUML lines. 
C 
C POSTCONDITION: The mean and standard deviation of the values
C                in the file have been printed.
C
C ARGS: FILEID, the IO# of the opened file
C        NUML, the number of lines in the file 
C

      SUBROUTINE FILEPR(FILEID, NUML)

C 
C LOCAL VARIABLES
C
      INTEGER FILEID
      INTEGER*8 NUML

      INTEGER*4 DATA(NUML)

      REAL*8 MN
      REAL*8 SD

C
C FUNCTION DECLARATIONS
C
      REAL*8 MEAN
      REAL*8 SSDEV

C
C CODE MODULE
C
      CALL FILELD(FILEID, NUML, DATA)

      WRITE(*, 10) 'FirstElement', DATA(1)
      WRITE(*, 10) 'Last Element', DATA(NUML)

      MN = MEAN(NUML, DATA)
      SD = SSDEV(MN, NUML, DATA)

      WRITE(*, 15) 'Mean: ', MN
   15 FORMAT(A6, F8.4)
      
      WRITE(*, 20) 'Sample StDev: ', SD
   20 FORMAT(A14, F8.4) 
      
      RETURN
   10 FORMAT(A, I4)

      END SUBROUTINE


C------------------------------------------------
C Subroutine FILEID loads the values from open file
C with unit number FILEID and NUML lines into the
C INTEGER*4 DATA array. 
C
C PRECONDITION: File corresponding to FILEID is open and 
C               contains one integer*4 value per line, with
C               NUML lines.
C 
C POSTCONDITION: The integers from the given file have been 
C                loaded into DATA.
C 
C ARGS: FILEID, the IO# of the opened file
C         NUML, the number of lines in the file 
C         DATA, an array of size NUML storing INTEGER*4 values


      SUBROUTINE FILELD(FILEID, NUML, DATA)
C
C LOCAL VARIABLES
C
      INTEGER FILEID
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML)

      INTEGER*8 I
C
C CODE MODULE
C
      DO I = 1, NUML
         READ(FILEID, *) DATA(I)
      END DO

      RETURN
      END SUBROUTINE


C ------------------------------------------------------
C FUNCTIONS

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
C
C LOCAL VARIABLES
C
      INTEGER ID
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

C
C LOCAL VARIABLES
C
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML)

      INTEGER*8 I

C
C CODE MODULE
C
      MEAN = 0

      DO I = 1, NUML
         MEAN = MEAN + REAL(DATA(I))
      END DO

      MEAN = MEAN/REAL(NUML)

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

C
C LOCAL VARIABLES
C
      REAL*8 MN
      INTEGER*8 NUML
      INTEGER*4 DATA(NUML)

      INTEGER*8 I

C
C CODE MODULE
C
      SSDEV = 0

      DO I = 1, NUML
         SSDEV = SSDEV + (REAL(DATA(I)) - MN)**2
      END DO

      SSDEV = SQRT(SSDEV/REAL(NUML - 1))

      RETURN
      END FUNCTION
