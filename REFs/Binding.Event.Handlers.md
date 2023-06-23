
# [Binding Event Handlers](https://URL "___")

## [Event Delegation](http://https://davidwalsh.name/event-delegate)
Bind event listener to a parent; all child node events bubble up, per `e.target`.

### Example  
Pass a function name to call per event

```js
var id = (id) => { // alias for ...
    return document.getElementById(id)
}

id("group-1")
    .addEventListener("click", function (e) {
        var f = e.target.innerHTML.replace('()','')
        if (typeof o[f] === "function") { 
            o[f]()
        }
    })
```
- `o` is parameter for namespace injected into the enclosing IIFE.  
E.g.,  

    ```js
    (function(o){
        o.aFunc = () => {/*...*/}
        // ...
    })($);
    ```

### Example  
Pass an attribute as parameter for function called per event


```js
// To shorten these common DOM references ...
var els = (tag) => {return document.getElementsByTagName(tag)}
var elID = (id) => {return document.getElementById(id)}

// @ e.target method 
elID("group-1")
    .addEventListener("click", (e) => {
        if (e.target && e.target.nodeName == 'BUTTON') {
            var el = els('BUTTON')[e.target.id]
            _toggleClass(el.title)
        }
    })

function _toggleClass(c) {
    c = c || 'default'
    var el = elID("target");
    el.className ? el.classList.toggle(c) : el.className = c;
    el.innerHTML = c
    console.log('@ _do(' + c + ')');
}
```

### [Event Bubbling and Capturing](https://medium.com/free-code-camp/the-complete-javascript-handbook-f26b2c71719c)


## [`DOMStringMap` :: `data-*` :: Global Attrib](https://developer.mozilla.org/en-US/docs/Web/API/DOMStringMap "MDN")

### HTML
```html
<div id="group-1">
    <button data-func="func1" id="event-1" title="Start SSE">Start</button>
    <button data-func="func2" id="event-2" title="Stop SSE">Stop</button>
</div>
```

### JS [@ `dataset.js`](scripts/dataset.js)

```js
// button Event Handler per Event Delegation (1 for all @ group)
id("group-1")
    .addEventListener("click", function (e) {
        if (e.target && e.target.nodeName == "BUTTON") {
            var f = tags('BUTTON')[e.target.id].dataset.func
            if (typeof $[f] === "function") { // validate
                // pass this element's title attribue (value)
                $[f](tags('BUTTON')[e.target.id].title)
            }
        }
    })
```

- `.dataset`, of the `DOMStringMap` API, accesses values at "`data-*`", per method (`*`).   
E.g., `tags('BUTTON')[1].dataset.func` returns value "`func1`" (@ `data-func="func1"`).

- Event delegation, per `e.target`, binds all child elements (`button`)   
of the parent (`#group-1`), all with one `EventListener` .

#### Above is embedded in an IIFE with an injected namespace (`$`)
```js
(function(o){
    // ...
})($);
```

So `$[f]` calls `$.f` per that specific (required) object notation syntax.


## Event Handler Array
> UPDATE: This is more complicated than it need be. Use Event Delegation.

- Attach a `click` event handler (`f`) to an HTML element (`id`)  

    ```js
    function eHandlerId(id, f) {
        console.log('@ _eHandlerId(' + id + ',' + f.name + ')');
        var el = document.getElementById(id);
        el.addEventListener('click', f);
    }

    eHandlerID('json-button', "fetchJSON");
    ```

    ### Modify to Accept an Array of such Bindings, and Wrap in `app` Method. 

    ```js
    var eHandlArr = eHandlArr || [
        ['json-button', "fetchJSON"],
        ['img-button', "fetchImage"],
        ['text-button', "fetchText"],
        ['head-button', "headRequest"],
        ['post-button', "postRequest"]
    ];

    app.eHandlersArr(eHandlArr);
    ```

- @ `app` Object ([Revealing Module Pattern](https://addyosmani.com/resources/essentialjsdesignpatterns/book/#modulepatternjavascript "Learning JavaScript Design Patterns @ addyosmani.com")). 

    ```js
    var app = (function () {
        ...

        function _eHandlersArr(bindings) {
            for (var pair of bindings) {
                console.log('@ _eHandlersArr(' + pair[0] + ',' + pair[1] + ')');
                var el = document.getElementById(pair[0]);
                el.addEventListener('click', app[pair[1]]);
            }
        }

        return 
            eHandlersArr: (_eHandlersArr),
            ...
    })();
    ```

- @ HTML

    ```html
      <button id="json-button" title="See object @ console">Fetch JSON</button>
      <button id="img-button">Fetch image</button>
      <button id="text-button">Fetch text</button>
      ...
    ```

    - Separation of concerns; `index.html` is HTML only.

### &nbsp;

<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

