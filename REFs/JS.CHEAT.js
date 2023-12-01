//=====================================================================
// Javascript [ES5/6]
//   https://developer.mozilla.org/en-US/docs/Web/JavaScript
//   https://github.com/getify/You-Dont-Know-JS#you-dont-know-js-book-series
//   https://github.com/cyberwizardinstitute/workshops/blob/master/javascript.markdown
//   https://learnxinyminutes.com/docs/javascript/
//   https://en.wikipedia.org/wiki/JavaScript_syntax
//  JS Design Patterns 
//   https://addyosmani.com/resources/essentialjsdesignpatterns/book/#designpatternsjavascript
//  JS Style 
//   https://standardjs.com/  Javascript Standard Style [feross]
//   https://en.wikipedia.org/wiki/Indent_style

// GRAMMAR 
// https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch5.md
// ASI [Automatic Semicolon Insertion]
// TDZ [Temporal Dead Zone]; ES6; where variable reference cannot yet be made, because it hasn't reached its required initialization.
// RESERVED JS Words https://www.w3schools.com/js/js_reserved.asp
// RESERVED EVENT (HTML Event Attributes)  https://www.w3schools.com/tags/ref_eventattributes.asp
// SCOPE 
    var 
    //   function scoped
    //   Undefined when accessing a variable before it's declared

    let
    //   block scoped
    //   ReferenceError when accessing a variable before it's declared

    const
    //   block scoped
    //   ReferenceError when accessing a variable before it's declared
    //   Yet MUTABLE if OBJECT|ARRAY, so use only on primitives.
         ;Object.freeze( obj ) // Use this on OBJECT|ARRAY to make IMMUTABLE 


// LEXICAL SCOPE vs. DYNAMIC SCOPE 
    // Lexical Scope is determined where declared [author-time].
    // Dynamic Scope is determined where called from [run-time]; call-site; call-stack immediately prior to execution

    // JS uses LEXICAL SCOPE, EXCEPT for `this`, which uses DYNAMIC SCOPE; 
        // Since `this` (a binding made for each function invocation) uses DYNAMIC SCOPE,
        // property/global namespace collisions CAN BREAK the `this` BINDING.
        // "Why this?" @  https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch1.md#why-this

        // BINDING to `this` occurs PER SCOPE;
        // 4 RULES, ordered by priority:  https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch2.md#review-tldr
        /*
            1. Called w/ new (CONSTRUCTOR CALL)?           binds to newly constructed object.
            2. Called w/ call(), apply(), or bind()?       binds to the specified object.
            3. Called w/ context object owning the call?   binds to that context object.
            4. Default:                                    Undefined @ strict mode, else to global object.
        */
        // FIXes for the `this` binding-rules problem:

            // IMPLICIT BINDING 
                obj1.obj2.foo()  // obj2 is the `this` @ foo method; BROKEN if property/global NAMESPACE COLLISION
            
            // EXPLICIT BINDING; force a function call to use a particular object for the this binding, without putting a property function reference on the object  https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch2.md#explicit-binding
                fn.call(thisArg, arg1, arg2, ..)        // known number of additional args
                fn.apply(thisArg, [argsArray])          // array holds the additional arg(s)
                fn.bind(thisArg[, arg1[, arg2[, ..]]])  // returns a new function
                
                // The `thisArg` IGNORED @ ARROW FUNCTIONS; they DO NOT HAVE THEIR OWN `this`; 
                // call(), apply(), and bind() can ONLY PASS IN PARAMETERS; no `this`.
                arrowFn.bind(undefined,a,b,c)

            // HARD BINDING of `this`  https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch2.md#hard-binding
                fn.bind(thisArg, ..) // ES5 :: Function.prototype.bind; 
                // or 
                var bound = function() {
                    fn.call( thisArg, ..)
                }

            // LEXICAL-THIS; another solution (to loss of `this` binding that may otherwise occur) ..
            // https://github.com/getify/You-Dont-Know-JS/blob/master/scope%20%26%20closures/apC.md
                function fooFn() {
                    var self = this
                    //... 
                }

// BLOCK SCOPE (@ lexical scope), in ES5/6, occurs only @ certain BUILT-INs: 
    function,  let, catch(e),  with() 
    
// ARROW function NOTATION 
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions 
    (param1, param2, .., paramN) => { statements }
    (param1, param2, .., paramN) => expression
    // EQUIVALENT TO: 
    (param1, param2, .., paramN) => { return expression }

    // if ONE PARAM, then PARENTHESES are OPTIONAL:
        param1 => { statements }
        
    // if NO PARAMs, then MUST USE parentheses:
        () => { statements }

    // if function BODY is PARENTHESIZED, then returns an OBJECT LITERAL EXPRESSION:
        params => ({foo: bar})

    // REST PARAMs (a.k.a. SPREAD SYNTAX) supported:  
        (param1, param2, ...rest) => { statements }
        // This represents an indefinite number of args as an ARRAY.

    // DEFAULT PARAMs are supported:  
        (param1 = defaultVal1, param2, .., paramN = defaultValN) => { statements }

    // Arrow functions have NO `this` of their own, so `call()` and `apply()` can ONLY PASS IN PARAMETERS.
    // Arrow functions bind `this` using LEXICAL SCOPE; fixes the `this` 4-rules issue; HOWEVER ...
        // Note, @ forEach(cbFn,thisArg), `thisArg` used as the `this` value for each callback.
        [1,2].forEach(function(i){console.log(this+i)},'foo')
        // foo1
        // foo2
        [1,2].forEach(i => console.log(this+i),'foo')  // Yet NO such binding @ arrow function:
        // [object global]1
        // [object global]2

    // Arrow functions CANNOT use as GENERATOR; no `yield` allowed, but can contain such a function.

    // LIMITATIONS 

        // Arrow functions NO PROTOTYPE property, and cannot invoke per `new ...`.
            var Foo = () => {}
            Foo.prototype         // UNDEFINED
            var foo = new Foo()   // TypeError: Foo is not a constructor

        // No `this` :: Does not create a new scope
            const obj = { 
                i: 10,
                b: () => console.log(this.i, this),
                c: function() {
                    console.log(this.i, this)
                }
            }
            obj.b() // undefined, Window {...} 
            obj.c() // 10, Object {...}

// BUILT-IN GLOBALs
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects

// EXPRESSIONS + OPERATORS
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators
    []              // Array initializer/LITERAL syntax.
    {}              // Object initializer/LITERAL syntax.
    ()              // Grouping operator.
    /pattern/flags  // RegExp LITERAL; flags: g [global/all], i [ignore-case], m,u,i
    
    // Operators || and && do NOT necessarily result in boolean; 
    // they select one of the two operand's values
        a || b    // `a`, if truthy, else `b`
        a && b    // `b` if `a` and `b` truthy, else whichever is falsey
        
        a && b()  // `b()` executes only if `a` truthy; all functions/objects/arrays are truthy

        ;( statement ) || ( statement )

        !foo   && ( pubs[eType] = [] )
        ;(foo) || ( pubs[eType] = [] )

        // vs. TERNARY 
            a || b
            // roughly equivalent to:
            a ? a : b

            a && b
            // roughly equivalent to:
            a ? b : a

            // USAGE -- NOTE that wrapping the ternary following `&&` is REQUIRED, 
            // else the false condition fires regardless.
            ;(thread) && (
                (thread.dataset.threadCollapsed) 
                    ? toggleThread(thread, expand) 
                    : toggleThread(thread, collapse)
            )

            return !x && ( x = false ) || ( x = true ) 
            return !x ? x = false : x = true  // equivalent

            // ternary operator is right-associative, which means it can be "chained" in the following way, similar to an if … else if … else if … else chain:
            function example() {
                return condition1 ? value1
                     : condition2 ? value2
                     : condition3 ? value3
                     : value4
            }

            // Equivalent to:

            function example() {
                if (condition1) { return value1 }
                else if (condition2) { return value2 }
                else if (condition3) { return value3 }
                else { return value4 }
            }

// OPERATOR/DESCRIPTION
    a == b   // equal to
    a === b  // equal value and equal type
    a !=     // not equal
    a !== b  // not equal value or not equal type
    a > b    // greater than
    a < b    // less than
    a >= b   // greater than or equal to
    a <= b   // less than or equal to
    
    !!foo  // foo to boolean 
    !foo   // NOT foo 
    !foo   // ERR if unDECLARED
    !null  // true 
    !0     // true 

    // bitwise
        &    // AND; Sets each bit to 1 if both bits are 1
        |    // OR;  Sets each bit to 1 if one of two bits is 1
        ^    // XOR; Sets each bit to 1 if only one of two bits is 1
        ~    // NOT; Inverts all the bits
        >>>  // Zero-fill right-shift; Shifts right; push zeros in from left; rightmost bits fall off
        <<   // Zero-fill left-shift; Shifts left; push zeros in from right; leftmost bits fall off
        >>   // Signed right-shift; Shifts right; push-copy leftmost bit in from left; rightmost bits fall off

        // E.g., create mask for flags b and c; then toggle them (mask all other bits)
        var FLAG_B = 2 // 0010
        var FLAG_C = 4 // 0100
        var mask = FLAG_B | FLAG_C // 0110
        flags = flags ^ mask       // 1100 ^ 0110 => 1010  (other bits/flags unaffected)

// KEYWORD/DESCRIPTION
    // break     // Terminates a switch or a loop
    // continue  // Jumps out of a loop and starts at the top
    // debugger  // Stops the execution, and calls the debugging function
    // do/while  // Executes a block of statements, and repeats the block, while a condition is true
    // for {}    // Marks a block of statements to be executed, as long as a condition is true
    // function  // Declares a function
    // if/else   // Marks a block of statements to be executed, depending on a condition
    // return    // Exits a function
    // switch    // Marks a block of statements to be executed, depending on different cases
    // try/catch // Implements error handling to a block of statements
    // var       // Declares a variable

// FLOW CONTROL

    // ITERATE 
    // loop var is NOT scoped to loop, by default, so declare [Crawford]
    for (var i = 0; i < max; i += 1) {/**/}
    for (;;) {/**/} // INFINITE loop

    while (condition) {/**/} 

    // ITERATE over ARRAY [arr] or OBJECT [obj] 
    
        // `forEach(fn)`
        // NOT include properties (keys) from its [[Prototype]] chain
            arr.forEach(function (val) {/**/}) 
            Object.keys(arr).forEach(function(idx) {/**/})
            Object.keys(obj).forEach(function(key) {/**/})
           
        // ARRAY :: `for..of` 
            for (const el of arr) {
                console.log(el)
            }
            
            for (const [i, el] of arr.entries()) {
                console.log(i+'. '+el)
            }

        // OBJECT :: `for..in` 
        // INCLUDEs properties (keys) from its [[Prototype]] chain 
            for (var key in obj) {/**/} 
            for (var  el in arr) {/**/} // if order is NOT important
        
            var i  // performance; define first
            for (i = 0; i < arr.length; i += 1) {/**/}
            for (i = 0; i < arr.length; i++) {/**/}  // equiv.
            
// ERROR HANDLING 
    throw new ERROR
    function assert(test, message) {if (!test) throw new Error(message)}
    
    // try [throw] catch 
        try {/**/} catch (error_object__thrown_from_try_block) {/**/} 
    
        try {undef();true} catch (e) {false}  // false
    
        try {
            if (typeof success === 'undefined' ) throw '@ try'
            console.log('success')
        } catch (e) {              // NOTE: e, of try/catch block, has block scope
            console.log(' FAILed',e)
        } 
        // 'FAILed @ try'

// LOGIC | BRANCHING 

    if (num < 2 || (num > 2 && num % divisor == 0)) {/**/}
    if (divisor <= Math.sqrt( num )) {/**/} else {/**/}

    // @ RECURSE :: MUTUAL RECURSION example:
        function isOdd(v) {
            if (v === 0) return false
            return isEven( Math.abs( v ) - 1 )
        }

        function isEven(v) {
            if (v === 0) return true
            return isOdd( Math.abs( v ) - 1 )
        }

    // SWITCH / CASE  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/switch
    switch (expression) {
      case value1:
        //...
      case value2:
        //... break is OPTIONAL
        break
      case valueN:
        //...
       break
      default:
        //...
    }


// TERNARY OPERATOR  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Conditional_Operator
    condition ? expr1 : expr2  // expr1 iff condition true; expr2 iff condition false
    // Examples ...
        'The fee is ' + (isMember ? '$2.00' : '$10.00')
        
        var rs = fromFile
            ? fs.createReadStream(file) 
            : process.stdin

// HOISTING 
    // declarations occur in compilation phase; are hoisted 
    // assignments occur afterwards, in execution phase; NOT hoisted
    a = 2 ;var a; console.log( a )  // 2
    console.log( a );var a = 2      // undefined

// DECLARATIONs

    // METHOD NOTATION; Object Literals
        // http://stackoverflow.com/questions/5754538/javascript-object-literal-notation-vs-plain-functions-and-performance-implicatio
        var Foo = {
            foo: function () {/* .. */},
            bar: 'Derp derp',
            baz() {/* .. */}         // ES6; concise function declaration w/in literal syntax
        }
        
    // FUNCTION NOTATION equiv. 
        var Foo = (function () {
            function foo() {return 'bar'}
            function baz() {/* .. */}

            return {
                f: foo,
                b: 'Derp derp',
                baz: baz
            }
        }()) // ... using IIFE

        // Use ...
        Foo.f     // [Function: foo]
        Foo.f()   // 'bar'
        Foo.b     // 'Derp derp'

// FUNCTION vs. METHOD NOTATION

    // declare 
        function f1() {return 'bar'}                 // function notation
        var f2 = function () {return 'bar'}          // function notation

        var m1 = {f:function () {return 'bar'}}      // method notation [per object]
        var m2 = (function () {return {f:'bar'}}())  // function notation [per IIFE]

    // invoke 
        f1()     // "bar"
        f2()     // "bar"
        
        m1.f()   // "bar"
        m2.f     // "bar"

// ARROW NOTATION ( FAILs @ IE < 11 )
    function (arg1,arg2) {/* .. */} 
    // Arrow equiv.
    (arg1,arg2) => {/* .. */}
    // equiv. if single arg
    arg => {/* .. */}

        // Ex. ...
        myArray.map(function (el) { 
            return el.arrProperty 
        }) 
        // Arrow equiv.
        myArray.map((el) => {
            return el.arrProperty
        })
        // Arrow simpler equiv.
        myArray.map((el) => el.arrProperty) 
        // Arrow simplest equiv.
        myArray.map(el => el.arrProperty)

    // Call a FUNCTION by its STRING NAME 
    // I.e., store func name as a variable
        var fnName = "aFn"
            // @ Global :: fooFn()
                aFn()           // Call
                window[fnName]()  // Call
            // @ Object :: fooObj.fooFn()
                aFn()           // Call
                fooObj[fnName]()  // Call

// CONSTANT 
    const pi = 3.145  // okay for PRIMITIVEs only
    pi = 7            // TypeError

    // BUT does NOT make objects immutable
    const z = [1,2,3]
    z.push(6)  // [ 1, 2, 3, 6 ] ... MUTATED!!!

    const o = {a:1,b:2}
    o.b = 0    // { a: 1, b: 0 } ... MUTATED!!!

// SYMBOLs (ES6) :: Unique IDs
    ( Symbol() === Symbol() ) // false 

    let id1 = Symbol("id")
    let id2 = Symbol("id")
    
    (id1 == id2)         // false

    const obj = {}
    
    obj[id1] = 123
    console.log(obj[id1])  // 123

    var s = { }, id = Symbol('id'), e = 'event'
    s[e][id] = 'whatever'
    if (Object.getOwnPropertySymbols(s[e]).length === 0) {
        delete s[e]
    }

// VARIABLEs

    // DECLARE and INITIATE/ASSIGN at the beginning; 
    // vars are HOISTED regardless
    // per DATA TYPEs [do NOT use 'new ..'] 
        var s1 = '',               // new primitive string  
                n1 = 0,                // new primitive number
                b1 = false,            // new primitive boolean
            obj1 = {},               // new object
            arr1 = [],               // new array object
                f1 = function () {},   // new function object
             rx1 = /()/              // new RegExp object

        var someVar             //  declared, but undefined
        var someVar = undefined // do NOT use 'null'; "it's useless" [Crockford]

            // esp., do NOT USE 'new ..' syntax on str/num/bool; useless + costly
            var x = new String()      // Declares x as a String object
            var y = new Number()      // Declares y as a Number object
            var z = new Boolean()     // Declares z as a Boolean object
                
        // loop vars are NOT scoped to loop, so ...
        var i
        for (i = 0; i < 5; i += 1) {/* code */}

    // TEST type
        typeof undefined     === "undefined" // true
        typeof unDECLARED    === "undefined" // true; perpetuates CONFUSION !!!
        typeof true          === "boolean"   // true
        typeof 42            === "number"    // true
        typeof "42"          === "string"    // true
        typeof { life: 42 }  === "object"    // true
        typeof funcFoo       === "function"  // true; but is actually a sub-type; a "callable object"
        // added in ES6!
        typeof Symbol()      === "symbol"    // true

        // test for null value
            var a = null
            (!a && typeof a === "object")  // true
                
        // test if undefined a.k.a. void 0
            (void 0 === undefined)  // true 
        
        if (!x) .. // ERR/FAIL if x undeclared, so ...
        // SAFEly test for unDECLAREd ...
        if (typeof x !== 'undefined') {/* x is declared */}
        // SAFEly test for undefined or null ...
        if (typeof x === 'undefined' || x === null) {/* x is undefined or null */}
        
    // increment/decrement
    x += 1; x -= 1
    // increment or initialize [works if foo UNDELCARED]
    var foo = ++foo || 0

        // ... else ...
        x++  // bad form; do NOT use
        x--  // bad form; do NOT use

    // mult/div 
    x  = x * y
    x *= y
    
    x = x / y
    x /= y

    "Hello" + 5 // Hello5

    // expression grouping (parens) to ensure/alter precedence 
    var x = (100 + 50) * 3 

    typeof undefined             // undefined
    typeof null                  // object; but it's not; it's a primitive [type]
    null === undefined           // false
    null == undefined            // true

    // interpretations per ORDER of types ...
    var x = 16 + 4 + "Volvo" // 20Volvo
    var x = "Volvo" + 16 + 4 // Volvo164 

    // DYNAMIC TYPES
        var x               // Now x is undefined
        var x = 5           // Now x is a Number
        var x = "John"      // Now x is a String

// SPECIAL VALUES 
// https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch2.md#special-values
    null      // special keyword 
    undefined // identifier [unfortunately]
    // for both, the label is its TYPE AND its VALUE
    // CAN, but DO NOT, in "non-strict mode"
    undefined = 2      // really bad idea!
        
    void  varFoo       // returns 'undefined'; does NOT mofify varFoo
        var a = 42     // Ex. ...
            void a     // undefined
            a          // 42
            void 867   // undefined
            void 0     // use that CONVENTION, from C-language

    NaN          // 'Not a Number'; bad number; invalid number, but type IS `number`
        NaN !== NaN  // true  
        typeof NaN   // number 
        2 / 'foo'    // NaN
        
        var a = 2 / "foo"
            a == NaN        // false
            a === NaN       // false
            isNaN( a )      // true
            isNaN( "foo" )  // true
        
    Number.POSITIVE_INFINITY    // Infinity
    Number.NEGATIVE_INFINITY    // -Infinity
        1 / 0                     // Infinity
        -1 / 0                    // -Infinity

    +0, -0  // +/- zeros
    var a = 0 / -3        // -0; browser dependent !!!
        a.toString()          // 0
        String(a)             // 0
        JSON.stringify( -0 )  // 0
        JSON.parse( "-0" )    // -0 
        
        -0 == 0      // true
        -0 === 0     // true
        0 > -0       // false
        
        Object.is(val,ref)  // ES6; test two values for absolute equality, without exception
            Object.is( ( 2 / 'foo' ), NaN )  // true
        
// DATA TYPES

    // in JavaScript, variables don't have types; VALUEs have TYPEs
    // 7 PRIMARY TYPES  https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch3.md#type
        string, number, boolean, object, null, undefined, symbol // "simple primitives", NOT objects, except for "object"
        // BOXING (WRAPPERS); primitive values don't have properties/methods; JS will auto' box (wrap) primitive value for access.
            Object(primitiveFoo)  // BOX manually; sans `new`; better performance than constructor form
            objFoo.valueOf()      // UNBOX object to primitive 
            
    // BUILT-IN OBJECTS [these are actually just built-in functions, NOT types or classes as in Java]
        String, Number, Boolean, Object, Array, Function, RegExp, Date, Error 

            // thus, e.g., 'String string' denotes a particular object [String] and its primary type [string].
        
            Function, Array // are "complex primitives"; object sub-types; functions are "callable objects"
        
            Objects, Arrays, Functions, and RegExp  
            // ... are objects regardless of whether declared per literal or constructed FORM
            // Only use the constructed form if you need the extra options; Array() constructor may omit `new`
            
            null, undefined  // ... are primitive values only; no object wrapper form. 

            // per Constructor Form ONLY; no literal form counter-part.
                Date(), Error()  // Error() is rarely created explicitly; may omit `new`; auto created when exceptions are thrown.

            Symbol()  // ES6; https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch3.md#symbol
        
    // PASSING by ... VALUE vs. REFERENCE
    // In JavaScript, there are NO POINTERS, and references work a bit differently. A reference points at a (shared) value; all references to a value are always distinct references to a single shared value; none of them are references/pointers to each other.

        // Simple values; always assigned/passed by VALUE-COPY
            null, undefined, string, number, boolean, symbol

        // Compound values; always assigned/passed by REFERENCE-COPY
            objects, arrays, functions, and all boxed object wrappers
                // Ex.
                var a = [1,2,3]  // [1,2,3]
                var b = a        // [1,2,3]
                b = [4,5,6]
                a                // [1,2,3]
                b                // [4,5,6]

        // TYPE TESTs :: typeof, instanceof 
        var strPrimitive = "a string"
        var strObject = new String( "a string" )

            typeof strPrimitive             // "string"
            strPrimitive instanceof String  // false

            typeof strObject                // "object"
            strObject instanceof String     // true
        
        // INSPECT OBJECT SUB-TYPE
        Object.prototype.toString.call( strObject )  // [object String]

            // NOTE: JS automatically coerces a "string" PRIMITIVE to a String OBJECT when necessary
            Object.prototype.toString.call( strPrimitive )  // [object String]
            // and yet such type coersion on-the-fly does NOT affect the variable
            typeof strPrimitive                             // "string" ... STILL.
            // thus, needn't use `new`; almost never need to explicitly create per Object form.

    // SYMBOL [ES6]; new primary data type; opaque unguessable value [per environment]
        var obj = {[Symbol.foo]: "value @ this Symbol key [foo]; a new data type called Symbol"}

    // BOOLEAN 
    // keywords: 
        true, false
        
        // Falsy Values: (primitive) values that will become false if coerced to boolean 
            undefined, null, false, +0, -0, NaN
        // Truthy Values; EVERYTHING ELSE
            
        // Falsy Objects: NONE
        // Truthy Objects: ALL  [ALL OBJECTS are TRUTHY]
            var a = new Boolean( false )
            var b = new Number( 0 )
            var c = new String( "" )
            var symb = Symbol('foo')
            var func = function(){return false}
            
            Boolean( a && b && c )  // true
            Boolean( [] )           // true
            Boolean( {} )           // true
            Boolean( symb )         // true
            Boolean( func )         // true

    // STRING [immutable VALUE, unlike arrays]
    // https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch2.md#strings
        var foo = "bar"

        // methods
            "hello".charAt(1)  // "e"; older syntax
            "hello"[1]         // "e"; newer syntax

            "hello".indexOf("l")     // 2
            "hello, world".replace("hello", "goodbye") // "goodbye, world"
            "hello".toUpperCase()    // "HELLO"
            "hello".concat( "bar" )  // "hellobar"

            // shallow resemblance to arrays; See ARRAY-LIKEs
            var a = "foo"
            var b = ["f","o","o"]
                a.length                    // 3
                b.length                    // 3
                a.indexOf( "o" )            // 1
                b.indexOf( "o" )            // 1
                a.concat( "bar" )           // "foobar"
                b.concat( ["b","a","r"] )  // ["f","o","o","b","a","r"]

            // "borrow" NON-MUTATION array methods ...
                a.join  // undefined
                a.map   // undefined ... BUT ...

                Array.prototype.join.call( a, "-" ) // "f-o-o"

                Array.prototype.map.call( a, function(v){
                    return v.toUpperCase() + "."
                } ).join( "" )                     // "F.O.O."

            // whereas mutating methods  ...
                a.reverse      // undefined
                Array.prototype.reverse.call( a ) // 'TypeError:...'
            // ... only work on arrays
                b.reverse()   // ["!","o","O","f"]
                b             // ["!","o","O","f"]

                // so, hack `reverse()` :: convert to array, reverse, convert to string ...
                a.split("").reverse().join( "" )  // "oof"

        // TEMPLATE LITERALS; enclosed by the backtick (back-tick a.k.a. grave-accent); "`"
            // Mock an XHR response of JSON (sans escape sequences)
            j = `[{"name":"foo's Bar"},{"name":"B's Fooz"}]`

            `string text ${expression} string text`
            //E.g.,
                `Fifteen is ${a + b} and 
                not ${2 * a + b}.`
            //equiv.
                'Fifteen is ' + (a + b) + ' and\nnot ' + (2 * a + b) + '.'

            // Escape using backslash char 
            `\`` === '`' // --> true

            // TAGGED TEMPLATE LITERALS; PArse template literals with a function
            // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals#Tagged_templates   
                var person = 'Mike'
                var age = 28
                function tagFn(strings, personExp, ageExp) {
                    var str0 = strings[0] // "That "
                    var str1 = strings[1] // " is a "
                    var ageStr
                    if (ageExp > 99){
                        ageStr = 'centenarian'
                    } else {
                        ageStr = 'youngster'
                    }
                    // We can even return a string built using a template literal
                    return `${str0}${personExp}${str1}${ageStr}`
                }
                var output = tagFn`that ${ person } is a ${ age }`
            // That Mike is a youngster

            // UNICODE
                // JS    https://mathiasbynens.be/notes/javascript-unicode
                // Node  https://kev.inburke.com/kevin/node-js-string-encoding/
                // HTML UTF-8  https://www.w3schools.com/charsets/ref_html_utf8.asp
                
                    '\x41\x42\x43'        // ABC; HEXIDECIMAL ESCAPE SEQUENCE
                    '\u0041\u0042\u0043'  // ABC; UNICODE ESCAPE SEQUENCE

    // NUMBER  https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch2.md#numbers
    // JavaScript number is "IEEE 754" aka "floating-point"; specifically the "double precision" aka "64-bit binary" format
    
        0.1 + 0.2 === 0.3  // false           // NOT a uniquely JS issue; IEEE 754 issue; infamous
        Math.abs( n1 - n2 ) < Number.EPSILON  // ES6; compare 2 numbers equate within EPSILON difference

        42.  // okay, but avoid; confusing
        42.0, 42, 42.3  // valid 
        0.42, .42       // valid
        
        123e5      // 12300000
        123e-5     // 0.00123
        
        0xf3    // hex for: 243 base 10
        0Xf3    // hex for: 243 base 10
        -0xCCF  // hex for: -3279 base 10
        
        0363    // oct for: 243 base 10
        -077    // oct for: -63 base 10
                
        // notation methods 
            x.toFixed( digits )          // "42.5900"
            x.toPrecision( digits )      // "42.6"
            x.toExponential()            // "5e+10"
            
            Number.isInteger( 42 )      // true
            Number.isInteger( 42.000 )  // true
            Number.isInteger( 42.3 )    // false
            Number.MAX_SAFE_INTEGER     // 9007199254740991 [@ Node.js]
            Number.isSafeInteger( Number.MAX_SAFE_INTEGER )  // true
            Number.isSafeInteger( Math.pow( 2, 53 ) )        // false
            Number.isSafeInteger( Math.pow( 2, 53 ) - 1 )    // true

        // BUILT-IN MATH
                Math.sin(3.5)
                Math.PI * r * r
            
        // BUILT-IN TYPE CONVERSIONS

            // NUMBER TO STR
            .toString()
            
                (123).toString()       // '123'
            // number to binary str: 
                (123).toString(2)      // '1111011'
            // number to hex str:
                (123).toString(16)     // '7b'

            // STR TO NUMBER
                Number('123')          // 123
                
                // STRING-TO-BASE CONVERSION
                parseInt(#, base)   
            
                    parseInt("7F", 16)   // 127 base 10
                    parseInt("255", 10)  // 255 base 10
                    parseInt('377', 8)   // 255 base 10
                    parseInt("11", 2)    //   3 base 10
                    parseInt("foo", 10)  // NaN

        // Infinity and -Infinity
        // See 'SPECIAL VALUES'
             1 / 0  //  Infinity
            -1 / 0  // -Infinity

            isFinite(1/0)        // false
            isFinite(-Infinity)  // false
            isFinite(NaN)        // false

            isFinite(1/0)        // false
            isFinite(-Infinity)  // false
            isFinite(NaN)        // false

    // TYPE COERSION
    // https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch4.md#explicit-coercion
        // always result in a scalar primitive; string, number, boolean
            5 + ""  // '5'; implicit coercion; number to string
            
            // to string 
                String(foo)
                foo.toString()
                JSON.stringify(foo[, replacer[, space]]) 
                // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify
                // https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch4.md#json-stringification

            // to number
                Number("123.45")      // 123.45
                parseInt("123.45")    // 123
                parseFloat("123.45")  // 123.45 

            // to boolean
                Boolean( foo && bar || baz )
                !!( foo && bar || baz )

            // per unary operator
                5+ +"3.14"  // 8.14

                // per `~`; bitwise NOT 
                    ~n  // 1; for ALL numbers EXCEPT -1
                    foo.indexOf(bar) // -1 IFF bar NOT in foo, 
                    // so, replace ...
                    if (a.indexOf( bar ) != -1) {/* found! */}
                    // ... with ...
                    if( ~a.indexOf( bar) )  {/* found! */}
                    if( !~a.indexOf( bar) ) {/* NOT found! */}
                    
                    // truncate to 32 bit int 
                        1E20      // 100000000000000000000
                        ~~1E20    // 1661992960 
                        1E20 | 0  // 1661992960 

    // OBJECTs :: JS objectds are CLASSLESS; no 'instances'; no 'inheritance'; 
        // Passed by REFERENCE; Assigned per LINK, NOT copy
        // 'k:v' pairs; keys are STRING; values are ANY TYPE 

        var obj1 = { 
                key1:"val1", 
                prop2:50, 
                meth1:function meth1(a,b) {/** */}, 
                prop3:{foo:'bar',k:'v'}, 
            }

        // EXTEND obj1 Property AFTERwards ...
            obj1.p3 = {a:1,b:2}

        // EXTEND obj1 Method AFTERwards ...

            // First define the desired method
            function has(k) {return k in this}
            // Then add it ...
            obj1.has = has     // Add has() method to obj1
            // So, ...
            obj1.has('prop2')  // true

        // JSON notation is NOT JS OBJECT notation; 
            // requires double-quotes @ both keys and values  https://www.w3schools.com/js/js_json_intro.asp
            x = { "prop1": "val1", "prop2": 1, "prop3": { "foo": 1.11, "k": "v" } }

        // NOTE: PROPERTY vs. METHOD; to access an object key is to access an object PROPERTY, whether or not the value is a function; there are no methods/classes in javascirpt; functions do NOT belong to anything. BUT, the lingo 'method' is used for object functions.  https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch3.md#property-vs-method

        // Obj KEY EXISTENCE TEST 
            (key in obj)                // boolean
            //... but also returns `true` for properties in prototype chain 
            // (`Object.prototype.<key>`), e.g., `constructor in obj`.
            
            obj.hasOwnProperty(key)     // boolean
            //... test if at object DECLARATION ONLY
            
                // more robust way; handles properties created per Object.create(null)
                Object.prototype.hasOwnProperty.call(obj,"a")

        // PROPERTY DESCRIPTORS [DATA DESCRIPTORS]
            Object.getOwnPropertyDescriptor(obj, key)
                /* { value: valueFoo,
                        writable: true,
                        enumerable: true,
                        configurable: true }
                */
        // (re)DEFINE [new/existing] PROPERTY; use to customize object's property(ies)
            Object.defineProperty( obj, key, 
                {                        // e.g., make it read-only ...
                    value: valueFoo,
                    writable: false,       // NOTE: CAN change to `false` EVEN AFTER `configurable: false`
                    configurable: true,    // FAILs if `false`, so change to `false` is one-time, one-way!
                    enumerable: true       // `false` to hide from enumeration code, e.g., at `for..in`
                } )
            
            // IMMUTABILITY; several JS approaches, but are SHALLOW
            // affects only the object and its direct property characteristics. If object has a reference to another object (array, object, function, etc), then contents thereof remain mutable.
    
                // OBJECT CONSTANT ...
                    Object.defineProperty(..) { writable:false, configurable:false } 
                    
                // PREVENT EXTENSIONS
                    Object.preventExtensions( obj )
                        // then ...
                        obj.foo = 3  // undefined
                    
                // SEAL; canNOT add new properties; canNOT reconfigure or delete any existing property; 
                // CAN MODIFY property VALUES 
                    Object.seal( obj )
                    
                // FREEZE; provides only SHALLOW, naive immutability
                    Object.freeze( obj )

                    var x = Object.freeze( [ 2, 3, [4, 5] ] )
                        x[0] = 42     // [ 2, 3, [ 4, 5 ] ]  ... unchanged.
                        x[2][0] = 0   // [ 2, 3, [ 0, 5 ] ]  ... MUTATED !!!  

        // ASSIGN 
            Object.assign(target, ...sources)
            // WARNing: values that are OBJECTs are copied BY REFERENCE.
            // ... so later mutations on target AFFECT SOURCE.

            // MERGE multiple sources
                Object.assign({foo: 0}, {bar: 1}, {baz: 2})  // {foo: 0, bar: 1, baz: 2}

            // ASSIGN per DESTRUCTURE  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment#Array_destructuring
                var stocks = {
                    "AAPL": { price: 121.95, change: 0.01 },
                    "MSFT": { price: 65.78, change: 1.51 },
                    "GOOG": { price: 821.31, change: -8.84 },
                }

                for (let id in stocks) { 
                    o = Object.assign( { id }, stocks[id] )
                }
                // { id: 'APPL', price: 121.95, change: 0.01 }
                // { id: 'MSFT', price: 65.78, change: 1.51 }
                // { id: 'GOOG', price: 821.31, change: -8.84 }

        // STRING array to variable names/values 
            var str = ["foo", "bar"]
                ,int = [10, 20]
            var str = str.map((str,i)=>self[str] = int[i]+1)
            foo // 11
            bar // 21

            // CLONE per ASSIGN 
            // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign

                // Object.assign() performs a SHALLOW clone [ES6]  
                    var newObj = Object.assign( {}, oldObj )

                        var o1 = { a1: 1, a2: { b1: 1 } }
                        var o2 = Object.assign({},o1)
                        o1  // { a1: 1, a2: { b1: 1 } }
                        o2  // { a1: 1, a2: { b1: 1 } }
                        o2.a1 = 8                        // o1 unchanged here.
                        o2.a2.b1 = 8                     // ... deep
                        o1  // { a1: 1, a2: { b1: 8 } }  // ... MUTATED !!!
                        o2  // { a1: 8, a2: { b1: 8 } }
                    
                    // Does NOT work @ Set(); original object MUTATEs on any change to "clone".

        // DEEP clone ( NOT per Object.assign() )
            var newObj = JSON.parse(JSON.stringify(oldObj))  
            // ( LIMITATION: Not all objects are JSON-safe. )

                var o1 = {a1:1,a2:{b1:1}}
                var o2 = JSON.parse(JSON.stringify(o1))

                o1  // { a1: 1, a2: { b1: 1 } }
                o2  // { a1: 1, a2: { b1: 1 } }
                o2.a1 = 8                        // o1 unchanged here.
                o2.a2.b1 = 8                     // ... deep
                o1  // { a1: 1, a2: { b1: 1 } }  // UNCHANGED.
                o2  // { a1: 8, a2: { b1: 8 } }

                delete o2.a2.b1                  // ... deep
                o1  // { a1: 1, a2: { b1: 1 } }  // UNCHANGED.
                o2  // { a1: 8, a2: {} }


    // TWO SYNTAXes
    
        // 1. DECLARATIVE :: OBJECT LITERAL  <<< PREFERRED way <<< the core of JSON syntax
            var obj = { 
                     prop_1: val_1,                     // key may be any valid identifier 
                 "prop n": '\u2627',                    // any UTF-8/Unicode compatible string; JSON names
                    meth1: function meth1() {/*...*/},  // may be method; property whose val is function
                 meth2() {/* anonymous */},             // ES6; concise method declaration in any object literal
                prop4Obj1: {                            // value may be object
                     sub1: [44,55,77],
                     sub2: {a:1,b:2},
                     regex: /ab+c/,                     // RegExp literals
                },
                oink: '🐷',
                [xVar + "foo"]: "Computed Property Name"  // ES6; note `[...]:` syntax
            }
                // NOTE: concise method decl expands to lambda; drawback is no self-ref
                // https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch6.md#unlexical

        // 2. CONSTRUCTED 
            var obj1 = new objFoo()  // Constructor; `new`; obj1 LINKed to objFoo() per objFoo.prototype
            obj1.key1 = value1
            
            // `new` operator LINKS two objects per its (badly named) `.prototype` property/method; though called a 'constructor', it does NOT 'instantiate' a class 'instance'; key distinction is that in JavaScript, no copies are made. Rather, objects end up linked to each other via an internal [[Prototype]] chain; `.constructor` property/method also delegates thru .prototype
            
            // NOTE: nuanced behavior if key1 (that object property name) already exists (anywhere in prototype chain): 
                // Setting & Shadowing Properties  https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch5.md#setting--shadowing-properties

    // PROTOTYPE :: JS uses Prototypal Inheritance vs. Class Inheritance 
    // use Object.prototype.XXX to ADD a property/method to an [existing] object
        Object.prototype
        // denoted `[[Prototype]]`; an internal property of Objects; an internal link that exists on one object which references another object; almost all objects are given some non-null value for this property, upon creation; a property is identified per "prototype chain" search; it's NEITHER about "class" NOR "inheritance"
        .hasOwnProperty(), .isPrototypeOf(), ( for..in )  // do prototype chain searches
        
        const card = {}
        const list = []
        Object.getPrototypeOf(card) === Object.prototype  // true
        Object.prototype.isPrototypeOf(card)              // true
        Object.getPrototypeOf(list) === Array.prototype   // true
        Array.prototype.isPrototypeOf(list)               // true

        // IF aObj instaniated per `new Object()`, THEN ...
        aObj.prototype.newProp = aValue
        // add a function [as a method] to an [existing] object
        aObj.prototype.aMethod = function (/* vars */) {
            /* other code perhaps */
            return this.aFn(/* vars */).aProp
        }

        // NATIVE PROTOTYPES [@ documentation]
            String.prototype.XYZ 
            // documentation convention; that becomes ... 
            String#XYZ
            
            // E.g., 
                Array.prototype.concat() /* DOC EQUIV TO */ Array#concat(..)
            // NEVER EXTEND Native Prototypes, else (future) namespace collision!
                Object.prototype.has = function(k) {
                    return k in this
                }
                Array.prototype.has = function(v) {
                    return this.includes(v)
                }
                // Rather EXTEND a specified target OBJECT; define the desired function (aFn), 
                // then add that as a method (aMethod) to an existing object (o)  
                    o.aMethod = aFn 
                    // Thus, all the per-instance STATE is managed per aFn definition (per closure)
                    o.aMethod = aClosureFn(aState)  // This is the FP-congruous way of doing things 
            
        // Example @ Mithral :: dbmonster
            (_base = String.prototype).lpad || (_base.lpad = function(padding, toLength) {
                return padding.repeat((toLength - this.length) / padding.length).concat(this)
            })  // ... now `_base.lpad` extends String method;

        // BEHAVIOR DELEGATION; DELEGATION-ORIENTED DESIGN; a fundamentally different design pattern from classes.
        // https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch6.md
        // https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch6.md#mental-models-compared
            // OLOO (objects-linked-to-other-objects) is a code style which creates and relates objects directly without the abstraction of classes. OLOO quite naturally implements [[Prototype]]-based behavior delegation.
            // DELEGATION LINKS; terminology such as "inheritance", "prototypal inheritance", and all the other OO terms do not make sense when considering how JavaScript actually works. Instead, "delegation" is a more appropriate term, because these relationships are not copies but delegation links; "OLOO" (objects-linked-to-other-objects) pattern. https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch5.md#whats-in-a-name
            
    Object.create() // creates an object with [[Prototype]] linkage to another object, WITHOUT all the class cruft
    // https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch5.md#createing-links
        var linkedObj = Object.create(someObj)
            // then add property(ies), sans `.prototype` ...
            linkedObj.newProp = .. // purposefully AVOID someObj (properties) NAMESPACE; do the opposite of OO pattern
            // https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch6.md#delegation-theory
        
        // "dictionary" (key:val data store); empty/null [[Prototype]] linkage;
            var dictObj = Object.create(null) 
        
        // OO vs. OLOO  Design Pattern [Mental Model]
        // https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch6.md#mental-models-compared
        
        // Introspection @ OLOO Pattern [test a delegation link]
        Foo.isPrototypeOf( Bar )              
        Object.getPrototypeOf( Bar ) === Foo  

    // ACCESSING OBJECT PROPERTIES :: 2 ways/syntax; either `.` or `[]` operator
        obj.propName     // "property access" 
        // equiv.
        obj["propName"]  // "key access"; "property access"

        // Call a function per STRING name (fn)
        obj[fn]
        // Call all functions in CSV list of them
        fnList.split(',').map(fn => (typeof o[fn] === 'function') && o[fn]())

        // `obj[method]` syntax allows greater variety of key names; any UTF-8/Unicode compatible string ... 
            obj.for = "Simon"           // Syntax error; 'for' is a reserved word
            obj["for"] = "Simon"        // okay
            obj["foo, bar!"] = "Simon"  // okay
            // ... but prevents some compiler optimizations [and takes more keystrokes]
            // Property names are pointers [references]; objects are passed by reference

    // CLASS [ES6]
    // https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/apA.md#review-tldr
    
    // ACCESSING OBJECT METHODs  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/prototype?v=control#Methods
        obj.methodName() 
        obj.methodName   // returns method description; same as w/ function
    
    // get ALL PROPTERTIES of object 'o'; returns array
    Object.getOwnPropertyNames(o)

// ARRAY [complex-primitive; object sub-type]
// https://github.com/getify/You-Dont-Know-JS/blob/master/types%20%26%20grammar/ch2.md#arrays
// length = (highest index) + 1

    var a = [...Array(parseInt(n)).keys()] // [ 0, 1, 2, 3, 4 ]  (Note rest syntax)
 
    // Array Literal syntax
    var arr1 = ["value 1", "value 2", 65, 3.987]                  // indices 0, 1, ...
    var arr2 = [{key1:'val 1',foo:'bar'}, [22,33,44], "foo", 86]  // value @ index 0 is an object
        arr2[0]          // { key1:'val 1', foo:'bar' }
        arr2[0]['foo']   // 'bar'
        arr2[1]          // [ 22, 33, 44 ]
        arr2[1][2]       // 44
        arr2[77]         // undefined
        arr2[3]          // 86
        arr2.length      // 4

    // append 
        var foo = [0,1]
        foo[foo.length] = 'el'  // assure no "empty slots"; next; last
        foo[5] = 5
        foo                     // [ 0, 1, 'el', , , 5 ]; "sparse array"
        foo.push(obj)           // appends obj to foo
        foo.concat(obj)         // appends obj, BY REFERENCE, to NEW ARRAY; foo unaffected

        foo.length = 0          // DESTROYs ALL ELEMENTS of foo

    // CAN create multi-dim array ...
        var arr = [[1, 2, 3], ['a', 'b', 'c'], 'bar']  // multidimentional arrays/els
            arr[0][2]  //  3
            arr[1][2]  // 'c'
            arr[2][2]  // 'r'

    // CAN, but DO NOT, add a key:value (property) to an ARRAY ...
        var arr = [1,2]
            arr.length // 2
            arr.foo = 'bar'
            // equiv.
            arr["foo"] = 'bar'
            arr        // [ 1, 2, foo: 'bar' ]
            arr['foo'] // 'bar'
            arr.foo    // 'bar'
            // ... such an element is NOT enumerable; NOT available per methods: .length, .pop(), ...
            arr.length // 2
            arr[2]     // undefined
            arr.pop()  // 2 
            arr        // [ 1, foo: 'bar' ]
            Object.getOwnPropertyDescriptor(arr,1) // undefined
        
    // CAN, but DO NOT, create array of purely key:value object[s]; `{}` type better optimized for such
    // also, if key LOOKS like a number, then it will be treated as an INDEX
        var arr = []; var arr["4"] = "foo"; var arr["2"] = "bar" 
                 // wanted ['4':'foo', '2':'bar']; 2 element array of two key:val pairs
        arr  // got    [, , , 'bar', , 'foo']; 4 element array; empty, except @ keys interpreted as indices		
            
    // ARRAY-LIKEs; convert an array-like value (a numerically indexed collection of values) into a true array
        function foo() {
            var arr = Array.prototype.slice.call( arguments )
            arr.push( "bam" )
        }
        foo("bar","baz")  // ["bar","baz","bam"]
        // ES6 equiv.
        var arr = Array.from( arguments )  // `arguments` is a builtin Array-like object

    // ARRAY METHODS
        length, forEach(func), indexOf(value[,#starting-idx]), toString(), 
        push(el), pop(), shift(), unshift(el), join(str), toString()
        concat(el), concat(arr), concat(arr1,arr2,..)
        
        // MAP an array :: every el  in array per callback function
            var n = [1, 4, 9]
            var roots = n.map(function(n) {
                return Math.sqrt(n)
            })
            // roots is now [1, 2, 3]

        // MAP an array of objects 
            var kvArr = [
                {k: 1, v: 10}, 
                {k: 2, v: 20}, 
                {k: 3, v: 30}
            ]
            var iArr = kvArr.map(obj =>{ 
                var iObj = {}
                iObj[obj.k] = obj.v
                return iObj
            })
            // iArr is now [{1: 10}, {2: 20}, {3: 30}] 

            // Generate array of object's size, and then iterate on the object
            [...Array(els.length)].map((_,i) => {  
                els[i].className = 'foo '+c
            })


        // REDUCE an array :: apply the supplied reducer func to every el 
            // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce
            [0, 1, 2, 3, 4].reduce(function(accum, currVal, currInd, array) {
                return accum + currVal
            }) 

        slice(#frm,#to-but-not-including)
            // (shallow) copy array using slice()
            var cloneArr = arr.slice() 
        splice(#start, #-els-removed, added-el-1, added-el-2,..) 
            // can slice with splice ...
            foo = [0, 1, 2, 3, 4, 5] // [ 0, 1, 2, 3, 4, 5 ]
            foo.splice(1,3)          // remove el# 1,2,3 (2nd, 3rd, and 4th els)
            // [ 1, 2, 3 ]
            foo
            // [ 0, 4, 5 ]
        sort(), reverse(), sort(fn) // https://www.w3schools.com/js/js_array_sort.asp
        sort(function(a, b){return a - b}) // numeric ascending
        sort(function(a, b){return b - a}) // numeric descending

        some(fn), every(fn) // return boolean
        
// ARRAY or OBJECT 
    var arr = ['a', 'b', 'c']
    var obj = { 100: 'a', foo: 'b', 7: 'c' }

    // JSON vs JS Object 
    person = {"firstName":"John", "lastName":"Doe", "age":46}  // JSON 
    person = {firstName:"John", lastName:"Doe", age:46,}       // JS Object
    points = [40, 100, 1, 5, 25, 10]  // valid JSON and a JS Object (BOTH)

    // JSON parses FASTER than JS Obj (JSON grammar is much simpler.)
        const data = { foo: 42, bar: 1337 }                // SLOW
        // store as JSON; parse @ runtime:
        const data = JSON.parse('{"foo":42,"bar":1337}')   // FAST

        // @ localStorage :: setItem(), getItem() handle k-v pairs only
        // Define an extension, where `v` may be an OBJECT. (Handles non-existent k-v.)
        // @ https://stackoverflow.com/questions/2010892/storing-objects-in-html5-localstorage
        Storage.prototype.setObject = function(k, o) {  // Set Obj; k-v, where `v` MAY BE an object. 
            this.setItem(k, JSON.stringify(o))
        }
        Storage.prototype.getObject = function(k) {     // Get Obj; k-v, where `v` MAY BE an object. 
            var o = this.getItem(k)
            return o && JSON.parse(o)
        }
        // Use
        uObj = { userId: 24, name: 'Jack Bauer' }

        localStorage.setObject('user', uObj)   // set
        uObj = localStorage.getObject('user')  // get

    Object.keys()  // an array of all the keys of the object; 
    // does NOT include properties (keys) from [[Prototype]] chain, unlike `for..in`

        // @ array
        Object.keys(arr)  // ['0', '1', '2']

        // @ object 
        Object.keys(obj)  // [ '7', '100', 'foo' ] ... NOTE the disregard for order

        delete obj.foo    // { '7': 'c', '100': 'a' }
        delete arr[1]     // [ 'a', , 'c' ]        ... NOTE index is NOT deleted; "sparse array"

        var kvArray = [{key: 1, value: 10}, 
            {key: 2, value: 20}, 
            {key: 3, value: 30}]

    // NESTED DATA STRUCTURE 
        var root = {
                a: 3,
                b: [ { x: 4, y: 6 }, { d: 1, e: 2 } ],
                c: { q: [ 7, 8, 9 ], r: [ 1, 2, 3 ]
        }
        root.c.r[2]  // 3
        
// ITERATE over ARRAY or OBJECT [preferred vs. 'for' loop]
// https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch3.md#iteration
    var arrFoo = ["Hello", "World"]
    var objFoo = {foo:'Foo', bar:'Bar', baz:{one:'baz 1', two:'baz 2'}}
    
    // `forEach()` :: iterate over OBJECT keys, but NOT those of its [[ Prototype ]] chain 
        arrFoo.forEach(function (val) {/**/}) 
        Object.keys(arrFoo).forEach(function(idx) {/**/})
        Object.keys(objFoo).forEach(function(key) {/**/})

     // `for..`    :: iterate over ARRAY indices
        for (var i = 0; i < arrFoo.length; i += 1) {
            // arrFoo[i] 
        }
        
     // `for..in`  :: iterate over OBJECT keys, including those of its [[ Prototype ]] chain 
        for (var key in objFoo) {
            // objFoo[key]
        }
        
        // `for..of` :: iterate over values directly [ES6]
        for (var val of arrFoo) {
            // values @ each index
        }
        // `for..of` looks for either a built-in or custom @@iterator object consisting of a next() method to advance through the data values one at a time.

        // `for..in` loops applied to arrays can give somewhat unexpected results, in that the enumeration of an array will include not only all the numeric indices, but also any enumerable properties. It's a good idea to use `for..in` loops only on objects, and traditional for loops with numeric index iteration for the values stored in arrays.

    // FILTER/MAP/REDUCE an ARRAY
    // f(a,b) <==> a.f(b)  [equiv.]

        filter(arr,filterFn(el))  
        // or 
        arr.filter(filterFn(el))

        // filterFn is typically a PREDICATE (FP lingo); returns true|false 
        // (el,i) :: OPTIONAL second param is INDEX.

        map(arr,mapFn(el))  
        // or 
        arr.map(mapFn(el))

        // reduce()
        function reduceFn(result,el) {/* code returning result */}
        reduce(arr,reduceFn,init-el-value)
        // or 
        arr.reduce(reduceFn, init-el-value)
        
        // other array functions; used to build above
            forEach(func),  arr.length,  test(),  push(el), arr.indexOf(val)
    
// SPREAD OPERATOR (SYNTAX) a.k.a. REST SYNTAX; the `...` operator  
// `...args`; holds all args, except any preceeding it; USES:

    // 1. Use to create VARIADIC FUNC 
        a = (arg, ...args) => foo(arg, ...args)

    // 2. Use as "Arrayifier" to feed `.map()`, `.filter()`, ... etal

        const foo = (a, b) => [a, b]
        const bar = (...a) => a
        foo(4, 5) // [4, 5]
        bar(4, 5) // [4, 5]

        ;[...Array(parseInt("3")).keys()]         // [ 0, 1, 2 ]
        x = (a) => 2 * a
        ;[...Array(parseInt("3")).keys()].map(x)  // [ 0, 2, 4 ]

       // @ DOM :: HTMLCollection to Array (CONVERTS!); then filter els per condition
       nodes = parent.getElementsByTagName(tag)
       ;[...nodes].filter( (el,i) => {if (condition === met) return el} )

        var a,b,x  
        a = [1, 2, 3]
        b = [...a, 4, 5, 6]  // [ 1, 2, 3, 4, 5, 6 ] 

        x = (a,b,...c) => console.log(a,b,c)  
        x(1,2,3)          // 1 2 [ 3 ]
        x(1,2,3,4)        // 1 2 [ 3, 4 ]
        x(1,2,3,4,[1,2])  // 1 2 [ 3, 4, [ 1, 2 ] ]

    // ADAPTING args TO params  
    // FLJS  https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch3.md/#adapting-arguments-to-parameters
        function foo( [x,y,...args] = [] ) {/** */}

        var spreadArgs = a => b => a(...b)    // apply @ Ramba 

        var gatherArgs = a => (...b) => a(b)  // unapply @ Ramba

// DESTRUCTURING ASSIGNMENT SYNTAX :: COMMA-SEPARATED  (ES6) 
    // FPJS  https://github.com/getify/Functional-Light-JS/blob/master/manuscript/ch2.md#parameter-destructuring
    // MDN  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment

    // IF 
        var P = { fName: 'Adolph', lName: 'Goldberg' }
    // THEN, per DESTRUCTURING, ...
        var { fName, lName } = P

            fName  // Adolph
            lName  // Goldberg

            // VARIABLE name MUST BE an EXISTING PROPERTY name of the object; 
            // E.g., `var { foo, bar} = P` would FAIL

                // ES6 internally ...
                var fName = P.fName  // Adolph
                var lName = P.lName  // Goldberg

    // @ ARRAYs and OBJECTs 

        const [name1,name2] = ['bar1', 23, 'bar3']
        name1  // 'bar1'
        name2  // 23

        var foo = [1,'bar',{foo:1,bar:2},44,55,66]
        ;[first, second, third, ...bar] = foo  
            first   // 1
            second  // bar
            third   // { foo: 1, bar: 2 }
            bar     // [ 44, 55, 66 ]

    // @ PARAMs :: OBJECTs (UNordered pairs)
        function foo( {x,y} = {} ) { console.log( x, y ) }
        foo( { y: 3 } )  //=> undefined 3

        var key = 'foo', 
            val = 'bar'

        {key,val}       //=> { key: 'foo', val: 'bar' }

    // @ PARAMs LIST :: ARRAYs and OBJECTs and DEFAULTs
        var fn = ([a, b] = [1, 2], {x: c} = {x: a + b}) => a + b + c  // 1 + 2 + (1 + 2) 
        fn()  // 6

        function foo( [x,y,...args] = [] ) {console.log(x,y,args)}
        foo([1,2,3])  //=> 1 2 [ 3 ]


// BLOCK SCOPE per `{let .. }` [@ ES6]
    for (let i=0; i<10; i++) {/**/} // @ for-loop; per-iteration block scope !!!
    console.log(foo)   // 'ReferenceError: foo is not defined'
    
    {let foo = 'bar'}  // @ ANY arbitrary block, not merely @ function definition
    console.log(foo)   // 'ReferenceError: foo is not defined'

    // GARBAGE COLLECTION; PREVENT MEMORY LEAKs per `{let ..}`
    {let someHUGEdata = {/**/} /* now process it, inside this block */ } 
    // ... now, @ end of this block/scope, [compiler knows] can trash someHUGEdata

    // CONSTANT [@ES6] is BLOCK SCOPEd
        {const thisConst = 555 /* any attempt to change it herein generates error */ }
        console.log(thisConst)   // 'ReferenceError: thisConst is not defined'

        
// BUILT-IN PROTOTYPEs [properties|methods] per DATA TYPE
// https://github.com/cyberwizardinstitute/workshops/blob/master/javascript.markdown#BUILT-IN-prototype-methods

// BUILT-IN MATH  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math
    Math.pow(base, exp)  // exponentiation
    Math.log(n)          // natural log (base e)
    Math.exp(n)          // e raised to the power n
    Math.PI              
    Math.E
    Math.sin(x)          // sine of x in radians
    Math.cos(x)          // cosine of x in radians

// BUILT-IN :: DATE 
// must use constructor form; `new`
    // create a new date instance; now 
    new Date(x) // x can be date-string OR timestamp (milliseconds)

    new Date('2015-01-04 15:00') // 2015-01-04T20:00:00.000Z
    // Date.UTC(year[, month[, day[, hour[, minute[, second[, millisecond]]]]]])
    new Date(Date.UTC(96, 1, 2, 3, 4, 5)) // Fri, 02 Feb 1996 03:04:05 GMT

    Date.parse('04 Dec 1995 00:12:00 GMT') // 818035920000   (ms)
    Date.parse('01 Jan 1970 00:00:00 GMT') // 0

    // UNIX TIME :: MILLISECONDS since 1970-01-01 (Unix Epoch):
    new Date().getTime()  // 1563133231075

    // FROM MILLISECONDS; so if have SECONDS (10 digit unix timestamp), ...
    new Date(1549312452 *1000) // 2019-02-04T20:34:12.000Z // ISO 8601

    // PERFORMANCE PROFILING  
         // BETTER :: `performance.now()` vs `new Date`
            // https://developer.mozilla.org/en-US/docs/Web/API/Performance/now  
            performance.now() // precise to ±100μs;  strictly monotonic. 
            Date.now()  // precise to ±1ms; may go back in time per machine Date/Time.

        var t0, t1 
        t0 = performance.now()
        sleep(2000)  // measure this
        t1 = performance.now()
        console.log("Call to doSomething took " + (t1 - t0) + " milliseconds.")

        // + End the timer only when the browser is ready to flush the frame
        requestAnimationFrame(() => { metric.finish(performance.now()) })

        // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/now 
        // https://blog.superhuman.com/performance-metrics-for-blazingly-fast-web-apps-ec12efa26bcb 
        var d5 = Date.now()  // Note no new object(s) created; NO CALL of Date function itself.

            var start = Date.now()
            sleep(2000)  // measure this 
            var delta = Date.now() - start
            console.log( `delta = ${Math.floor(delta/1000)} seconds` )
            //=> "delta = 2 seconds" 

                // sleep() :: a blocking event
                function sleep(ms) {
                    let t0 = Date.now()
                    while (true) if ( ( Date.now() - t0 ) > ms ) break
                }

        // EVENT TIME 
            // User event does not register until AFTER whatever event loop may be running comes to an end. This distorts such metrics. To ACCURATELY MEASURE user events:  
            window.event.timeStamp // This (main) process is NOT blocked by current event loop. 


    // BUILT-IN DATE METHODS  
        var d = new Date 
        d.toString()                                    // Fri Jan 09 2015 10:18:26 GMT-0800 (PST)
        d.toUTCString()                                 // Fri, 28 Feb 2020 20:28:57 GMT
        d.toISOString()                                 // 2015-01-09T18:18:26.194Z
        d.valueOf()                                     // 1420827506194
        [ d.getFullYear(), d.getMonth(), d.getDay() ]   // [ 2015, 0, 5 ]
        [ d.getHours(), d.getMinutes(), d.getSeconds(), d.getMilliseconds() ]  // [ 10, 18, 26, 567 ]

    // TIMESTAMP :: CURRENT UTC TIME (zero UTC offset; "Z"; "Zulu")
        new Date()                  // 2019-07-16T15:26:36.483Z
        new Date().toISOString()    // 2019-07-16T15:26:36.483Z
        new Date().getTime()        // 1563133231075
        +(new Date())               // 1563133231075

        let d = new Date()
        d = d.getUTCDate() + '.' 
            + d.getUTCHours() + '.' 
            + d.getUTCMinutes() + '.' 
            + d.getUTCSeconds()  + '.' 
            + decodeURIComponent.getUTCMilliseconds() 
        // 14.19.36.59.931

// BUILT-IN RegExp  http://eloquentjavascript.net/09_regexp.html#h_ErccPg/l98
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp
    /pattern/flags   // RegExp LITERAL; flags: g [global/all], i [ignore-case], m,u,i
    
    // CHARACTER CLASSes
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp#character-classes
    // CHARACTER SETS
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp#character-sets
    
    // regexObj.exec(str); executes RegExp search; returns array or null
        // E.g., parse url
        var url = 'https://developer.mozilla.org/en-US/Web/JavaScript'
        var parsedURL = /^(\w+)\:\/\/([^\/]+)\/(.*)$/.exec(url)
        parsedURL  // ["https://deve...", "https", "developer.mozilla.org", "en-US/Web/JavaScript"]
        var [, , fullhost] = parsedURL
        fullhost  // 'developer.mozilla.org'

    // regexObj.replace(pattern, str) method on RegExp LITERAL
        "Borobudur".replace(/[ou]/, "a")  // replace 'o' and 'u' with 'a'
        "Borobudur".replace(/[ou]/g, "a") // replace ALL ...

    // regexObj.test(str) method on RegExp LITERAL; returns boolean
        /abc/.test("abcde")            // true
        /[0-9]/.test("in 1992")        // true 
        /^\/api\/parsetime/.test(url)  // test if  url === '/api/parsetime'
        /[^01]/.test(100011010111)     // false; ^*  except *

        // E.g., test() on a digit class, '\d', RegExp ...
        var dateTime = /\d\d-\d\d-\d\d\d\d \d\d:\d\d/ 
        dateTime.test("30-01-2003 15:20")  // true

    // TypeError :: throw new TypeError('MSG')
        function assertSomeFoo(someFoo) {
            if (typeof someFoo !== 'string') {
                throw new TypeError('\`someFoo\` must be a string')
            }
        }

    // Error :: throw new Error('MSG')
        throw new Error(`The property \`${foo}\` already exists on 'bar'`)

        x = (function aName1() {throw new Error(`Stack Trace reports @ 'aName'`)})()
        x = (() => {throw new Error(`Stack Trace reports @ 'x'`)})()
        x = (async () => {throw new Error(`Stack Trace reports @ ... (nowhere).`)})()

    // SELF :: JS script PATH|FNAME (works @ URL & FS)  ... Any ...
        // @ self.HTML
        console.log( `@ ${(o.location).toString()
            .substring((o.location).toString().lastIndexOf('/')+1)}` )

        // @ self.anywhere :: NOT STANDARD :: DO NOT USE 
        console.log( `@ ${(new Error).fileName
            .substring((new Error).fileName.lastIndexOf('/')+1)}` )

        // @ <script src="selfScript.js">
        console.log( `@ ${document.currentScript.src.
            substring(document.currentScript.src.lastIndexOf('/')+1)}` ) 

// FUNCTIONs [complex-primitive; object sub-type]

    // FUNCTION DECLARATION [args optional]; hoisted, as are variable declarations
    function aFn(arg1, arg2, ..) {
        /* code */
    }
    // FUNCTION EXPRESSION [args and privateName optional]
    var publicName = function privateName(arg1, ..) {
        /* code */
    } 
    // FUNCTION EXPRESSION [args and privateName optional]
    (function privateName(arg1, arg2, ..) {
        /* code */
    })

    // * In Function EXPRESSIONS, the optional function name is NOT VISIBLE outside its scope.
    // * LAMBDA FUNCTION is a function without a name; a.k.a. ANONYMOUS FUNCTION.
    // * Js oddity: ONLY functions can create LOCAL SCOPE
    
        // to SET GLOBAL in FUNCTION, 
        //  create property on global object ...
        function foo(a,b) {
            // global ...
            globalFoo = "I'm Global"        // @ browser   [FAILs @ Node.js]
            window.globalFoo = "I'm Global" // @ browser   [FAILs @ Node.js]
            global.globalFoo = "I'm Global" // @ Node.js   [FAILs @ browser]
            // not global ...
            var globalFoo = 'Nope!' // NOT global
            return {bar:globalFoo}  // returns locally-defined globalFoo
        }
        // access ...
        globalFoo        // ERR; undefined
        foo()            // 'Nope!' [but sets globalFoo GLOBAL]
        globalFoo        // 'I\'m Global'
        foo().globalFoo  // ERR; undefined
        foo().bar        // 'Nope!'
        
        foo.length        // ARITY; number of args EXPECTED
        arguments.length  // number of args @ the current CALL 
    
        // GET FUNCTION NAME (OF SELF)
            function foo() {
                selfName = arguments.callee.name // 'foo'
            }
            // or @ ...
            x = foo
            x.name   // 'foo'

        // GET FUNCTION DESCRIPTION / BODY (stringified)
        foo.toString()  // 'function foo() {\n    selfName = ... \n}'

    // IIFE (Immediately-Invoked Function EXPRESSION) 
    // a.k.a. "auto-run" a.k.a. "self-executing function"
    // parens wrapper forces parser to treat as an EXPRESSION, not as a declaration
    // thus optional name is private, so written as lambda, unless self-reference needed
    // https://en.wikipedia.org/wiki/Immediately-invoked_function_expression
    // http://benalman.com/news/2010/11/immediately-invoked-function-expression/
    (function privateName() {
        /* code */
     }())
     
    // 2 equal syntaxes ; Crockford prefers 1st
    (function () { /* code */ }())  
    (function () { /* code */ })()

    // Passing variables into scope ...
    (function (a, b) {
        /* code */
    })("foo", "bar")

    // named IIF 
    (foo = function (var1) {console.log(var1 || "No variable")}())

    // IIFE (IIF expression); can be lambda (anonymous function)
    var varIsFnX = (function X() {/**/}())

    // Closure
    // maintain access to PRIVATEvarX; everywhere and always
    // Think "close" as in "trap" the scope
    function X() {
        var PRIVATEvarX = ObjX

        return function closureX() {
            return PRIVATEvarX['key17']
        }
        return closureX
    }
    closureX()  // has lexical scope access to inner scope of X(), 
                            // even here outside its declared lexical scope
                            // closureX() "closes over X()"; Confusing lingo; 
                            // would be more appropriate to say "closes duing X()" or "closes under X()"

        // Using CLOSURES to replace the "this" 
        // http://radar.oreilly.com/2014/03/javascript-without-the-this.html
        //
            // -- per this [without closure] --
            function createCar(numberOfDoors){
                this.numberOfDoors = numberOfDoors
                this.numberOfWheels = 4
             
                this.desc = function () {
                    return "I have " + this.numberOfWheels +
                        " wheels and " + this.numberOfDoors + " doors."
                }
            }
            // usage ...
            var sportsCar = new createCar(2)
            sportsCar.desc()

            // -- per closure --

            function createCar(numberOfDoors) {  // Constructor Function
                var numberOfWheels = 4
             
                function describe() {
                    return "I have " + numberOfWheels +
                        " wheels and " + numberOfDoors + " doors."
                }
             
                return {
                    desc: describe  // returns an object that only exposes the public behavior of that type
                }
            }
            // usage ...
            var sportsCar = createCar(2)
            sportsCar.desc()

    // IIFE used TO HIDE/PROTECT A VAR; functions create local scope 
    // [a.k.a. 'lambda' or 'bare anonymous function']
        var a = 1
        var b = 2

        (function () {
            var b = 3  // hidden/protected
            a += b     // a is global; is only reset, NOT declared, here
        }())
        a  // 4
        b  // 2

    // `arguments` is a BUILT-IN OBJECT available to all functions 
    // ALL args passed to func are accessible thereof
        function foo() {console.log(arguments)} // NOTE: NO explicitly DECLARED args
        foo(1,2)  // { '0': 1, '1': 2 }

    // @ Node.js cli (@ Windows-OS) GLOBAL: process.argv array
        node.exe file.js arg1, arg2, ..  // passing arguments @ file call
        process.argv           // [node.exe-path, script-path, arg1, arg2, ..]
        process.argv[2]        // arg1
        process.argv.slice(2)  // [arg1, arg2, ..]
        
    // INVOKE a FUNCTION ...
        aFn()   // invokes function
        aFn     // returns function declaration [definition]

            function foo() {return 'bar'}
            foo()  // 'bar'
            foo    // function foo() {return 'bar'}
        
        (function foo() {return 'bar'}) // 'foo' is PRIVATE; [Function: foo]
        foo()  // 'ReferenceError: foo is not defined'

        var foo = function privatefoo() {return 'bar'}
        privatefoo()  // 'ReferenceError: foo is not defined'
        foo()         // 'bar'
        foo           // function privatefoo() {return 'bar'} 
        
        var foo = function () {return 'bar'}       // lambda
        foo()         // 'bar'
        foo           // function privatefoo() {return 'bar'}
        
        var foo = (function () {return 'bar'})    // lambda
        foo()         // 'bar'
        foo           // function privatefoo() {return 'bar'}
        
        var foo = (function () {return 'bar'})()  // IIFE
        foo()         // 'TypeError: foo is not a function'
        foo           // 'bar'
        
        // INVOKE a CURRIED function 
            aFn()()().. 
            // n times to get value of n-ary func
            // Ex. curried function; replaces a binary func with two unary funcs
            function aFn(x) { 
                return function(y) {
                    return x + y
                }
            }
            aFn(1)(2) // <<< INVOKE curried function
        
// CALLBACK; trust issue, "inversion of control" issue; lack of sequentiality; lack of trustability
// https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch2.md
// setTimeout() :: CBfunc, the callback function, runs @ #-msec-delay after end of event loop
    setTimeout( CBfunc, millisecs-delay )
    // "split-callback style" 
    asyncFn( param, CB@success, CB@failure )  
    // "Node style"; "error-first style" 
    asyncFn( CB@err, CB@data )  // err is null on success, else err truthy and data undefined 

// PROMISES; immutable upon resolved; mechanism for encapsulating and composing future values.
// Promises normalize asynchrony and encapsulate time-dependent value state, thus chainable.
// asynch; never rely on anything about the ordering/scheduling of callbacks across Promises.
// https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch3.md

    // CONSTRUCTOR; create a promise; only to wrap functions that don't inherently support promises
        var p = new Promise( function(resolve,reject){  // "Revealing Constructor";idiotic name
            // RESOLUTION FUNCTIONs (callbacks)
            //   resolve() for fulfillment [usually]
            //    reject() for rejection   [always]
        } )
        
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
        
    // Design Patterns 
        foo(p) { p.then( onResolved, onRejected ) }
        // or 
        barSuccess()
        barFail()
        p.then( barSuccess, barFail )

        p.then( onResolved, onRejected )
        // or
        p.then( onResolved ).catch( onRejected ) // better

        // handle rejections only ...
        p.then(null,function(err){/**/}) /* <= equiv => */ p.catch(function(err){/**/})

    // Thenable Duck Typing; need to know if something is a promise

// CALLBACK HELL; it's not about indentation; it's about the brittle nature of hardcoding nested callbacks, and the visual back-and-forth, from function callback to function definition, required to comprehend the code.

// ASYNCH AWAIT; ES7; incorporates generators; return implicitly wrapped in Promise.resolve; cleaner code than promise/then
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function
// https://hackernoon.com/6-reasons-why-javascripts-async-await-blows-promises-away-tutorial-c7ec10518dd9
    const makeRequest = async () => { // RETURNS a PROMISE
        try {
            const data = JSON.parse(await getJSON()) // (a)wait for getJSON() PROMISE to RESOLVE
            console.log(data)
        } catch (err) { // catch ALL asynch/synch errs @ one code, unlike @ promise/then
            console.log(err)
        }
    }	
    makeRequest()

// GENERATORS (ES6); synchronous-looking async code; flow control per keywords;
// preserve a sequential, synchronous, blocking code pattern for async code, 
// making callback-based async more human-reasonable
// https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch4.md
    // `yield ..` / `next(..)` forms cooperative pause/resume interchange btwn generator/iterator; 
    // control mechanism AND 2-way message-passing mechanism; ITERATION MESSAGING
    // the generator, at each `next()` iteration, returns an object accessible per `.value`
    // Each "constructed" iterator is a separate instance of a generator
    // 1st `next()`, sans args, starts a generator, which runs to the 1st `yield ..`; 
    // 2nd `next(..)` fulfills the 1st paused `yield ..` expression
        function *gen(a) { yield 'yield-1'; yield 'yield-2'; return 2 * a } // generator
        
            var it = gen(5)                       // iterator; `{}` (always)
            it.next()                             // 1st iteration; NEVER has an arg
                { value: 'yield-1', done: false } // status; `gen()` PAUSEd per 1st `yield`
            it.next().value                       // 2nd iteration; return `value` property of the object
                'yield-2'                         // status; `gen()` PAUSEd per 2nd `yield`
            it.next()                             // 3nd iteration 
                { value: 10, done: true }         // status; done
            
            it                                    // {}
            it.next() 
                { value: undefined, done: true }
            
            // can be INTERLEAVEd
            val1 = it1.next( val2 * 2 ).value 
            val2 = it2.next( val1 * 5 ).value 
            
            // ITERATOR INTERFACE METHOD [standard pattern], inside a generator
            // https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch4.md#producers-and-iterators
            
                // COMPUTED PROPERTY NAME (syntax); an expression; use result as name (key) for property (val)
                    [Symbol.iterator]: valX  // k-v pair; setting a property of an object

            // ITERABLEs; an object that contains an iterator 
            // BUILT-IN ITERABLES 
                String, Array, TypedArray, Map, Set

                // SPREAD OPERATOR uses iteration internally 
                    [...'hi']   // [ "h", "i" ]

                // Map()  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map 

                // Set()  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set 
                // Has redundant k-v structure, where k=v, allowing for iterable (object) methods.
                    s = new Set()  
                    s.add('foo')
                    s.add({a:1,b:2})
                    s.forEach((k,v) => console.log(k,v))
                    s.has('foo')
                    s.delete('foo')

                    [...s]       // CONVERT to a regular Array 

                    s.values()   // all
                    s.keys()     // same as values 
                    s.entries()  // all k,v
                    var it = s[Symbol.iterator]()
                    it.next()    // { value: 'foo', done: false }
                    it.next()    // { value: {a:1,b:2}, done: false }
                    it.next()    // { value: undefined, done: true }


                // ITERATION PROTOCOL 
                // to retreive iterator, an iterable must have a function on it, with the name being the special ES6 symbol value `Symbol.iterator`. When this function is called, it returns an iterator
                    var it = a[Symbol.iterator]()   // iterator function call; all in one step
                    it.next().value  // 1
                    it.next().value  // 3
                    it.next().value  // 5
                    
            // ITERATING GENERATORS ASYNCHRONOUSLY
            // https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch4.md#iterating-generators-asynchronously
            
            // GENERATORS + PROMISES
            // https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch4.md#generators--promises
            // yield a Promise, and wire that Promise to control the generator's iterator

            // GENERATOR CONCURRENCY 
            // https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch4.md#generator-concurrency
            // Use: coordinating/ordering a set of network req/resp
            
// MESSAGE CHANNEL https://developer.mozilla.org/en-US/docs/Web/API/MessageChannel 
    // SYNCH per MSG PASSING (CSP); channels are useful for coordinating concurrent tasks that might running on separate threads; just as useful in a single-threaded environment; solve general problem of coordinating anything that's asynch.

    // GENERATORS + [CSP] CHANNELS [i.e., Clojure's "core.async"]
    // ... pre ES6; pre asynch/await
    // http://jlongster.com/Taming-the-Asynchronous-Beast-with-CSP-in-JavaScript
        // CSP; handles coordination between processes via messsage passing; `go` spawns a process; `chan` creates a channel; `take`, `put` gets/puts a value from/to a channel and blocks if channel not available

    // MSGs to IFRAME  https://developer.mozilla.org/en-US/docs/Web/API/MessageChannel/MessageChannel#Example
    // MSGs to WEB WORKERs (See below)

// WEB APIs (NON-JAVASCRIPT)  https://github.com/getify/You-Dont-Know-JS/blob/master/up%20%26%20going/ch2.md#non-javascript

    // EVENT LOOP  https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch1.md#event-loop
    // hosting environment mechanism to schedule "events" (chunks of code); JS spec as of ES6; each iteration of the event loop is a "tick".
    // JOB QUEUE; JOBs; ES6; a queue hanging off the end of every tick in the event loop queue; take priority over subsequent event loop(s).
    
    // WEB APIs :: Event Handlers 
    // https://developer.mozilla.org/en-US/docs/Web/API/GlobalEventHandlers
    // DOM API     https://www.w3schools.com/js/js_htmldom_methods.asp
    // HTML DOM    https://www.w3schools.com/jsref/dom_obj_document.asp
    // https://github.com/cyberwizardinstitute/workshops/blob/master/dom.markdown#the-dom
    // DOM EVENTS  https://www.w3schools.com/jsref/dom_obj_event.asp
        document         // host object; global, per browser engine
        getElementById() // DOM built-in method; browser; Web API 

        var el = document.getElementById( "foo" )
        
    // WEB WORKERs  https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch5.md#web-workers
    // multiple instances of JS engine, each @ separate thread, one script per thread;
    // separate env per thread; NO globals nor DOM access; but CAN COMMUNICATE btwn threads; 
        // MESSAGE CHANNELs :: EVENT LISTENER + TRIGGER; symmetric comms btwn (sub)worker(s) and creator:
            // https://developer.mozilla.org/en-US/docs/Web/API/MessageChannel 
            // http://jlongster.com/Taming-the-Asynchronous-Beast-with-CSP-in-JavaScript

        // Instantiate "DEDICATED WORKER"; typically from web page, except if a sub-worker 
            var w1 = new Worker( "http://some.url.1/web_worker_1.js" ) 
        
        // @ (main) web page (script) 
            w1.addEventListener( "message", function (ev) {/*...*/ ev.data /*...*/}) // listen to web worker #1
            w1.postMessage( "Message TO web worker #1" ) // send message to web worker #1
            
        // @ web_worker_1.js has 1-to-1 relationship with creator (page)
            addEventListener( "message", function (ev) {/*...*/ ev.data /*...*/})    // listen to web page
            postMessage( "Message FROM web worker #1" ) // send message to any creator

        // HAS own GLOBALs; navigator, location, JSON, and applicationCache; future <canvas>, WebGL access; 
        // CAN load extra JS scripts
            importScripts( "foo.js", "bar.js" )  // @ web_worker_1.js
        
        // DATA TRANSFER  https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch5.md#data-transfer

        // SHARED WORKERS  https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch5.md#shared-workers
        
    // asm.js  https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch5.md#asmjs
    
    // OUTPUT
        alert()
        console.log()
        // overwrite entire doc 
        <button onclick="document.write(5 + 6)">document.write(5 + 6)</button>

        // insert str @ html element (html-tag) having id="target_el"
        var str = 'Insert this string'
        document.getElementById("target_el").innerHTML = str

        // ... above as a function ...
        function writeThis(str) {
            document.getElementById("target_el").innerHTML = str
        }
        writeThis('this')

    // console.METHOD [Web API]  https://developer.mozilla.org/en-US/docs/Web/API/Console
    // (a)synch console I/O behavior per hosting environment; if causing debug issue, then take snapshots of objects, and I/O later; e.g., using JSON.stringify(..)
        console.log('%cThis text will now be blue and large', 'color: blue; font-size: x-large') 
        console.info(); console.debug(); console.warn(); console.error()

    // Global DOM Variables
    var foo // creates window.foo, global.foo property  
    // creating DOM elements with id attributes creates global variable
    <div id="foo"></div>
    // then ...
    if (typeof foo == "undefined") { /* NEVER executes */ }
    console.log( foo )  // HTML element
    
    // .accessKey :: Set the access key of a link:
        document.getElementById("myAnchor").accessKey = "w"
        // user @ Firefox :: ALT + SHIFT + <accessKey>

    // location.reload() :: reload page
        <button onclick="location.reload()">location.reload()</button>
        
// BENCHMARKING [Benchmark.js]  https://benchmarkjs.com/
// jsPerf.com  https://jsperf.com/
// Tail Call Optimization (TCO)  https://github.com/getify/You-Dont-Know-JS/blob/master/async%20%26%20performance/ch6.md#tail-call-optimization-tco
    return foo( y + 1 )   // tail call; faster and less memory; runs foo() @ current func memory stack
    return 1 + bar( 40 )  // not tail call

//=====================================================================

// PATTERNS 
        
    // CONSTRUCTOR CALL
    
        // define 
        function fooFn () {
            this.method = something // `return` implicitly per constructor 
        }
        // CALL/use/invoke ...
        var n = new fooFn()  // ... MUST use `new` @ each invocation
    
            // ... OR, per TRICK; handle `new` @ function definition ... 
            
            // define
            function fooFn () { // `new` handled here, @ func definition
                if (!(this instanceof fooFn)) return new fooFn(value)
                /* code */
            }
            // use/invoke ...
            var n = fooFn(); // ... sans `new` 
    
    // MODULE PATTERN 
    // same as singleton below, but w/out IIFE; fooModule can be invoked any number of times, each time creating a new module instance.  https://github.com/getify/You-Dont-Know-JS/blob/master/scope%20%26%20closures/ch5.md#modules
    
    // MODULE PATTERN :: SINGLETON 
        var x = x || (function(){return {a:'bar',b:3}})()
        x    // { a: 'bar', b: 3 }
        x.a  // 'bar'
        x.b  // 3

        // declare an object using an IIFE
            var App = App || (function() {
                // 1. declare/define/protect its properties and methods
                var propFoo = 'foo'   // private property
                function funcBar(s) { // private method [closure]
                    return propFoo + ' bar ' + s 
                }
                // 2. return/expose its public behavior only
                var publicAPI = { 
                    foo: propFoo,
                    bar: funcBar
                }
                return publicAPI
            }())
        
        // or, simply as the object therein; the content of the module 
            var App = {/**/} // pattern used by Node.js 
        
        // invoke ...
            App.foo         // 'foo'
            App.bar('baz')  // 'foo bar baz'
            App             // { foo: 'foo', bar: [Function: funcBar] }


        // MODULE IMPORT/EXPORT  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules

            // @ main.js
                export const fooConst = 'exported constant'
                export var fooVar = 'exported var'
                export function fooFn(a,b,c) {
                  // ...
                }
                // OR, better, all at once, so no need to prepend `export ...` to each.
                export { fooConst, fooVar, fooFn }
                // then, @ the file (importing.js) importing the exported ...
                import { fooConst, fooVar, fooFn } from '/path/to/modules/exports.js'
                // ... can now use ...
                let x = fooFn(arg1,arg2,arg3)

                // IMPORT and EXPORT STATEMENTS are ALLOWED ONLY inside modules; not regular scripts

                // @ HTML, declare as top-level module, the script IMPORTING the module(s).   
                <script type="module" src="imports.js"></script> 
                // OR inline ... 
                <script type="module">/* script here */</script> 

                // RENAMING 
                    // inside exports.js
                    export {
                        func1 as newFnName,
                        func2 as anotherNewFnName
                    };
                    // inside imports.js
                    import { newFnName, anotherNewFnName } from '/modules/exports.js';

                    // OR 

                    // inside exports.js
                    export { funcA, funcB }

                    // inside imports.js
                    import { 
                        funcA as newFnName,
                        funcB as anotherNewFnName 
                    } from '/modules/exports.js'

            // @ Node.js pattern 
                // @ exporting.js
                var App = {/**/}
                module.exports = App
                // @ importing.js
                require('./exporting.js')

    // REVEALING PROTOTYPE  https://scotch.io/bar-talk/4-javascript-design-patterns-you-should-know
    // stupid name; private properties/methods are protected; NOT "revealed" aka exposed [externally]
        var publicVar = function() {
            this.prop1 = val1
            this.prop2 = val2
        }
        // REVEALING PROTOTYPE to ADD METHODS to existing var
        publicVar.prototype = function() {
            var privateMeth1 = function() {
                //... 
            }
            var privateMeth2 = function() {
                //...
            }
            return {
                pubMeth1: privateMeth1,
                pubMeth2: privateMeth2
            }
        }()

    // EVENT LISTENER BINDINGs [attach an html element to a javascript handler]
    
        // @ main.js [orthogonal to .html]
        var app = (function() {
                function eventHandler() {/* do stuff on event */}

            return { // expose functions by reference, per app.{METHOD}
                eventButton: (eventHandler) //,
                //otherListener: (otherHandler)
            }
        }())
        
        // @ index.html [orthogonal to .js]
        <button id="eventButton">Trigger</button>

        <script> // binds per el.addEventListener()
            (function () { //  el <==[click]==> app.{METHOD}
                var eventButton = document.getElementById('eventButton')
                eventButton.addEventListener('click', app.eventButton)  
            }())
        </script>

    // SET DEFAULT
        // replace the following ... 
        function documentTitle(theTitle)
            ​if (!theTitle) {
                theTitle  = "Untitled Document"
            }
        }
        // ... with this equivalent ...
        function documentTitle(theTitle)
            theTitle = theTitle || "Untitled Document"
        }

    // SIMPLIFIED SYNTAXes ...

        // replace the following ... 
        function isAdult(age) {
            if (age && age > 17) {
            return true
        }
        ​else {
            return false
            }
        }
        // ... with this equivalent ...
        function isAdult(age) {
             return age && age > 17 
        } // i.e., returns boolean; the "else false" is implied
        
        // replace the following ... 
        if (userName) {
            logIn(userName)
        }
         else {
             signUp()
        }
        // ... with this equivalent ...
        userName && logIn(userName) || signUp()
        // {condition} && {if true} || {if false}
    
        // TERNARY 
        a ? if_True : if_False

    // returns boolean (false if true) 
    !function //... 

