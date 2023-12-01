#include <stdio.h> 

/* C98 comment ['winged comment'] */
		
// C99 comment
	
// C98 all declarations preceed statements;
int main (void) 
{
	declarations
	statements 
}
// not so in C99; declare just before needed
int main (void) 
{
	declarations
	statements 
	
	declarations
	statements 	
	
}

// C99 allows 'universal character names' [UCS] as IDENTIFIERs [variable names]

// C99 added 5 new keywords

		restrict  _Bool		
		inline 	  _Complex
				  _Imaginary

// C99 returns 0 to OS if main returns int
// C98 returns undefined to OS

// C98 has NO boolean type, so programmers often define per macro
#define TRUE 1
#define FALSE 0
// C99 has boolean data type; _Bool; but it's actually an unsigned integer allowed only one of two values, 0 or 1. 
#include<stdbool.h>
// allows declaring & initializing ...
bool flag = true;
// which is equiv to ...
_Bool flag = true;

// C99 :: 1st expression in for loop can declare/initialize var 
for (int i = 0; i < n; i++)
  


