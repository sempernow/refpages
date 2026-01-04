// DEFER `fn` until the end of the current JS event loop
;(async function def() {
    // Do stuff ...
    Promise.resolve()
        .then(fn)
    // EQUIVALENT
    await Promise.resolve() 
    fn()
    // EQUIVALENT 
    await undefined 
    fn()
    // Do more stuff ...
    // ... THEN run `fn`.
})()

// Example ... 
// https://stackoverflow.com/questions/45079887/await-equivalent-of-promise-resolve-then
// Defer until the end of the current run of the JS event loop: 
    // `Promise.resolve()` vs. `await undefined`
    // which is same as `await Promise.resolve()`
;(function(){
    console.log('A')

    Promise.resolve()
        .then( () => console.log('E') )

    console.log('B')

    console.log('C')

    ;(async () => {
        await undefined 
        console.log('F')
    })()

    console.log('D')

    // A 
    // B 
    // C 
    // D 
    // E 
    // F 
})()

// Generators [YDKJS]  https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch4.md#chapter-4-generators
/*
    Generators are a new ES6 function type that does not run-to-completion like normal functions. Instead, the generator can be paused in mid-completion (entirely preserving its state), and it can later be resumed from where it left off.

    This pause/resume interchange is cooperative rather than preemptive, which means that the generator has the sole capability to pause itself, using the yield keyword, and yet the iterator that controls the generator has the sole capability (via next(..)) to resume the generator.

    The yield / next(..) duality is not just a control mechanism, it's actually a two-way message passing mechanism. A yield .. expression essentially pauses waiting for a value, and the next next(..) call passes a value (or implicit undefined) back to that paused yield expression.

    The key benefit of generators related to async flow control is that the code inside a generator expresses a sequence of steps for the task in a naturally sync/sequential fashion. The trick is that we essentially hide potential asynchrony behind the yield keyword -- moving the asynchrony to the code where the generator's iterator is controlled.

    In other words, generators preserve a sequential, synchronous, blocking code pattern for async code, which lets our brains reason about the code much more naturally, addressing one of the two key drawbacks of callback-based async.
*/
// async-await & Promise (functions)
// NOTE: The `async` ALWAYS RETURNs a PROMISE, WHETHER or NOT `await` is used.
// REFs:
//   "Async functions - making promises friendly "  
//   https://developers.google.com/web/fundamentals/getting-started/primers/async-functions 
//   "Should I use Promises or Async-Await?"
//   https://hackernoon.com/should-i-use-promises-or-async-await-126ab5c98789
async function asyncFunc() {
    try {
        const fulfilledVal = await promise
    } catch (rejectedVal) {
        // on fail
    }
}

// Example 1; fetch() is natively "promisified", i.e., always returns a promise 

// per Promise 
function logFetch(url) { // using .then()
    return fetch(url)
        .then(response => response.text()) // ES6 syntax
        .then(text => {
            console.log(text)
        })
        .catch(err => {
            console.error('fetch failed', err)
        })
}
// per async (Equivalent)
async function logFetch(url) {
    try {
        const response = await fetch(url)
        console.log(await response.text())
    } catch (err) {
        console.log('fetch failed', err)
    }
}

// Example 2; "promisify" a (legacy) function 
function wait(x, t) { // promise that resolves to x after t seconds
    return new Promise((resolve) => {
        setTimeout(() => resolve(x), t * 1000)
    })
}

// Use per Promise
wait('foo', 2)
    .then(x => console.log(x))   // foo [after 2 seconds].

// Use per async-awat & promise IIFE [concurrent]
;(async function (x) {
    var a = wait(20, 2)
    var b = wait(30, 2)
    return x + await a + await b
})(15).then(v => console.log(v)) // 65 [after t seconds; concurrent!].

// per async and promise IIFE [NOT concurrent]
;(async function (x) {
    var a = await wait(20, 2)
    var b = await wait(30, 2)
    return x + a + b
})(15).then(v => console.log(v)) // 65 [after 2 * t seconds; NOT concurrent!].