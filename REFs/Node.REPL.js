// Node.js :: REPL API 
// https://nodejs.org/api/repl.html

// launch REPL ...
    node 
// run a script 
    node foo.js
    // optional args, e.g., run a script ...
        node [options] [v8 options] [foo.js | -e "foo"] [arguments]

// GLOBALs
    process
    process.argv  // ['node.exe path', 'script-path', arg1, arg2, ...]
    console
    global        // browser 'window' equivalent
    Buffer        // to store binary data; file reads, or receiving network packets

// MODULEs 

    // Export :: Must EXPORT for GLOBAL scope, else all is LOCAL.
    module.export = {}
    export.foo = 'bar' // Don't use; use `module.export`

    module.paths       // Module system search paths; CSV list of all paths searched @ require(...)
                       // INCLUDEs its PARENT; ./../node_modules, so multiple projects can share one `npm install ...`

    // Import ...
    var modName = require ("moduleName")

// editor mode 
    .editor 

// load FILE_PATH into REPL
    .load foo.js

// exit ...
    .exit // or CTRL+D, or CTRL+C [twice]

// passing arguments @ file call; GLOBAL: process.argv
    `node.exe file.js arg1, arg2, ...` 
    process.argv           // [node.exe-path, script-path, arg1, arg2, ...]
    process.argv[2]        // arg1
    process.argv.slice(2)  // [arg1, arg2, ...]
    

// special variable _ (underscore)
// by default, is assigned the result of most recently evaluated expression
    [ 'a', 'b', 'c' ]; _.length
    // 3
    _ += 1 // DISABLES default behavior; informs ...
    // Expression assignment to _ now disabled.
    // 4
    [ 'a', 'b', 'c' ]; _.length
    // undefined
    
// methods  
    process.cwd() // current working dir 
    
// CORE MODULEs
//  ~ 24 modules; small; tools for cross-platform handling of common I/O protocols/formats.

    // EVENTs  https://github.com/maxogden/art-of-node#events
    emitter.on(eventName, listener) // subscribes a callback (listener) to an event 
    // STREAMs  https://github.com/substack/stream-handbook#basics