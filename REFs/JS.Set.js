// Set() :: A collection of UNIQUE elements; a map, but key = value; https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set

// LAB :: Set()
;(()=>{
    // Want idempotent registry of functions. 
    // Different functions, in differing contexts, may have SAME NAME. 

    const fnsSet = new Set()
    const reg = (fn) => fnsSet.has(fn) || fnsSet.add(fn) 

    const fn1 = () => true
    const fn2 = (a) => 2*a
    const fnNot = () => false
    reg(fn1)
    reg(fn1)
    reg(fn2)
    ;(function foo(){ 
        const fn2 = (a,b) => a+b 
        reg(fn2)
        reg(fn2)
    })()

    var fnsList = fnsSet.entries() // iterator REQUIRED
    for (let fn of fnsList) {log( fn )}
    // Array [ fn1(), fn1() ]
    // Array [ fn2(), fn2() ]
    // Array [ fn1(), fn1() ]

    var fnsList = fnsSet.values()
    for (let fn of fnsList) {log( fn(1,2) )}
    // true 
    // 2 
    // 3

    // Match 
    const matchFn = (fn) => {
        var fnsList = fnsSet.values()
        for (let fn of fnsList) {
            if (fn1 === fn) return fn
        }
    }
    log('Matched', matchFn(fn1), 'to', fn1) // function fn1

    // Transform into obj having UNIQUE KEYS
    const fnsObj = {}
    var fnsList = fnsSet.values()
        ,i = 0
    for (let fn of fnsList) {
        i++
        fnsObj[`${fn.name}.${i}`] = fn
        //log(fn)
    }
    log(fnsObj)
    // { "fn1.1": fn1(), "fn2.2": fn2(), "fn2.3": fn2() }

    // Match per ID
    const matchID = (fn) => {
        return Object.keys(fnsObj)
                .filter(key => fnsObj[key] === fn)
    }
    log('MatchID', fn1 , 'to', matchID(fn1))    // ["fn1.1"]
    log('MatchID', fnNot, 'to', matchID(fnNot)) // []
})()