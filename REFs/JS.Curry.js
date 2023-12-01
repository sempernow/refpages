// A Beginner’s Guide to Currying in FUNCTIONAL Javascript 
// https://www.sitepoint.com/currying-in-functional-javascript/ 
/*
    CURRYing; constructing functions that ALLOWS PARTIAL APPLICATION of a function’s arguments. 
    So, passing all the required arguments returns the result; 
    passing a subset of those arguments RETURNS A FUNCTION that accepts the remaining arguments.

    Currying is elemental in functional languages such as Haskell and Scala. 
    JavaScript has functional capabilities, but currying isn’t built in by default.
*/
// Gettin’ Freaky Functional w/Curried JavaScript
// http://blog.carbonfive.com/2015/01/14/gettin-freaky-functional-wcurried-javascript/
'use strict'

const log = (arg, ...args) => console.log(arg, ...args)
// CONVERT fn0 to curried version of itself

    // DEFINE
    function curry(fn0) {
        var arityFn0 = fn0.length

        return function curriedFn1() {
            var argsFn1 = Array.prototype.slice.call(arguments, 0)
            if (argsFn1.length >= arityFn0) {
                return fn0.apply(null, argsFn1)
            }
            else {
                return function curriedFn2() {
                    var argsFn2 = Array.prototype.slice.call(arguments, 0)
                    return curriedFn1.apply(null, argsFn1.concat(argsFn2))
                }
            }
        }
    }
    // ES6 version (FAIL)
    // var curry6 = (fn0) => {
    //     var arityFn0 = fn0.length
    //     return function() {
    //         var argsFn1 = Array.prototype.slice.call(arguments, 0)
    //     }
    // }

    // USE
    var sum4Args = curry((w, x, y, z) => {
        return w + x + y + z
    })
      
    sum4Args(1,2,3)      // [Function: f2]
    sum4Args(1,2,3)(4)   // 10
    sum4Args(1,2,3,4)    // 10
    sum4Args(1,2)(3)(4)  // 10
    sum4Args(1)(2, 3, 4) // 10

log(sum4Args(1)(2,3,4))

// @ MAG  https://mostly-adequate.gitbooks.io/mostly-adequate-guide/appendix_a.html  

    // curry :: ((a, b, ...) -> c) -> a -> b -> ... -> c
    function curryZZZ(fn) {
        const arity = fn.length

        return function $curry(...args) {
                if (args.length < arity) {
                return $curry.bind(null, ...args)
            }

            return fn.call(null, ...args)
        }
    }

// @ FLJS  https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch3.md/#one-at-a-time  
    // Its signature (thus behavior) is DIFFERENT than the others  

    function curryZZ(fn, arity = fn.length) {
        return (function nextCurried(prevArgs){
            return function curried(nextArg){
                var args = [ ...prevArgs, nextArg ]

                if (args.length >= arity) {
                    return fn(...args)
                }
                else {
                    return nextCurried(args)
                }
            }
        })( [] )
    }

    // ES6 version
    var curryZ = (fn, arity = fn.length, nextCurried) =>
            (nextCurried = prevArgs =>
                nextArg => {
                    var args = [ ...prevArgs, nextArg ]

                    if (args.length >= arity) {
                        return fn(...args)
                    }
                    else {
                        return nextCurried(args)
                    }
                }
            )([])
