// A closure returns a (partially applied) function AND its state. 
// @ YDKJS  https://github.com/getify/You-Dont-Know-JS/blob/master/up%20%26%20going/ch2.md
"use strict"
function makeAdder(x) {
    // parameter `x` is an inner variable

    // inner function `add()` uses `x`, so
    // it has a "closure" over it
    function add(y) {
        return y + x
    }

    return add
}
// A closure MAINTAINs STATE of the param(s) it closes over. 
// Here, the parameter closed over is `x`. 

// Two new functions, `plusOne` and `plusTen`, are DEFINED 
// by PARTIALLY APPLYing the `makeAdder` function. 
// (By calling that two-arg function with only one argument.)
// Thereby, each gets a reference to the inner `add(..)` function 
// with closure over its `x` parameter (applying its lone argument).

// That `x`, set per new function, is IMMUTABLE THEREAFTER (over all calls). 
// Yet the `y` PARAMETER REMAINS; hence the term "partially applied".

// DEFINE 

    var plusOne = makeAdder( 1 )

        // function add(y) {
        //     return y + 1
        // }

    var plusTen = makeAdder( 10 )

        // function add(y) {
        //     return y + 10
        // }

// CALL 

    plusOne( 3 )    // 4  <-- 1 + 3
    plusOne( 41 )   // 42 <-- 1 + 41

    plusTen( 13 )   // 23 <-- 10 + 13

// CLOSUREs vs OBJECTs  
/* 
    Objects and closures are ISOMORPHIC to each other; 
    somewhat INTERCHANGEABLE in representing STATE and BEHAVIOR.

    BENEFITS of CLOSURE: granular change control & automatic privacy. 
    BENEFITS of OBJECT: more PERFORMANT and easier cloning of state.
*/
// @ YDKJS  https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch7.md/#chapter-7-closure-vs-object  

// Closure does NOT 'close over' OBJECTs
var obj, xpz

obj = {foo:1,bar:2}

xpz = (function (o) {
    return (function() {  
        return o
    })
})(obj)()

xpz.bar = 0

console.log(xpz)  // { foo: 1, bar: 0 }
console.log(obj)  // { foo: 1, bar: 0 }

// To PROTECT :: Use JSON methods to CLONE

obj = {foo:1,bar:2}

xpz = JSON.parse(JSON.stringify(obj))

xpz.bar = 0

console.log(xpz)  // { foo: 1, bar: 0 }
console.log(obj)  // { foo: 1, bar: 2 }
