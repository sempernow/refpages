// @ FLJS  https://github.com/getify/Functional-Light-JS#book  
// @ MAG   https://mostly-adequate.gitbooks.io/mostly-adequate-guide/appendix_a.html  

var identity = a => a

var constant = a => () => a

var unary = fn => a => fn(a)

var not = (predicate) => (...args) => !predicate(...args)

var apply = fn => a => fn(...a)      // spreadArgs

var unapply = fn => (...a) => fn(a)  // gatherArgs

var partial = (fn, ...a) => (...b) => fn(...a, ...b)

var partialRight = (fn, ...a) => (...b) => fn(...b, ...a)

var reverseArgs = fn => (...a) => fn(...a.reverse())

var curry = fn => {
    const arity = fn.length
    return function $curry(...args) {
        if (args.length < arity) {
            return $curry.bind(null, ...args)
        }
        return fn.call(null, ...args)
    }
}

var uncurry = fn => {
    return function uncurried(...args) {
        var rtrn = fn

        for (let i = 0; i < args.length; i++) {
            rtrn = rtrn( args[i] )
        }
        return rtrn
    }
}

var compose = (...fns) => {
    // pull off the last two arguments
    var [ fn1, fn2, ...rest ] = fns.reverse()

    var composedFn = (...args) => fn2( fn1( ...args ) )

    if (rest.length == 0) return composedFn

    return compose( ...rest.reverse(), composedFn )
}

var pipe = reverseArgs( compose )

var getProp =  (k, o) =>  o[k]

var setProp = (k, o, v) => {
    var o = Object.assign( {}, o )
    o[k] = v
    return o
}

var makeObjProp = (k, v) => setProp( k, {}, v )

function zip(a1, a2) {
    var zipd = []
    a1 = [...a1]
    a2 = [...a2]
    while ( ( a1.length > 0 ) && ( a2.length > 0 ) ) {
        zipd.push( [a1.shift(), a2.shift()] )
    }
    return zipd
}

var uniqueWords = a => unique( words( a ) )

var unique = wordsArr => {
    var uniqList = []
    for (let v of wordsArr) {
        if (uniqList.indexOf( v ) === -1 ) 
            uniqList.push( v )
    }
    return uniqList
}

var words = str => {
    return String(str)
        .toLowerCase()
        .split( /\s|\b/ )
        .filter( v => /^[\w]+$/.test( v ) )
}

var tnarySelf = (a) => {
    return (b) => { 
        b ? b : false
        return a ? a : b
    }
}  // tnarySelf(a)(b)

// =========

var identity =
    v =>
        v

var constant =
    v =>
        () =>
            v

var unary =
    fn =>
        arg =>
            fn(arg)

var not = 
    (predicate) => 
        (...args) => 
            !predicate(...args)

var apply =
    fn =>
        argsArr =>
            fn(...argsArr)

var unapply =
    fn =>
        (...argsArr) =>
            fn(argsArr)

var partial =
    (fn, ...presetArgs) =>
        (...laterArgs) =>
            fn(...presetArgs, ...laterArgs)

var reverseArgs =
    fn =>
        (...args) =>
            fn(...args.reverse())

var partialRight =
    (fn, ...presetArgs) =>
        (...laterArgs) =>
            fn(...laterArgs, ...presetArgs)

var curry = 
    fn => {
        const arity = fn.length

        return function $curry(...args) {
            if (args.length < arity) {
                return $curry.bind(null, ...args)
            }
            return fn.call(null, ...args)
        }
    }

var compose =
    (...fns) => {
        // pull off the last two arguments
        var [ fn1, fn2, ...rest ] = fns.reverse()

        var composedFn =
            (...args) =>
                fn2( fn1( ...args ) )

        if (rest.length == 0) return composedFn

        return compose( ...rest.reverse(), composedFn )
    }    

var pipe = 
    reverseArgs( compose )

var pipe = 
    (...fns) => 
        (result) => {
            var list = [...fns]
            while (list.length > 0) {
                result = list.shift()( result )
            }
            return result
        } 

var getProp =
    (k,o) =>
        o[k]

var setProp = 
    (k,o,v) => {
        var o = Object.assign( {}, o )
        o[k] = v
        return o
    }

var makeObjProp =
    (k,v) =>
        setProp( k, {}, v );