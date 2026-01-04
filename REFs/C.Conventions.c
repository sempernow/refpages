/* FIRST line of comments
 * Greg Kroah-Hartman :: Code Style ...
 *   - Use Tabs [8 char]
 *   - 80 ch line limit
 * cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
 * LAST line of comments
 */

// K & R Style [Java/Linux Style]
if ( 0 == i) {
  foo = 0;
  count++;
}
// Allman Style [Eric Allman]
if ( 0 == i) 
{
  foo = 0;
  count++;
}
// Whitesmiths Style
if ( 0 == i) 
  {
  foo = 0;
  count++;
  }
// GNU Style
if ( 0 == i) 
  {
    foo = 0;
    count++;
  }
  
// Counting up from 0 to n-1
for (i = 0; i < n; i++)
  
// Counting up from 1 to n
for (i = 1; i <= n; i++)
  
// Counting down from n-1 to 0
for (i = n - 1; i >= 0; i--)
  
// Counting down from n to 1
for (i = n; i > 0; i--)

// Infinite Loops
while (1)
for (;;)
	
// null statement, ';', usage
for (d = 2; d < n && n % d !=0; d++)
   ; // empty body
  
	// alternately, use dummy continue
	for (d = 2; d < n && n % d !=0; d++)
	   continue;
	  
	// alternately, use empty compound statement
	for (d = 2; d < n && n % d !=0; d++)
   {} 
				
