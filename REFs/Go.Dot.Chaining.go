// Fluent API Design Pattern; return the same Object (struct) over and over.
// https://stackoverflow.com/questions/45256433/go-functions-dot-notation
// Similar to MIDDLEWARE, but the receiver is returned.
package main

import (
	"fmt"
)

type Object struct {
	Value string
	Error error
}

func (o *Object) Before(s string) *Object {
	o.Value = s + o.Value
	// add an error if you like
	// o.Error = error.New(...)
	return o
}

func (o *Object) After(s string) *Object {
	// could check for errors too
	if o.Error == nil {
		o.Value = o.Value + s
	}
	return o
}

func main() {
	x := Object{}

	x.
		Before("123").
		After("456").
		After("789").
		Before("0")

	if x.Error != nil {
		// handle error
	}
	fmt.Println(x.Value)
}
