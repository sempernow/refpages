// Stringers
// https://tour.golang.org/methods/18
// http://127.0.0.1:3999/methods/18

package main

import "fmt"

/*
	Stringer INTERFACE is @ "fmt" package  https://golang.org/pkg/fmt/#Stringer
	It is implemented by any value having a `String` method, which defines the “native” format for that value. The `String` method is used to print values passed as an operand to any format that accepts a string or to an unformatted printer such as Print.
*/
type Stringer interface {
	String() string
}

/*
If `String` renamed [everywhere], then it still binds
to IPAddr type,, but does nothing. Same effect as simply
removing the "TODO" method.
*/

// define a custom type; IPAddr
type IPAddr [4]byte // 4 element array of bytes

// TODO: Add a `String` method to IPAddr. DONE; this was the exercise:
func (ip IPAddr) String() string {
	return fmt.Sprintf("%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3])
}

// Stringer interface is bound to IPAddr through invocation of String method
func main() {
	hosts := map[string]IPAddr{ // map string to IPAddr [types]
		"loopback":  {127, 0, 0, 1},
		"googleDNS": {8, 8, 8, 8},
	}
	// note `val` is `ip`, but name is irrelevent; scoped to loop; NOT what binds interface
	for name, val := range hosts {
		fmt.Printf("%v: %v\n", name, val)
	}
}

// // sans Interface
// loopback: [127 0 0 1]
// googleDNS: [8 8 8 8]

// // with Interface
// loopback: 127.0.0.1
// googleDNS: 8.8.8.8
