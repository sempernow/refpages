// Interfaces are implemented implicitly, per TYPE
// https://tour.golang.org/methods/10
// http://127.0.0.1:3999/methods/10

package main

import "fmt"

// The METHOD SET of Interface type is its interface

type I interface { // abstract TYPE
	M() // method SIGNATURE (`I` may contain multiple mthods)
}

type T1 struct {
	S string
}

type T2 struct {
	N int
}

// Types T1,T2 IMPLEMENT interface I by implementing its method M.
// RECEIVER r is passed to M as its (concrete a.k.a. dynamic) type.
func (r T1) M() {
	fmt.Println(r.S)
}
func (r T2) M() {
	fmt.Println(r.N)
}

// The different UNDERLYING (concrete) types, T1 and T2,
// are ALSO of ABSTRACT type I because they both implement M(),
// thus SATISFYing the interface (I).

// POLYMORPHISM
// All types implementing I can be handled by ONE function, P(), taking param of type I.
// P() calls a different M() depending on underlying type of `t` (M's receiver).
func P(t I) {
	t.M()
}

func main() {
	// i1, i2 have same (abstract) interface type
	// but differing (underlying) concrete types
	var i1 I = T1{"hello"}
	var i2 I = T2{44}
	// EQUIVALENT declaration; no explicit reference required
	//i1 := T1{"hello"}
	//i2 := T2{44}

	fmt.Println(" === per method ix.M()")
	i1.M() //=> hello
	i2.M() //=> 44

	// POLYMORPHISM :: THIS makes interfaces useful.
	fmt.Println(" === per func P(ix)")
	P(i1) //=> hello
	P(i2) //=> 44

	// LITERAL of INTERFACE TYPE
	iz := []I{
		T1{"hello"},
		T2{44},
	}
	fmt.Println(" === per []I{T1{},T2{}}  (Interface Literal)")
	for _, x := range iz {
		x.M()
	}

}

// LINGO
/*
	A bit weird; a type "satisfies" an interface by "implementing" its method(s). That's like saying/understanding "A mountain satisfies nature by implementing gravity". I rather think of types as nouns, and methods (functions) as verbs, and so would rather say/understand simply as "A method implements an interface by (having) its signature". The whole point of interfaces, after all, is to abstract away the underlying types, yet the lingo defines them by such. To be fair, an interace may have several methods, which renders that understanding more difficult to articulate. Finally, a method is just a function written with different syntax. Golang is NOT an OOP language. There are no objects. There is nothing "special" about the first argument (the "receiver"). Method syntax merely makes the signature more obvious.

	Golang idiom is to name interface by appending 'er' to its (lone) method, e.g.,
		type Puller interface {
			Pull(d *Data) error
		}

*/
// FEATUREs
/*
	- No fancy syntax. The compiler recognizes the interface by the method operating on the type.
	- No access to upstream source code is required; okay to comandeer/rewrite even a standard library interface in your package. (See `Stringer` interface example.)
*/
