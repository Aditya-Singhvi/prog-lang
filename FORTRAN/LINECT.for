      PROGRAM LINECT
C
C Aditya Singhvi
C ATCS: Programming Languages, Period 3
C Nov 4 2020
C
C Program that counts the number of lines in a text file
C The name of the text file is included in a data statement, 
C with I/O device #15 being used to open the file. 
C
C The file is opened in the main program module, with the 
C number of lines being counted in a subroutine named COUNTL. 
C The number of lines is stored and printed as an 8-byte integer.
C

C 
C PARAMETERS
C
      INTEGER FILEID 
      PARAMETER (FILEID = 15)

C
C LOCAL VARIABLES - NONE
C 

C 
C FUNCTION DECLARATIONS
C 
      INTEGER*8 COUNTL

C
C COMMON VARIABLES - NONE
C 

C
C DATA STATEMENTS
C 
      CHARACTER*12 NAME
      DATA NAME / 'LineFile.txt'/

C
C MAIN PROGRAM MODULE
C
      OPEN(UNIT=FILEID,FILE=NAME, ACTION='READ')
   
      WRITE(*, 5) 'Num Lines: ', COUNTL(FILEID)
    5 FORMAT(A11, I8)

      CLOSE(UNIT=FILEID)

      RETURN
      END    
      

C
C SUBROUTINES - none
C

C
C FUNCTIONS 
C

C ------------------------------------------------------
C Function to count lines in an opened file given the file 
C identifier number (ID)
C
      FUNCTION COUNTL(ID)
      
      INTEGER*8 COUNTL
C
C PARAMETERS - NONE
C

C
C LOCAL VARIABLES
C
      INTEGER ID
      INTEGER*8 N

C
C FUNCTION DECLARATIONS - NONE
C

C
C COMMON VARIABLES - NONE
C

C
C DATA STATEMENTS - NONE
C

C
C FUNCTION MODULE
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
