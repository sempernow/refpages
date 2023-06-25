package main

import (
	"google.golang.org/appengine/channel"
	"fmt"
	"math/rand"
	"time"
)

// Concurrency :: Channel Design Patterns
// https://github.com/ardanlabs/gotraining/tree/master/topics/go/concurrency/channels
// https://www.youtube.com/watch?v=AHAf1Xfr_HE
//
/*
	Signal With Data
		- Wait For Task
			- Goroutine waits for task (indefinitely).
				- UNBUFFERED channel guarantees task is recieved.
		- Wait For Result
			- Wait for goroutine result (indefinitely).
				- UNBUFFERED channel guarantees result is recieved.
	Signal withOUT Data
		- Use WaitGroups NOT Channels
		- If by Channel, use EMPTY STRUCT data type ; make(chan struct{})
			- simply close the channel with it.

		UNBUFFERED channels allows us to sense BACKPRESSURE, e.g., from a pool of goroutines, and to add DEADLINEs and TIMEOUTs. Can't do that with buffered channels.

	Fan Out 
		Wait for specific number of goroutines to finish per BUFFERED channel.       
		GUARANTEE all work sent by goroutine is recieved. 
		NO guarantee that 

*/
func waitForTask() {
	// Make a channel where goroutine can SIGNAL with data; recipient gets GUARANTEEd DELIVERY;.
	// Cost is UNKNOWN LATENCY; UNBUFFERED, so Rx happens BEFORE Tx.
	ch := make(chan string)

	go func() {
		p := <-ch // Tx (send); WAIT for work; unary operation; signalling; UNKNOWN block time.
		fmt.Println("employee : recv'd signal :", p)
	}()

	time.Sleep(time.Duration(rand.Intn(500)) * time.Millisecond) // unknown time later ...
	ch <- "paper"                                                // Send task to goroutine;
	// GUARANTEEd because Rx (receive) happens (nsec) BEFORE Tx (send) @ UNbuffered channel.
	fmt.Println("manager : sent signal")
	// ... order cannot be seen by print; may print send first..

	time.Sleep(time.Second)
	fmt.Println("-------------------------------------------------------------")
}

/*  @ waitForTask()

$ ./example1
manager : recv'd signal : paper
employee : sent signal
-------------------------------------------------------------

Ubuntu:/c/Users/X1/go/src/f06ygo/concurrency/channels/ardanlabs/example1 [1] [x1@XPC] [10:50:16] [#0]
$ ./example1
employee : sent signal
manager : recv'd signal : paper
----------------
*/
func waitForResult() {

	ch := make(chan string)

	go func() {
		time.Sleep(time.Duration(rand.Intn(500)) * time.Millisecond)
		ch <- "paper"
		fmt.Println("employee : sent signal")
	}()

	p := <-ch
	fmt.Println("manager : recv'd signal :", p)

	time.Sleep(time.Second)
	fmt.Println("-------------------------------------------------------------")
}

// pooling: goroutines waiting for work 
func pooling() {
	ch := make(chan string) // "string-based work"

	g := runtime.NumCPU()
	// ... the number of workers/employees aka goroutines.
	for e := 0; e < g; e++ {
		go func(emp int) {
			for p := range ch { // WAITing; channel receive; 
				fmt.Printf("employee %d : recv'd signal : %s\n", emp, p)
			}
			fmt.Printf("employee %d : recv'd shutdown signal\n", emp)
		}(e) // Go runtime (scheduler) decides which goroutine gets any one piece of work
	}

	const work = 100  // ... pass this much work to pool
	for w := 0; w < work; w++ {
		ch <- "paper" // Signalling with data 
		// ... senses BACKPRESSURE; can add TIMEOUTs to manage that.
		fmt.Println("manager : sent signal :", w)
	}

	close(ch) // Signalling without data 
	fmt.Println("manager : sent shutdown signal")

	time.Sleep(time.Second)
	fmt.Println("-------------------------------------------------------------