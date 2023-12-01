
## [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch "Using Fetch @ MDN")

```js
o.jFetch3 = function () {
    fetch(o.url)
        .then(validate)
        .then(jreduceFetch)
        .then(toDOM)
        .catch(log)
}
```

## XHR: [`XMLHttpRequest()`](https://developer.mozilla.org/en-US/docs/Glossary/XHR_(XMLHttpRequest) "@ MDN") | Promisified: [`fetchXHR()`]([misc]/ajax/xhr.js)

#### @ Basic `GET` 

```js
document.querySelector('H1').onclick = makeRequest

function makeRequest() {
    var xhr = new XMLHttpRequest()
    xhr.open('GET', '/foo', true)
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200){
            toDOM(xhr) // callback
        }
    }
    xhr.send()
}

var toDOM = (xhr) => {
    var el = document.querySelector('H1'),
        html = `<h2><code>${xhr.responseText}</code></h2>`

    el.insertAdjacentHTML("afterend",html)
    document.querySelector('BODY').prepend(el) // APPENDs to BODY
}
```

#### @ JSON `POST`/`GET`

```js
// POST
function post(url, data, callback) {
    var xhr = new XMLHttpRequest()

    xhr.open("POST", url, true)
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.onload = function() {
        callback(JSON.parse(xhr.response))
    }

    xhr.send(JSON.stringify(data))
}
// GET
function get(url, callback) {
    var xhr = new XMLHttpRequest()

    xhr.open("GET", url, true)
    xhr.onload = function() {
        callback(JSON.parse(xhr.response))
    };

    xhr.send(null)
}
```

## ( XHR | Fetch ) &amp; Render

###  Various schemes profiled @ JSON payload 
- [(`jrender.js`)]([misc]/ajax/jrender.js)  
Fetch and render one large set of serialized blocks of an html component, coded in JSON; one file. 
- [(`hrender.js`)]([misc]/ajax/hrender.js)  
Fetch and render a serialized set of html files, each one block of the html component.

### tl;dr  

Injecting pre-rendered html fragments is very performant, in both network efficiency and DOM manipulation. JSON works as well too. Template literals are great for mapping JSON to html components very quickly; bypasses the per-node javascript code. The DOM performance will suffer some, but the tradeoff is well worth it for most text rendering scenarios, e.g., chat/comments threads and such.

- __XHR__ vs. __Fetch__ 
    - Both use Promise chained processing, from HTTP GET, all the way through to HTML injected into DOM. Here, XHR refers to a _promisified_ [XHR function (`fetchXHR`)]([misc]/ajax/xhr.js).
    - The [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch "Using Fetch [MDN]") is a low-level API, just like its predecessor, `XHR`. Fetch requires explicit coding to handle the full set of AJAX processing fail modes. Asent such, it provides zero HTTP response info, e.g., on `HTTP 404`; from MDN: _The Promise returned from `fetch()`_ ___won’t reject on HTTP error status___ ... _`HTTP 404` or `500`_. Instead, ___it will resolve normally___ (with `ok` status set to `false`), and __it will only reject on network failure__ or if anything prevented the request from completing. Worse, `.json()` is deadly. Forbids __any scheme to catch any error on any malformed json__ payload. (It fails internally, somehow, and offers no hooks for any ES6 error catching schemes.) ([More on Fetch API.](https://gomakethings.com/why-i-still-use-xhr-instead-of-the-fetch-api/ "'Why I still use XHR instead of the Fetch API' @ GoMakeThings.com"))

        - `fetch()` defaults to __allow__ CORS.

        ```js
        // @ CORS, if server Response Header:  
        // Access-Control-Allow-Origin: <origin>
        var initFetch = {
            method: 'GET',
            mode: 'cors',
            cache: 'default'
        }
        $.url = new Request($.domain+'/data/data-serial-1.json', initFetch)
        $.jFetch2()
        ```

- HTML DOM  
Best performance is by promise/resolve all data prior to DOM manipulation. Fetching a single JSON file of 1000 serialized html components takes about 50 ms, from fetch to DOM injection. Here is a single block of the tested component: 

    ```html
    <h2><code>el[008] @ 150</code></h2>
    <p>rTJqlr dm41uf L6UI36 gN9MkT pFvxbQ dBucYJ NfBsHt GVCPNf 
    xS1khx k8TNLV KCv4kJ 2eWBBG LgjG3K 3qj5M6 rxvSXZ qTZqQ9 YGxMTD kFWJ56 
    5BK0Cl 3YepEy couB64 ND12vF WEXeYr AWXfiX kYWrPc </p>
    <div><span>foo</span> ☧ <i>bar</i> <span>baz</span></div>
    ```


- ES6 ___Tagged Template Literal__ is used to generate string,   
injected by `insertAdjactentHTML()` method. 

    ```js
        // Render HTML from JSON; this is the data reducer callback.
        function render(s, j) {
            s += 
            `\n<h2><code>${j.head}</code></h2>
            <p>${j.body}</p>
            <div><span>${j.f1}</span> ${j.f2} <i>${j.f3}</i> <span>${j.f4}</span></div>\n`
            return s
        }
    ```

    - @ `d.reduce(render, '')`


### &nbsp;
<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

