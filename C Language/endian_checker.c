#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	union {char a[2]; short v;} bob;
        
        bob.v = 1;

	printf("%d, %d\n", (int) bob.a[0], (int) bob.a[1]);

        exit(0);
}