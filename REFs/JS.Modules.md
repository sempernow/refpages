
# [Modules](http://exploringjs.com/es6/ch_modules.html "exploringjs.com") / Module Patterns

## tl;dr 
Virtually all modules are __CommonJS__, of the Node.js / `npm` ecosystem, and so require Babel or some such compiler along with their chain of bundlers/builders/..., all from that black-hole of dependency hell, to "_broswerify_" it. We've gone from _spaghetti code_ to recursively dependent modules. 

Though each is atomic, such is fractal. That is, the modules are not separable, and that includes their build tools too. That's _spaghetti code_ with superglue as the sauce. 

_Want to change the color of a component element? Well, you'll first have to update and manually repair the broken build tool chain from its year-old repo. And then start working on all its dependencies. Have a fun year._

## (Nebulous) Lingo 
The term ___module___ in the javascript world is generally applied to script(s), function(s), object(s), name(s), and/or _whatev(s)_; both or either importing and/or exporting any such thing(s). Anytime and everywhere the context is about injecting any javascript thing from __one file__ into some scope at __another file__, its all about "___the module___". 

## AMD / [RequireJS](https://requirejs.org/docs/whyamd.html "Requiresjs.org") Modules

- Asynchronous Module Definition (AMD)
- ___For browers___; allows ___asynchronous loading___.
- __RequireJS__ is _the most popular implementation_ of AMD 
- More complicated syntax, and `eval()` (a compilation step)

### ___Incompatible with CommonJS___ modules

- Hence the ___labyrinth of dependency managers___; Webpack and such.

```js 
define(['require', 'dependency1', 'dependency2'], function (require) {
    var dependency1 = require('dependency1'),
        dependency2 = require('dependency2');

    return function () {};
});
```

## [CommonJS](https://en.wikipedia.org/wiki/CommonJS "@ Wikipedia") / Node.js Modules 

- ___For servers, not browsers___; ___synchronous loading___; _pure genius!_ 
- Node.js modules are _based on this standard_, and extend it.
- Compact syntax.

### ___Must be bundled___ for browser
- Hence the ___labyrinth of dependency managers___; Webpack and such.

- ___Convert___ from __CommonJS to ES6__ modules  
`Rollup.js` ([MD](Rollup.js.html "@ browser"))   

### CommonJS Export @ `exporter.js`

```js
module.exports.func1Exported = func1Private
// and/or 
module.exports = func2
// and/or 
exports.func3Exported = func3
// and/or 
module.exports = {
    someFunc2: aFuncX,
    someThing: aFunc1('aArg')
}
// and/or
var otherModule= require( "path/to/module/foo" );
exports.aFooFunc99 = function(){
    return otherModule.someFunc3();
}
```

### CommonJS Import @ `importer.js`

```js
// Import
// IF @ ./node_modules or ~/node_modules
const o = require('exporter')  
// Else, ... abs|rel path ...
const o = require('path/to/exporter') 
// Use
o.func1Exported()
const bar = o.func2
o.func3Exported()
o.someFunc2()
const x = o.someThing
o.aFooFunc99()
```

- [Import per `require()`](https://www.freecodecamp.org/news/requiring-modules-in-node-js-everything-you-need-to-know-e7fbd119be8/ "'Requiring Modules in Node.js ...' @ FreeCodeCamp.org")
-  Note the __file__ being imported is referenced ___sans extension___ (`.js`).

## [UMD](https://github.com/umdjs/umd "@ GitHub") (Universal Module Definition)

A pattern supporting __CommonJS__, __AMD__,  and the [Global (`global`)](https://developer.mozilla.org/en-US/docs/Glossary/Global_object) Window object:

```js
(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD
        define(['jquery', 'underscore'], factory);
    } else if (typeof exports === 'object') {
        // Node, CommonJS-like
        module.exports = factory(require('jquery'), require('underscore'));
    } else {
        // Browser globals (root is window)
        root.returnExports = factory(root.jQuery, root._);
    }
}(this, function ($, _) {
    //    methods
    function a(){};    //    private because it's not returned (see below)
    function b(){};    //    public because it's returned
    function c(){};    //    public because it's returned

    //    exposed public methods
    return {
        b: b,
        c: c
    }
}));
```

## [ES6 Modules](https://exploringjs.com/es6/ch_modules.html#sec_basics-of-es6-modules "exploringjs.com")

- ___For both servers and___ [___browsers___](https://exploringjs.com/es6/ch_modules.html#sec_modules-in-browsers)
- No dependency manager required.
- [___3x slower___ than an optimized bundle](https://v8.dev/features/modules#bundle "v8.dev"); time to first render.
- Compact, declarative syntax
- Support for cyclic dependencies.
- Support for _asynchronous_ loading
    - Programmatic loader API; configurable loading.
- Can be statically analyzed.

### Support (sort of)

- Chrome/Firefox/Edge/Safari
    - [@ `<script>`](https://caniuse.com/#feat=es6-module "@ CanIUse.com")
    - [ @ `import()`](https://caniuse.com/#feat=es6-module-dynamic-import "@ CanIUse.com") 


###  [Import/Export](https://exploringjs.com/es6/ch_modules.html#sec_importing-exporting-details)

### ES6 Export @ `exporter.js`

```js
// per function, object or whatever
export function aFunc(){/*...*/}
// and/or a group of such
export { aFunc, aObj, aVar, ... }
// and/or
export { aThing as FOO, aThing2, ...}
// and/or (re-export) all from another file
export * from 'path/to/someOtherModule'
```

- The `export` statement is __hoisted__.

### ES6 Import @ `importer.js`

```js
// Import 
import { aFunc, aObj } from 'path/rel-to-this-js-file/exporter.js'
// Use
aFunc()
const x = aObj
```

### ES6 Import @ HTML (`<script type="module" src="...">`)   

- Note the ___importer___ is the "`module`" here. Nowhere is the _exporter_ (module) referenced in the HTML file, since the ES6 runtime is handling that, per `import` statement(s).

```html
<script type="module" src="path/rel-to-this-html-file/importer.js"></script>
<!-- FALLBACK :: `nomodule` -->
<script nomodule src="fallback.js"></script>
```

### ES6 Import @ HTML (`<script type="module">`)

```html
<script type="module">
    // Import
    import { aFunc } from 'path/rel-to-this-html-file/exporter.js'
    // USe
    aFunc()
</script>
```

- Requires relative path and filename, including extension (`.js`), __unlike CommonJS__.

### [Dynamic (a.k.a. Lazy) Loading](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules "MDN")

```js
aButton.addEventListener('click', () => {
    import('./modules/dynamo.mjs').then(M => {
        // Use module (M) here, after it loads ...
        const dyn = new M
        dyn.aDynamoFunc()
    })
})
```

#### [@ HTML `<script>`](https://v8.dev/features/modules#other-features)

```html
<script type="module">
    (async () => {
        const moduleSpecifier = './lib.mjs'
        const {repeat, shout} = await import(moduleSpecifier)
        repeat('hello')
        // → 'hello hello'
        shout('Dynamic import in action')
        // → 'DYNAMIC IMPORT IN ACTION!'
    })()
</script>
```


>HTTP header for "`.mjs`" file(s) ___must declare___ `MIME-type`: `javascript/esm` or `application/javascript` .

# [Singleton / Module Pattern](https://stackoverflow.com/questions/1479319/simplest-cleanest-way-to-implement-singleton-in-javascript "@ StackOverflow") | [Namespace Injection](https://addyosmani.com/resources/essentialjsdesignpatterns/book/#singletonpatternjavascript "'Learning JavaScript Design Patterns' @ addyosmani.com")

### HTML
```html
<script src="./scripts/jquery.js"></script>
<script src="./scripts/app.js"></script>
```

### JS

```js
;(function (o,Z){
    // Use jQuery, as Z, herein only.
    Z('#target').html("<h4>Hello from the app (JS file).</h4>")

    // App definition/instantiation.
    o.x = 44
    o.foo = function Foo() { /* ... */}
    // ...

    return o // Return everything (our `this`).
})(window.App = window.App || {}, jQuery) 
```

- That exposes `App`, e.g., `App.foo()`, globally; available to another IIFE per so-named (`window.App`) injection, at another file.
- Do 3rd-party mixins sans ES6 `module` method.  
    - This is the only (practical) way to do it, currently. The claimed browser support is sketchy, and the module authors are all CommonJS, requiring the _browserify_ process to shoehorn it into something usable by a brower. So, further requiring that it's a valid ES6 module is a bit optimistic.





### &nbsp;

<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

