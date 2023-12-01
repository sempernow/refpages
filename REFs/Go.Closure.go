// CLOSUREs :: "close" as in "trap"
// PERSISTENCE OF STATE by the variable "closed over" is their hidden magic.
package main

import "fmt"
import "strconv"

func adder() func(int) int {
	sum := 0
	fmt.Println("sum:" + strconv.Itoa(sum))
	return func(x int) int { // closes over `sum`; maintains state; recalled per successive calls
		sum += x // NOT reset; STATE PERSISTs; closure RETURNs FUNCTION as its VALUE
		fmt.Println(" closure @ X:" + strconv.Itoa(x) + "=> sum:" + strconv.Itoa(sum))
		return sum
	}
}

func main() {
	A := adder() // returns FUNCTION [STATEFULly] [its own version]
	B := adder() // returns FUNCTION [STATEFULly] [its own version]
	fmt.Println("A:", A(5), A(2))  // state @ each call preserved: sum[A@call-1]; sum[A@call-2];
	fmt.Println("B:", B(1), B(3))  // state @ each call preserved: sum[B@call-1]; sum[B@call-2];
	//fmt.Println(A,B)
}

/* =>
sum:0
sum:0
 closure @ X:5=> sum:5
 closure @ X:2=> sum:7
A: 5 7
 closure @ X:1=> sum:1
 closure @ X:3=> sum:4
B: 1 4
*/

// CLOSUREs with GOROUTINEs  [closure-binding] 
	// Goroutines may survive beyond a loop iteration, so a separate 
	// instance of loop var is needed for each one; for each iteration.

	// E.g., RANGE over goroutine 
	done := make(chan bool)
	values := []string{"a", "b", "c"}

	// SOLUTION 1: variable shadowing
	for _, v := range values {
		v := v  // shadow the loop var; this inner scope `v` is anew per iteration
		go func() {
			fmt.Printf(v)   // "cab" (sans shadow, prints "ccc")
			done <- true
		}()
	}
	// SOLUTION 2: add `u` arg; pass `v` as param
	for _, v := range values {
		go func(u string) {
			fmt.Printf(u)   // "cab"
			done <- true
		}(v)
	}
