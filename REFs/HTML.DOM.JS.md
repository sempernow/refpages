# [HTML DOM](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model "@ MDN") ::  [Node](https://developer.mozilla.org/en-US/docs/Web/API/Node "@ MDN") :: [Document](https://developer.mozilla.org/en-US/docs/Web/API/Document "@ MDN")  | [Element](https://developer.mozilla.org/en-US/docs/Web/API/Element "@ MDN") :: [`CanIUse.com`](https://caniuse.com/)

__Document Object__ has both __Model__ (DOM) and __Interfaces__.

Interface hierarchy: Node > (Document|Element)

Both have properties and methods, with the descendents inheriting from Node.

## Examples 

- [Document](https://www.w3schools.com/jsref/dom_obj_document.asp "Reference @ w3schools.com")
- [Element](https://www.w3schools.com/jsref/dom_obj_all.asp "Reference @ w3schools.com") 

## Libraries 

### UPDATE: Use `base.js` library

```js
o.toDOM = (parent, child, at) => {
    /** Insert into DOM
     * @param {Element}   parent
     * @param {DOMString} child   gets parsed
     * @param {any}       at      optional; prepend on any, else append
     * 
     * USAGE: toDOM(css('#foo .bar'), '<h3>Foo</h3> <p>bar baz</p>', 1)
     */
    //o.profStart('toDOM')
    // https://developer.mozilla.org/en-US/docs/Web/API/Element/insertAdjacentHTML 
    at = at ? 'afterbegin' : 'beforeend' 
    // ... "? Prepend : Append" (amongst siblings; children of parent node).
    if (parent && child) {
        parent.insertAdjacentHTML(at, child)
        return true
    }
    return false
}
o.purge = (target) => { // Remove all child nodes
    if (!target) return false
    while (target.firstChild) {
        target.removeChild(target.firstChild)
    }
}
o.replaceContent = (node, html) => node.textContent = html

o.create = (name) => {
    return document.createElement(name)
}
o.id = (id) => {
    return document.getElementById(id)
}

/* root is context node */

o.css = (selector, root) => {
    root = root ? root : document 
    return root.querySelector(selector)
}
o.cssAll = (selector, root) => {
    root = root ? root : document 
    return root.querySelectorAll(selector)
}
o.class = (name, root) => {
    root = root ? root : document 
    return root.getElementsByClassName(name)
}
o.tags = (tag, root) => {
    root = root ? root : document 
    return root.getElementsByTagName(tag)
}
```

### Others 

- [`utilise`](https://github.com/utilise/utilise#api-reference "pemrouz @ GitHub")
- [`w3-framework.js`](w3-framework.js)
- [`commento.js`](https://github.com/adtac/commento/tree/master/frontend/js "adtac/commento/... @ GitHub")

## [DOM Location](https://www.w3schools.com/jsref/obj_location.asp "Reference @ w3schools.com")

```js
console.log("origin",window.location.origin)    // origin http://127.0.0.1:5500
console.log("window",window.location.pathname)  // /sub/
console.log("top",top.location.pathname)        // /sub/
console.log("parent",parent.location.pathname)  // /sub/
// `top` and `parent` useful @ iframe
```

## DOM Position : [`el.getBoundingClientRect()`](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect) | CanIUse @ `99.5%`

```css
div {
    width: 400px;
    height: 200px;
    padding: 20px;
    margin: 50px auto;
    background: #990;
}
```
```html
<div>&nbsp;</div>
```
```js
const 
    getRect = el => { 
        /*************************************************************
         * Convert the unusable return of getBoundingClientRect(),
         * which is the morphodite DOMRect, into a USEFUL object.
         * 
         * USEAGE: [...Object.keys(getRect(el))].map(perKey)
         ************************************************************/
        const {
            top, right, bottom, left, width, height, x, y
        } = el.getBoundingClientRect()
        return {top, right, bottom, left, width, height, x, y} 
    },
    src = document.querySelector('DIV'),
    got = getRect(src),
    put = (key) => {
        const tgt = document.createElement('PRE')
        tgt.textContent  = `${ key } : ${ got[key] }`
        document.body.appendChild(tgt)
    }

;[...Object.keys(got)].map(put)
```

## HTML DOM :: [Element](https://developer.mozilla.org/en-US/docs/Web/API/Element "Class @ MDN") > [Node](https://developer.mozilla.org/en-US/docs/Web/API/Node "EventTarget Interface @ MDN") < [Document](https://developer.mozilla.org/en-US/docs/Web/API/Document "Interface @ MDN")

### Test per CSS 

#### [`Element.matches()`](https://developer.mozilla.org/en-US/docs/Web/API/Element/matches) ([CanIUse.com](https://caniuse.com/#search=matches))

Test if the CSS `selectorString` matches the element; checks if `el` _is_ the selector.

```js
var result = el.matches(selectorString) // true | false
```

### Find per CSS 

#### [`Element.closest()`](https://developer.mozilla.org/en-US/docs/Web/API/Element/closest) ([CanIUse.com](https://caniuse.com/#search=closest))

Walk up the DOM, from `targetEl`, to find the closest element (closestEl) matching the CSS `selectors`.

```js
var closestEl = targetEl.closest(selectors) // HTMLElement | null
```

#### [`document.querySelector(CSS-selector)`](https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector "@ MDN")

Examples

```js
document.querySelector('main.group-1') 
document.querySelector('#logo>svg') 
document.querySelector('div.user-panel.main input[name="login"]') 
```

Returns _first_ element matched, else null.

#### [`parentNode.querySelectorAll(CSS-selector)`](https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelectorAll "@ MDN")

Returns a `NodeList` representing a _list_ of matching elements.

```js
contextNode.querySelectorAll(selector)
```

### Insert | Replace :: HTML as String (parsed as HTML and inserted as nodes)

#### [`insertAdjacentHTML()`](https://developer.mozilla.org/en-US/docs/Web/API/Element/insertAdjacentHTML "@ MDN")

```js
el.insertAdjacentHTML(position, STRING)
```

- Append (next _sibling under parent_)

    ```js
    function appendNextSibling(parent, child) {
        !!(parent) && parent.insertAdjacentHTML('beforeend', child)
    }

    var h = {parent: aContainerEl, child: nextSiblingEl}
    ```

    Better, parameterize the choice of append/prepend: 

    ```js
    function toDOM(parent, child, at) {
        at = at ? 'afterbegin' : 'beforeend' // default appends
        if (parent && child) parent.insertAdjacentHTML(at, child)
    }
    ```

        @ HTML ... 
        aContainerEl
            existingSiblingEl
            nextSiblingEl  <== inserts this.
            ...

#### [`node.textContent`](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent "MDN") 

- Replace (text of a node)

    ```js
    const
        node = document.querySelector('main.group-1') 
        ,txt = 'Foo'

    node.textContent = txt
    ```

#### Comparisons:

- [`el.insertAdjacentHTML(position, STRING)`](https://developer.mozilla.org/en-US/docs/Web/API/Element/insertAdjacentHTML "MDN") 
    - This method of the Element interface ___parses the string as HTML___ or XML  ___and inserts the resulting nodes___ into the DOM tree at a specified position. It _does not reparse the element_ it is being used on, and thus it _does not corrupt the existing elements_ inside that element. This avoids the extra step of serialization, making it __much faster__ than direct [`innerHTML`](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML "MDN") manipulation, ___usually___. (For counter-example, where `innerHTML` is faster, see dbmon challenge `map` case.) 
- [`el.innerHTML`](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML "MDN")   
    - Parses the string into HTML
- [`node.textContent`](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent "MDN") 
    - Sans parsing; faster than either (3x `innerHTML`), since it does not parse, ___though___ it's therefore ___limited to text___ (not even html entities).
- `el.innerText`
    - Do __not__ use [`innerText`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/innerText "MDN"). It triggers [_Layout Thrashing_](#LT).

### Insert | Replace :: HTML as Node

#### [`append()`](https://developer.mozilla.org/en-US/docs/Web/API/ParentNode/append "MDN")  ([CanIUse.com](https://caniuse.com/#search=append))
```js
parentNode.append(...nodesToAppend)
```

`append()`/`prepend()` do so ___relative to sibling node(s)___ of `parentNode`; not `parentNode` itself. Inserts one or more nodes (`nodesToAppend`/`nodesToPrepend`) after/before _the collection of siblings_ under `parentNode`.

- JS

    ```js
    var el = document.getElementById("target")
    var pre = document.createElement('PRE')
    el.append(pre)
    pre.textContent = `Here is AJAX Response: ${xhr.response}`
    ```

- HTML

    ```html
    <div id="target">
        <div> 
        <!-- ... Pre-existing ... -->
        </div>
        <pre>Here is ...</pre>
    </div>
    ```

#### [`prepend()`](https://developer.mozilla.org/en-US/docs/Web/API/ParentNode/prepend) ([CanIUse.com](https://caniuse.com/#search=prepend))

- [`prepend()`](https://developer.mozilla.org/en-US/docs/Web/API/ParentNode/prepend)

```js
parentNode.prepend(...nodesToPrepend)
```

- JS 

    ```js
    el = document.createElement('UL')
    html = '<li>bar</li>'  
    el.insertAdjacentHTML('afterbegin', html) 
    document.getElementById('target').prepend(el)
    ```

- HTML

    ```html
    <section id=target>
        <ul>
            <li>bar</li>  <!-- inserts this li node. -->
            <li>foo</li>
            ...
        </ul>
        ...
    ```

- JS 

    ```js
    parent = document.createElement('DIV')
    p = document.createElement('P')
    parent.prepend("Some text", p)

    console.log(parent.childNodes)  // NodeList [ #text "Some text", <p> ]
    ```

#### [`appendChild()`](https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild "MDN") / [`insertBefore()`](https://developer.mozilla.org/en-US/docs/Web/API/Node/insertBefore "MDN")  are Older APIs (IE compatible) of `append()`/`prepend()`

```js
parentNode.appendChild(aChild);
parentNode.insertBefore(newNode, referenceNode)
```

E.g.,

```js
li = document.createElement('LI')       // Create <li> node
txtNode = document.createTextNode(str)  // Create text node
li.appendChild(txtNode)                 // Append it to <li>

ul = document.getElementById('target') 
ul.insertBefore(li, ul.childNodes[0])   // prepend this li to siblings under ul
```

#### [`node.childNodes[0]`](https://developer.mozilla.org/en-US/docs/Web/API/Node/childNodes "MDN") &amp; [`node.nodeValue`](https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeValue "MDN")

Use to ___replace TEXT at one of many siblings___; leaves all else unaffected.

```js
node.childNodes[0]
```

- JS

    ```js
    var el = document.getElementById("target").childNodes[0]
    el.nodeValue = "SUCCESS"  // "Target" replaced with "SUCCESS"
    ```

    - Unlike `nodeValue`, using either `innerHTML` or `textContent`  methods replaces __all__ the content of `target` (all its child nodes; html &amp; text).

- HTML

    ```html
    <div id="target">
        Target
        <pre>Save</pre>
    </div>
    ```

### Insert MANY :: [`DocumentFragment`](https://developer.mozilla.org/en-US/docs/Web/API/DocumentFragment "MDN") |   [`create​Document​Fragment()`](https://developer.mozilla.org/en-US/docs/Web/API/Document/createDocumentFragment "MDN")

- [`Node​.append​Child()`](https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild "MDN")
- [`Node​.insert​Before()`](https://developer.mozilla.org/en-US/docs/Web/API/Node/insertBefore "MDN")


```js
const messages = document.querySelectorAll('#messages div.msg') || [ghost]

// Iterate over a node list 
;[...messages].map(msg => {
    const ageEl = messages.querySelector('div.date>span', msg) || ghost
    ageEl.replaceContent(ageNow(ageEl.dataset.utcTime))
})
```

```js
const node = document.getElementById('target')
    ,frag = document.createDocumentFragment()

var i = 0

while (i < app.ITEMS) {
    // Not yet in DOM
    var li = document.createElement('li') 
    li.textContent = 'Item number ' + i
    frag.appendChild(li)
    i++
}

// Insert into DOM.
node.appendChild(frag) 
```

### Remove child elements 

#### [`node.removeChild(child)`](https://developer.mozilla.org/en-US/docs/Web/API/Node/removeChild "MDN")

- [Purportedly ___much faster___](https://stackoverflow.com/questions/3955229/remove-all-child-elements-of-a-dom-node-in-javascript "2015 @ StackOverflow.com") than "`innerHTML = ''`".

Referencing only the target node:

```js
let node = document.getElementById('target')
if (node.parentNode) {
    node.parentNode.removeChild(node)
}
```

Referencing only the parent node:

```js
let parent = document.getElementById('parent')
while (parent.firstChild) {
    parent.removeChild(parent.firstChild)
}
```

Or 

```js
let parent = document.getElementById('parent')
while (parent.firstChild) {
    parent.firstChild.remove()
}
```

[Other suggested &hellip;](https://stackoverflow.com/questions/3955229/remove-all-child-elements-of-a-dom-node-in-javascript "2019 @ StackOverflow.com")

```js
var cNode = node.cloneNode(false)
node.parentNode.replaceChild(cNode, node)
```

## <span id="LT"></span>Layout Thrashing :: [Layout Reflow Culprits](https://gist.github.com/paulirish/5d52fb081b3570c81e3a "gist.github.com")  

>... properties or methods that __trigger the browser__ to __synchronously calculate__ the style and layout; ... a common performance bottleneck.

- Box metrics; `.clientXXX`, `.offsetXXX`, ... 
- Scroll; `.scrollXXX`
- Focus; `.focus() `

- `.innerText` 
    - "[&hellip; triggers a reflow to ensure up-to-date computed styles.](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent "MDN"). Use `textContent` instead.

    &vellip;

### &nbsp;
<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

