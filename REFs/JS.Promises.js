// tl;dr

// A promise (chain) is an asynchronous process that is ORTHOGONAL (in time) to that outside. There is no "value" that is ever "resolved" to anything outside the chain. Even trying to log a "thenable" (a SETTLED promise) will print only a Promise "pending" or "fullfilled", depending upon the promise-method preceeding. So, do ALL downstream PROCESSING inside a function (fn) called per .then(fn)
p.then(fnX)
// or 
p.then(()=>{
    // Process per embedded processing block ...
})
// or, upon its promised value ...
p.then((x)=>{
    // Process the promised `x` here ...
})

// Return a promise with resolve/reject already attached
function promise() {
    var resolve
        , reject
        , p = new Promise(function(res, rej){ 
                resolve = res, 
                reject = rej
            })

    arguments.length && resolve(arguments[0])
    p.resolve = resolve
    p.reject  = reject
    return p
}

window.Promise  
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise  
// Promises are tricky, brittle, and poorly supported, unlike the claims of those peddling the new stuff.   
// At best, `fetch()` is about as fast as `XHR`, but almost always integer multiples slower,   
// and oddly the newer API tends act like it's blocking (they're supposedly asynchronous),  
// though it may merely be such a CPU hog that it only mimics such regarding the UX. 
// "Promisifying" a function almost always degrades its performance.

new Promise(executor)  // executor FUNCTION is invoked immediately; its return is ignored. 
// HOWEVER, the executor takes TWO PARAMETERS, EACH is a Promise CALLBACK FUNCTION:
// The two callback functions (resolve, reject) are what survive Promise creation.
// `resolve` is called IF the Promise *settles* *fullfilled*; 
// `rejected` is called IF the Promise *settles* *rejected*
const p = new Promise((resolve, reject) => {
    // DO something ASYNCHRONOUS, which eventually CALLS EITHER:
    //
    //   resolve(someValue)        // if settled FULFILLED  
    // or
    //   reject("failure reason")  // if settled REJECTED
})
// Promise STATUS is PENDING until SETTLED.  
// A Promise RETURNs a *thenable* Promise.  
// If, at any point in this chain, a promise is not RETURNED, 
// the chain ends, reverting to SYNCHRONOUS mode

// EACH of the callback functions (resolve, reject) 
// takes ONE ARGUMENT; string, number, boolean, array or object
resolve(string|number|boolean|array|object)
reject(string|number|boolean|array|object)
    // I.e., 
    resolve(data)
    reject(error) // typically, `error` is set of k-v pairs capturing state 
    
// ONLY ONE is CALLED upon Promise SETTLED; called per `.then()`
.then() // CONSUMEs a settled PROMISE 
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/then

// To chain, MUST RETURN a FUNCTION 
p.then( fn1 ).then( () => val1 ).then( fn2 )
// p.then( fn1 ).then( val1 ).then( fn2 ) ... FAILs

// NOTE: Promise ARGs are best HANDLEd IMPLICITly
p.then(fnX)
// ... BUT can do explicitly, i.e., 
// DESIGN PATTERN; embed the function (processing block) 
p.then(() => {
    // Process the promise here 
})
// or
p.then((x) => {
    // Process (the promise of delivering) 'x' here.
}) 

// NOTE: Use EXPLICIT .catch()
p.then(resolve).catch(reject)  // BETTER
// or 
p.then(resolve, reject)

    // EXPANDING the second form above (using ES6 arrow notation) ...

    p.then((data) => {
        // Do if Promise settled fullfilled (HAPPY).
        // Use try/catch block here, ELSE UNCAUGHT ERROR may occur.
        },
        (error) => {
        // Do if Promise settled rejected (FAILED).
        }
    )
    // That is, each arg, both of .then(arg) and .catch(arg), is a FUNCTION NAME.

    // IF the resolve func RETURNs an ASYNC func, 
    // THEN (is *thenable*) ASYNC chain CONTINUES. 
    // So, to keep promise chain "alive", each func MUST RETURN a PROMISE
    .then((resp) => {
        if (resp.ok) {
            return resp.json()   // promise chain continues
        } else {
            throw Error({  // promise chain ends; drops down to .catch(eHandler)
                status: resp.status,
                statusText: resp.statusText,
                url: resp.url
            })
            // throw, INSTEAD OF ...
            return Promise.reject({  // promise chain ends; drops down to .catch(eHandler)
                status: resp.status,
                statusText: resp.statusText,
                url: resp.url
            })
        }
    })
    .then(foo)
    .then(bar)
    .catch(eHandler)

        // Expanding eHandler ...
        .catch((err) => {/* handle the error */})

// Promise reject vs. Throw  
// https://stackoverflow.com/questions/33445415/javascript-promises-reject-vs-throw
// The `throw` TERMINATES that block, whereas `reject` does NOT.
    new Promise((resolve, reject) => {
        throw "err";
        console.log("NEVER REACHED");
      })
      .then(() => console.log("@throw: RESOLVED"))  
      .catch(() => console.log("@throw: REJECTED"))  
      
    new Promise((resolve, reject) => {
        reject(); // resolve() behaves similarly
        console.log("@reject: ALWAYS REACHED"); // "REJECTED" will print AFTER this
      })
      .then(() => console.log("@reject: RESOLVED"))
      .catch(() => console.log("@reject: REJECTED"))

// PROCESS MANY PROMISES
Promise.all(arrOfPromises)  // Handle a batch of promises
// E.g., fetch/process an array of URLs 
    // generated here (incidentally)
    ;[...Array(max)].forEach((_, i) => {
        urls[i] = ('data/frag.' + i + '.html')
    })
    // fetch all promises; Fetch API is promise-based
    const fetchAll = urls.map(url => {
        return fetch(url).then(resp => resp.text())
    });
    // process all promises
    Promise.all(fetchAll)
    .then((texts) => {
        //... the sum of ALL text(s) are delivered here, as promised.
    })

// Promise Factory to Execute a batch of promises SEQUENTIALLY
function executeSequentially(promiseFactories) {
    var result = Promise.resolve()
    promiseFactories.forEach((promiseFactory) => {
        result = result.then(promiseFactory)
    });
    return result;
}

// HANDLE Promise ARGs IMPLICITly:

// Understanding Promises :: "We have a problem with Promises" 
// https://pouchdb.com/2015/05/18/we-have-a-problem-with-promises.html
// Q: What are the differences in the following 4 : 

    one() 
        .then(() => {
            if (x) {return x}                // Return synchronous value !
            if (!x) {throw new Error('boo')} // Throw synchronous error !
            return two()                     // two(UNDEFINED); returns async promise
        }).then(finalHandler)                // finalHandler(resultOftwo)

    one()  // USE THIS FORM
        .then(two)               // two(resultOfone)
        .then(finalHandler)      // finalHandler(resultOftwo)

    one() 
        .then(() => {
            two()                // two(UNDEFINED)
        }).then(finalHandler)    // finalHandler(UNDEFINED)

    one()
        .then(two())             // two(UNDEFINED)
        .then(finalHandler)      // finalHandler(resultOftwo)

    // - ALWAYS pass a function ??? to .then()
    // - ALWAYS throw (sync) err @ .then(); much better debugging

// Wrap SYNCHRONOUS code :: MAKE it ASYNCHRONOUS; 
    // DEFER execution of synchronous FUNCTION @ then()
    Promise.resolve()
        .then(() => {
            /* deferred */
        })

    // Start a Promise (API) with ...
    function aPromiseAPI() {
        return Promise.resolve()
            .then(function () { // deferred 
                doSomethingThatMayThrow()
                return 'foo';
            })
            .then(/* process return of above */)
            .catch(/* catch any error thrown anywhere above */)
    }

    // PARAMs can be PASSed IMPLICITLY (Pointfree)

        Promise.resolve(8).then(console.log) // 8

        function foo() {return 8}

        Promise.resolve(foo).then(foo)       // [Function: foo]
        Promise.resolve(foo()).then(foo)     // 8

// ASYNC/AWAIT <==> PROMISE
    function resolveAfter2Seconds() {
      return new Promise(resolve => {
        setTimeout(() => {
          resolve('resolved')
        }, 2000)
      });
    }
    // EQUIV @ async/await
    async function asyncCall() {
      console.log('calling')
      var result = await resolveAfter2Seconds()
      console.log(result)
      // expected output: 'resolved'
    }

asyncCall()

// ==============================================

// Promises Intro 
//    https://developers.google.com/web/fundamentals/getting-started/primers/promises
// Working with Promises
//    https://developers.google.com/web/ilt/pwa/working-with-promises
// MDN
//    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
//    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises
//    https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/catch
// "Should I use Promises or Async-Await?"
//    https://hackernoon.com/should-i-use-promises-or-async-await-126ab5c98789

// SYNChronous vs. ASYNChronous
    // Sync 
        try {
            var value = foo();
            console.log(value);
        } catch(err) {
            console.log(err);
        }
    // Async
        foo().then(function(value) {
            console.log(value);
        }).catch(function(err) {
            console.log(err);
        });
    // So, say
        p = foo()
    // I.e., foo() is a PROMISE; `onResolved()` and `onRejected()` are its two handler functions
        p.then( onResolved ).catch( onRejected ) // i.e., onSuccess, onFailure

// ARRAY of PROMISES
    Promise.all([..])   // resolves if all of the promises passed into it resolve
    Promise.race([..])  // settles [resolves] on first resolved promise passed to it  
                       // gotcha! @ race if empty array; promise never resolves 

    // .resolve()
    Promise.resolve(non-thenable-value)  // returns p; the value made thenable (fullfilled) 
    Promise.resolve(p)                   // returns p; unwraps, then wraps, as needed

    // .defer()
    Promise().defer()  // suppresses automatic error reporting on that Promise 

    // .then()
    p.then( onResolved, onRejected )  // REGISTERS "fulfillment" and/or "rejection" event(s)/callbacks

// DESIGN PATTERNS 
    function onResolved() {/* @ promise SUCCESS (resolved) */}
    function onRejected() {/* @ promise FAIL (rejected) */}

    p.then( onResolved, onRejected )
    // BETTER
    p.then( onResolved ).catch( onRejected ) 

        // `null`, to handle rejections only ...
        p.then(null,function(err){/* @ promise REJECTED */})
        // Equivalent ...
        p.catch(function(err){/* @ promise REJECTED */})

    // Another pattern ...
    function foo (p) { p.then( onResolved, onRejected ) }

// USEage :: 2 PATTERNS
    p.then(onResolved,onRejected)         // BAD
    p.then(onResolved).catch(onRejected)  // GOOD

    // BAD :: p.then(onResolved,onRejected)
    p
        .then(function (result) {
            console.log("Success!", result); // "FULFILLed"
            // some PROCESS HERE MAY THROW ERROR, but is UNCAUGHT.
        }, function (err) {
            console.log("Failed!", err);   
            // "REJECTed", but NOT @ .then() block ERR 
    });
    
    // GOOD :: p.then(onResolved).catch(onRejected)
    p
        .then(function (result) {
            console.log("Success!", result); // "FULFILLed"
            // some PROCESS HERE MAY THROW ERROR, and is CAUGHT.
        })
        .catch(function (error) {
            console.log("Failed!", error);  
            // "REJECTed", AND @ .then() block ERR
    })
    // GOOD (ES6 equiv)
    p
        .then(result => {
            console.log("Success!", result);
        })
        .catch(error => {
            console.log("Failed!", error);
        })

        // NOTE: ...
            .then(onResolved).catch(onRejected)
        //  is equivalent to ...
            .then(func, null).then(null, errHandle);	
            
    // NOTE: Can fix the BAD pattern; use try/catch block @ then() block 
    p
        .then(function (result) {            // "FULFILLed"
            try {
                /* possibly err here */
            } catch (errOnThen) { 
                /* handle error */
            };
        }, function (err) {                  // "REJECTed"
            console.log("Failed!", error);
    });

// CONSTRUCTOR; create a promise; "PROMISIFY" a function 
// Use ONLY to wrap FUNCTIONS THAT DON'T INHERENTLY SUPPORT PROMISES
    var p = new Promise(function (resolve, reject) {  // ES5 syntax
    var p = new Promise((resolve, reject) => {        // ES6 syntax
        // do stuff, then…
        // ... "RESOLUTION FUNCTIONS" are called:
        //  resolve(..) generally signals fulfillment, and ...
        //  reject(..) signals rejection ALWAYS.
        if (success) {
                resolve("RESOLVEd"); 
            }
            else {
                reject(Error("REJECTed"));
            }
    });

    // Promisify a function 

    // Example 1 
        function wait(x,t) { // promise; resolves to x after t seconds
             return new Promise((resolve) => {
                 setTimeout(() => resolve(x), t * 1000)
             });
        }
        // use ...
        wait('foo',2)
            .then(x => console.log(x)); // foo [after 2 seconds].

    // Example 2 :: Allow max-time-til-fail
        var p = new Promise(function (resolve, reject) {
            // event 
            var maxTime = 2500, event = 0;
            setTimeout(function () { 
                 return event = 1;                         
            }, maxTime - 100); // '-' for success, '+' for fail
            
            // detect success/fail 
            setTimeout(function () { 
                if (event === 1 ) {
                    resolve("The event occurred 100ms BEFORE maxTime. [FULFILLed]");
                }                           
                if (event === 0 ) {
                    reject(Error("The event occurred 100ms AFTER maxTime. [REJECTed]")); 
                    // Error() returns 'Error: {text}', 'at {fname.js}:{line}' of this reject()
                }
            }, maxTime);
        });

        // Usage ...

        // GOOD :: p.then(onResolve).catch(onReject)
        p   // handles all errors
            .then(function (result) {
                console.log("Success!", result);
                //throw '@ then() block'; // simulate err occuring here
            })
            .catch(function (error) {
                console.log("Failed!", error);
            })

        // BAD :: p.then(onResolve,onReject)
        p   // (un)handled err @ .then() 
            .then(function (result) {
                console.log("Success!", result);
                //throw '@ then() block'; // simulate err occuring here
                //try {throw 'oops';} catch (e) { console.log("try-catch!", e)};
            }, function (error) {
                console.log("Failed!", error);
            })

/*
Lab: Promises
    https://developers.google.com/web/ilt/pwa/lab-promises
            
        .then(function-called-@-RESOLVED, function-called-@-REJECTED)
        
            @ .then(func1, func2), func1 OR func2 will be called, never both. 
            @ .then(func1).catch(func2), both will be called if func1 rejects, as they're separate steps in the chain. 
            
        functions on an ARRAY of PROMISES
        
            .all()   resolves if all of the promises passed into it resolve
            .race()  settles [resolves] on first resolved promise passed to it    
    
    Working with Promises
        https://developers.google.com/web/ilt/pwa/working-with-promises
        
    JavaScript Promises: an Introductionhttps
        https://developers.google.com/web/fundamentals/getting-started/primers/promises

    Promise Fates & States [no distinction even within their own abstractions;]
        https://github.com/domenic/promises-unwrapping/blob/master/docs/states-and-fates.md

        JavaScript promises API will treat anything with a then() method as promise-like ('thenable').
        
        States [ recorded in [[PromiseState]] ]

            fulfilled   if p.then(f) will call f "as soon as possible."
            rejected    if p.then(undefined, r) will call r "as soon as possible."
            pending     if p is neither fulfilled nor rejected.
            
            "settled"   if p is either fulfilled or rejected; NOT pending 

        Fates [ stored implicitly ]

            resolved    settled; if filled or rejected.
            unresolved  pending; if it is not resolved.

        PromiseCapability Record Fields
        
            Field Name    Value             Meaning
            -----------   ---------------   --------
            [[Promise]]   object            usable as a promise.
            [[Resolve]]   function object   used to resolve the promise object.
            [[Reject]]    function object   used to reject the promise object. 
            
*/
