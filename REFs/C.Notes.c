#include <stdio.h> 

/*
	the above PREPROCESSOR DIRECTIVE references a HEADER file which has information regarding the STANDARD LIBRARY of I/O functions; directive is to INCLUDE, before compiling, whatever LIBRARY FUNCTIONS therein are required by this program.
	
	Directives are ONE LINE long and have NO SEMICOLON.
*/
/*
	"Compiler" does three steps 
	
		- Preprocessing; C Pre-Processor [CPP]
		
			performs commands referenced by "#"; 
			allows conditional, per machine-architecture [#if/#endif];
			MODIFIES the program as necessary.
			
		- Compiling 	
		
			translate [modified] program into object code
			@ gcc.exe http://gcc.gnu.org
			
		- Linking 		
		
			combines object code of program with whatever else is needed per preprocessor directives to yield complete executable program (file).
			ld.exe @ 'binutils pkg' http://www.gnu.org/software/binutils
	
		- ALL 3 in 1 ...
		
			make.exe 		http://www.gnu.org/software/make
		
		Installed Version Info ...
		
			gcc --version
			ld -v 
			make --version
*/
/* C98 comment ['winged comment'] */ 
		
// C99 comment

	// C98 comments CAN'T be nested 

		/*  ... ILLEGAL ...
		
			/*   */
			
		*/

	// compiler converts C98 comment to single whitespace
	a/**/b = 0; // gets compiled to an illegal statement => a b = 0;

// Implementation-Defined Behavior
/*
	The result of some statements are purposefully undefined; 
	to be determined by the build environment; compiler/linker config.
	
	http://stackoverflow.com/questions/2397984/undefined-unspecified-and-implementation-defined-behavior
	https://hackernoon.com/so-you-think-you-know-c-8d4e2cd6f6a6#.28aga695v
*/

/*  TOKENs

    Think of a C statement as a series of tokens;
    keywords, identifiers, constants, operators, and separators;
    so whitespace, tabs, new-line, is irrelevant, unless obscures meaning of a token, e.g., two identifiers, foo bar, concatenated to foobar.
	https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Lexical-Elements
*/

// Integer Constants

	47		// decimal     47
	0x2f	// hexidecimal 47
	057  	// octal       47

	// integer data types; 
	// short, long, signed, or unsigned
	// append identifier[s] to integer ...
	
	45UL // unsigned long

	// Both ISO C99 and GNU C extensions add the integer types long long int and unsigned long long int. 	
	
	45ULL // unsigned long long int constant
	
	// C integer SIZE is machine dependent [16, 32, 64 bit]

/*
	Character Constants; one char, but some require "escape sequence"
	Enclose in single quotes and treat as single char; '\n'
	https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Character-Constants
*/
	// octal is \o, \oo, \ooo  [1-3 digits only]
	
		'\101' 	// octal for 65, which is ASCII for 'A'
	
	// hex is \xh, \xhh, \xhhh, ...
		
		'\x41'  // hex for 65, which is ASCII for 'A'
		
	// Extended ASCII character set has 256 chars
	
// expression 
c > a+b
// statement
int c = a + b;

// L-Value of Expression
/*	
     L-Value stands for left value
     L-Value of Expressions refer to a memory locations
     In any assignment statement L-Value of Expression must be a container
	  (i.e. must have ability to hold the data)
     Variable is the only container in C programming thus L Value must be any Variable.
     L Value Cannot be Constant, Function or any of the available data type in C	
	
*/
/*  POINTERs

    ‘&’ Address Operator
    ‘*’ Indirection Operator
	
	so, *(&n) is just n; it's the value of the address of n
*/

	// Declaring Pointers; white space is not significant
	
	data-type *name;
	
	data-type* name;

	int a = 10;      
	int *ptr = &a;  // address of ptr holds address of a

	// Dereferencing a Pointer ...

	x = *ptr; // which means x = *(&a), which means  x = a

	// Void Pointers aka 'General Purpose Pointer'

		void *ptr;    // ptr is declared as Void pointer

		int inum;
		float fnum;
		char cnum;

		ptr = &inum;  // ptr has address of integer data
		ptr = &fnum;  // ptr has address of float data
		ptr = &cnum;  // ptr has address of character data

		// Dereferencing a Void Pointer
		
		* ( ( data_type * ) void_pointer )
		
			// Example ...
		
			ptr = &inum;  // if void pointer, ptr, is assigned address of INTEGER data
			
			*((int*)ptr)  // then dereference syntax is thus 

			// Similarly we should use following for Character and float –

			*((float*)ptr)  // De-reference Float Value
			*((char*)ptr)   // De-reference Character Value
	
// Function syntax  https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html#Functions
	int
	fooAdder (int x, int y)
	{
	  return x + y;
	}
	
	// OLD syntax is valid; don't use...

	int
	fooAdder (x, y)
		int x, int y;
	{
	  return x + y;
	}


	int main (void) // 'main' function is mandatory; special; CALLED AUTOMATICALLY upon execution.
	{
		// Statement #1; function call
		printf("To C, or not to C: that is the question.\n"); // LITERAL STRING [double-quotes]
		// C has no built-in commands for read or write, 
		// standard library, ref'd @ preprocessor directive, has such LIBRARY FUNCTIONS
		
		// Statement #2; return
		return 0;

		exit (0); // equivalent in main [old way]
	}
	
	// Equivalent ....

	// argc (argument count) and argv (argument vector)
	int main(int argc, char * argv[]) // arg_count, arg_vector
	int main(int argc, char ** argv)  // arg_count, arg_strings

	// parameter 'char * argv[]' decays to a pointer, 'char ** argv'
	
// Append 'f' to float constants that have decimals ..

float profit = 49349.0537f; // else compiler warns

#define INVERSE_PI ( 1.0f / 3.14159f ) // w/out 'f', result is truncated to int

// %f default to 6 decimal places
printf("$%.2f", profit); // $49349.05

// variable NAME & function NAME are called 'identifier'

	// valid IDENTIFIERs 
	times10 _someID foo_bar
	
	// but starting w/ underscore not always allowed by some compilers

	// INvalid IDENTIFIERs
	10times foo-bar
	
	// KEYWORDS are INVALID identifiers
		auto	   double	int
		char	   extern	return
		const	   float	short
		continue  for		signed
		default	   goto		sizeof	
		
		restrict  _Bool				/ C99
		inline 	  _Complex
				  _Imaginary
	
	// C is CASE SENSITIVE
	foo, Foo fOO  // are all different

'x' // SINGLE CHARACTER LITERAL; includes escape-sequence chars; '\n', '\057', ...
"x" // STRING LITERAL containing 'x' and '\0', null terminator (a 2 char ARRAY)

fprintf // writes formatted text to the output stream you specify.
		// outputs to a file handle (FILE*)
sprintf // writes formatted text to an array of char, as opposed to a stream.
		// outputs to a buffer you allocated. (char*)
printf	// is equivalent to writing fprintf(stdout, ...)
		// outputs to the standard output stream (stdout)
		
		// https://www.gnu.org/software/libc/manual/html_node/Formatted-Output-Functions.html#Formatted-Output-Functions
/* 
	STREAMs
	
	In C, a "stream" is an abstraction; from the program's perspective it is simply a producer (input stream) or consumer (output stream) of bytes. It can correspond to a file on disk, to a pipe, to your terminal, or to some other device such as a printer or tty. The FILE type contains information about the stream. Normally, you don't mess with a FILE object's contents directly, you just pass a pointer to it to the various I/O routines.

	There are three standard streams: stdin is a pointer to the standard input stream, stdout is a pointer to the standard output stream, and stderr is a pointer to the standard error output stream. In an interactive session, the three usually refer to your console, although you can redirect them to point to other files or devices:

	$ myprog < inputfile.dat > output.txt 2> errors.txt

	In this example, stdin now points to inputfile.dat, stdout points to output.txt, and stderr points to errors.txt.
	http://stackoverflow.com/questions/4627330/difference-between-fprintf-printf-and-sprintf
*/

//  typedef [idiom] :: allows struct name use without preceding w/ 'struct'

	typedef struct fooStruct fooStruct;
	struct fooStruct {
		/*  ... */
	};
	
	fooStruct 