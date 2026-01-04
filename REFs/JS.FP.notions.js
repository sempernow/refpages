// FP Light  @ https://github.com/getify/Functional-Light-JS  
// FP Jargon @ https://github.com/hemanth/functional-programming-jargon#functional-programming-jargon 

// REACTIVE FP :: Lazy Data Structures (vs. Eager; all at once) 
// a.k.a. Functional Reactive Programming (FRP)
// https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch10.md/#reactive-fp  
    /*
        LazyArray() is an OBSERVABLE data structure; 
        push()s values onto `a` as they arrive (EVENT), over time.  
        We call `a` the PRODUCER, and `b` the (REACTIVE) CONSUMER.

        Needn't save values after they are consumed, 
        so these LAZY DATA STRUCTURES are more like BUFFERS than arrays.
    */
    var a,b 

    // PRODUCER  (OBSERVABLE) -- a stream of values

        a = new LazyArray() // fictitious 

        // EVENT (EMIT) -- a value 
        setInterval( () => a.push( Math.random() ), 1000 )

    // CONSUMER  (OBSERVER) -- a callback function 

        // CONSUME -- a value
        b = a.map( v => v * 2 )

        // LISTENER -- Listen to CONSUMER, and trigger callback on new value
        b.listen( v => console.log(v) )

    // DECLARATIVE TIME  https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch10.md/#declarative-time 
    /*  
        `a` is the PRODUCER (EMITTER), which acts essentially like a STREAM OF VALUES. We can think of each value arriving in `a` as an EVENT. The map(..) operation then TRIGGERS a CORRESPONDING EVENT on `b`, the CONSUMER, which we listen(..) to so we can CONSUME the new value.

        TIME is ABSTRACTED away; a is merely a time-independent conduit for values, whenever they are ready; `b` simply consumes whenever they are ready. Good, because the EVENTs are probably out of our control; user's mouse clicks or keystrokes, websocket messages from a server, etc.

        Again, this is a time-independent (aka LAZY) MODELING of the map(..) TRANSFORMATION OPERATION. 

        The time relationship between a and b is DECLARATIVE (and IMPLICIT!), not imperative (or explicit).

        The consumer PULLs from the producer; imperatively the producer would PUSH to the consumer; also, imperatively, the concerns would not be separable.
    */

    // Consumer may process per whatever ...

        b = a.reduce( (total,v) => total + v )

        b.listen( (v) => console.log( "New current total:", v ) )

// FUNCTOR 
// An object that implements a map function; adheres to two rules: 1. Preserve Identity, 2) Composable

// ISOMORPHISM vs EQUALITY: two values are equal if they’re exactly identical in all ways; isomorphic if they are represented differently but still have a 1-to-1, bi-directional mapping relationship. A and B are isomorphic if A can be mapped (converted) to B and then back to A with the inverse mapping; BIJECTIVE MORPHISM.  
// https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch7.md/#isomorphic 

// push() EQUIVALENT, abiding immutability
function fn(addedEl,arr = []) {
    return [ ...arr, addedEl ]
}

// IMPERATIVE
    const makes = [];
    for (let i = 0; i < cars.length; i += 1) {
        makes.push(cars[i].make)
    }
// DECLARATIVE
    const makes = cars.map(car => car.make)

// IMPERATIVE
    const authenticate = (form) => {
        const user = toUser(form)
        return logIn(user)
    }

// DECLARATIVE
    const authenticate = compose(logIn, toUser)

// COMPOSE 
    const compose =  (f, g)  =>    x      => f(g(x))  // f, g are functions; x is the value "piped" through them.
    const compose = (...fns) => (...args) => fns.reduceRight( (res, fn) => [fn.call(null, ...res)], args )[0]
   
    // RIGHT-TO-LEFT data flow for best mathematical fit; ORDER MATTERS, but not grouping.
        // sans FP, the data flow is LEFT-TO-RIGHT
        d.g(a).f(b)  
        // @ FP ...
        compose( f(b),g(a) ) (d)

        const compose = (f, g) => x => f( g(x) )
        const f = (b) => b + 1
        const g = (a) => 3 * a
        compose( f,g )(1)  // 4
        compose( f,g )(3)  // 10

    // ASSOCIATIVITY :: immutable under regrouping
        compose(f, compose(g, h)) === compose(compose(f, g), h)

    // IDENTITY
        compose(id, f) === compose(f, id) === f

// POINTFREE 
    // Given
    const map = (fn) => (list) => list.map(fn)
    const add = (a) => (b) => a + b

    // Then

    // Not points-free - `numbers` is an explicit argument
    const incrementAll = (numbers) => map(add(1))(numbers)

    // Points-free - The list is an implicit argument
    const incrementAll2 = map(add(1))

// IMPURE to PURE 
    const calculateArea = (radius) => radius * radius * PI      // Impure; relies on global (PI)
    const calculateArea = (radius, pi) => radius * radius * pi  // Pure; but ... 
    // ... FP libraries are stuffed full of their own dependencies; functions relying on redefined (MUTATED) JS functions.
    // IDEMPOTENCE :: multiple calls yield same result as first 
    // Pure functions are idempotent.

// CURRYING :: call a function with fewer arguments than it expects. It returns a function that takes the remaining arguments.

    // PARTIAL APPLICATION -- giving a function fewer args than it expects -- can remove a lot of boiler plate code. Also, can run any pure function concurrently since it does not need access to shared memory and it cannot, by definition, have a race condition due to some side effect.

    // FP functions typically do NOT take array arg(s) because can effect per composability; map(getChildren), or @ Ramba, per apply(fn) 

        // Transform function that takes scalar args into one that takes array: simply  wrap it with curried version of map:
     
            function apply(fn) {
                return function (a){
                    return fn( ...a )
                }
            }

            var apply = fn => a => fn( ...a )

    // Same with sort, filter, and other higher order functions (a higher order function is a function that takes or returns a function).

// REFERENTIAL TRANSPARENCY: the code block can be substituted for its evaluated value without changing the behavior of the program.
    // REASONING/TESTING is simplied (due to no side-effects)
    // Inline the value(s), since data is IMMUTABLE 
    const punch = (a, t) => (a.get('team') === t.get('team') ? t : decrementHP(t))
    const punch = (a, t) => ('red' === 'green' ? t : decrementHP(t))
    const punch = (a, t) => decrementHP(t)


// memoize :: only one function; cache corrupted by any other(s) of same argStr
    const memoizeFoo = (foo) => {
        // private cache is memoization
        const cache = {} 

        return (...args) => {
            const argStr = JSON.stringify(args)
            cache[argStr] = cache[argStr] || foo(...args)
            return cache[argStr]
        }
    }

// TRANSDUCER 
    // To transduce means to transform with a reduce; A COMPOSABLE REDUCER.
    // TRANSDUCERs take ONE ARGUMENT, a TRANSFORMER (xf) OBJECT, 
    // and RETURN TRANSFORMERs (xf) when invoked. 

    // GitHub / cognitect-labs / transducers-js 
    // https://github.com/cognitect-labs/transducers-js#the-transducer-protocol  

    // Transducers are composable algorithmic transformations; independent from the context of their input and output; specify only the essence of the transformation per individual element; used in many different processes - collections, streams, channels, observables, etc.; compose directly, without awareness of input or creation of intermediate aggregates.

    // Sneaky lingo for a composable reducer (FUNCTION). Like Monad, it's a FUNCTION that BREAKS THE RULES of FP to get things done. They don't call them functions, keep the explanations as confusing and complex as possible, and hope no one notices. Used to compose adjacent map(..), filter(..), and reduce(..) operations together; express maps and filters as reduces, and then abstract out the common combination operation to create reducing functions that are easily composed. Transducing supposedly improves performance; used on observables. 

    // GitHub / jlongster / transducers-js  
    // https://github.com/jlongster/transducers.js  
    // FLJS  https://github.com/getify/Functional-Light-JS/blob/master/manuscript/apA.md/#what-finally  

        var transduceMap =
            curry( 
                function mapReducer(mapperFn,combinerFn) {
                    return function reducer(list,v){
                        return combinerFn( list, mapperFn( v ) )
                    }
                 } 
            )

        var transduceFilter =
            curry( 
                function filterReducer(predicateFn,combinerFn) {
                    return function reducer(list,v){
                        if (predicateFn( v )) return combinerFn( list, v )
                        return list
                    }
                } 
            )

        var transducer = compose(
            transduceMap( strUppercase ),
            transduceFilter( isLongEnough ),
            transduceFilter( isShortEnough )
        )

// MONAD   https://dev.to/theodesp/explain-monads-like-im-five  
    // The FP "monad" is sneaky lingo for the functions needed to handle all that which FP overlords forbid any "function" from handling. The Monad does the dirty work of handling state, IO, exceptions, ...; all that FP denies functions from doing; the Monad unfucks what FP fucked up. Under FP, a "function" is allowed only to play with itself; affecting nothing whatsoever outside itself. That is, FP is utterly useless, by design, unless it violates its own rules. Hence this magical, mystical, monoidal monstrosity, the Monad, forever presented to us peasantry per way-to-smart-for-you wads of needless blather, all to avoid outing acadamia's useless idiots.
    // 1. A "box" to codify/store MULTIPLE meanings/values of a function's return, 
    //    so function remains PURE, returning that ONE "boxed values" regardless.
    // 2. Composers/linkers, g >>= f, to connect output to input; handling those multiple meanings/values
    //    without having to modify any of the function thereby composed/linked.

// The Wad of Lies Peddled by FP Marketers
    /*
    Readable? No. 

    FP libraries are all about bastardizing native JS methods. And there's no easy way to know which ones they mutated and which remain native. Making the task of deciphering such well obfuscated code all the more burdensome, their favorite pasttime is to strip arguments from function calls. In other words, FP is illegible by design and definitively so. Literally. Nothing is knowable by reading any one of function definition. What you see is not what you get, whether `map` or any other of their mutated natives. To decipher any one code block requires a search across their entire library of mutilated methods to unravel their near-infinitely nested references.

    Portable? No. 

    Without the specific library de jour, virtually nothing coded thereunder will be usable, nonetheless reusable. They shouldn't even call it javascript. The only thing not mutilated is syntax. (They're working on that.) FP is the ultimate spaghetti-code, but for the npm/Node black-hole of stupid, which remains its lone immutable. FP libraries are firmly embedded in its web of recursive dependencies. So, an FP build can be no more stable than its least stable member, which is the signature trait of that "ecosystem". The half-life of a typical npm/Node codebase is a few months, if you're lucky, ignoring the instabilities of its notorious "bundlers", of course. FP does absolutely nothing to remedy any of that. 

    Reasonable? No.

        // either :: (a -> c) -> (b -> c) -> Either a b -> c
        const either = curry((f, g, e) => {
            if (e.isLeft) {
                return f(e.$value)
            }

            return g(e.$value)
        })

    You can surely fantasize about its adorable semantics, but that's not "reasoning", is it? FP codebases are thorougly peppered with these alien creatures. Yet such are a lesser problem compared to its  mutants masquerading as natives. There is no standard for any of their "essentials". And, lest you be lulled into believing there can a learning of it, there is no static "it". In effect, FP attempts to usher in an infinitely mutating language, per repo!

    In the end analysis, one is left wondering how much the oligarchs pay these sorts to inject evermore chaos into the system. The OOP era  gifted us the 500KB "Hello World" app; 555KB after "tree shaking". Perhaps the geniuses of FP can 10x that, but their legacy is to have found an entirely new dimension of wrong to pile upon us.
    */

// Erlang creator, Joe Armstrong: "The problem with object-oriented languages is they’ve got all this implicit environment that they carry around with them. You wanted a banana but what you got was a gorilla holding the banana... and the entire jungle".
