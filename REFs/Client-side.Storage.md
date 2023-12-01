# [Client-side Storage](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Client-side_web_APIs/Client-side_storage "MDN :: Client-side storage")  

## tl;dr

- Below `5MB`, an effective design pattern is to `fetch`/`XHR` docs per REST/JSON API, store the network payload as is (serialized JSON; string), yet parse and maintain the payload as the in-memory state store (object/array); repeating this parse-per-net when stale, which is observable per Etag or some such. This is ___buildable into a synch scheme___. 

- Note that JSON parses faster than POJO (Plain Old Javascript Obj). It is often less perfomant to parse JSON payload into POJO and then store/pull data to/from, per object key; a scheme relying much, much more on these flakey (browser-variant) storage APIs.

## Document Stores 

- @ Browser &mdash; [`Cache`](https://developer.mozilla.org/en-US/docs/Web/API/Cache "Web/API @ MDN")/[`CacheStorage`](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage "Web/API @ MDN") `Interface` (a.k.a. [`Cache` API](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/cache-api "developers.google.com")) is a document store; stores URL-addressable resources per Request/Response (`k/v`) pairs; a [`ServiceWorker` API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API "MDN :: Web/API/") interface; [___not&nbsp;well&nbsp;supported___](https://caniuse.com/#search=Cache%20API "CanIUse.com"). ___Hard limit on cache size___, per browser, per origin.  
    - [Workbox](https://developers.google.com/web/tools/workbox/guides/using-bundlers "developers.google.com") is the latest/leanest way to *auto-generate* a Service Worker (`.js`) and its associated manifest (`.json`), and to handle the `Cache` _document store_, [and `IndexedDB`](https://codelabs.developers.google.com/codelabs/workbox-indexeddb/index.html?index=..%2F..index#4 "WorkBox + IndexedDB @ codelabs.developers.google.com") as application _state store_. 
    - __Synch schemes__   
        - [Background Sync API](https://developers.google.com/web/updates/2015/12/background-sync "developers.google.com 2015") (Chrome only); a `ServiceWorker` API  
- @ Android &mdash; [SQLcipher](https://www.zetetic.net/sqlcipher/open-source/ "@ Zetetic.net") ([@ GitHub](https://github.com/sqlcipher)); an encrypted database; an extension of [SQLite](https://www.sqlite.org/index.html "www.sqlite.org"). Used by WeChat app [(`EnMicroMsg.db`)](https://guardianproject.info/2013/12/10/sqlcipher-has-300-million-mobile-users-thanks-to-wechat/ "'SQLcipher has 300M Mobile Users ... WeChat' @ GuardianProject.info"). See&nbsp;`Tech.Stacks` ([MD](Tech.Stacks.html#wechat "@ browser")).  

>Though not Document Stores per se, the Key-Value Stores (below) can be used quite effectively to store documents (per key).

## Key-Value Stores

<a name="localStorage"></a>

- [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API) includes _two_ `k-v` stores; ___value must be string___; per domain; insecure; `5MB` limit; [___well supported___](https://caniuse.com/#search=Web%20Storage "browser compatibility"), though ___not available at___ __`Web Worker`__; use for small amounts of data. Unlike Cookie API, this is readable by client only. Insecure. Do _not_ store JWTs here. 
    - [`sessionStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/sessionStorage "MDN :: Window/sessionStorage"); available for the duration of the page session. 
    - [`localStorage`](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage "MDN :: Window/localStorage"); same, but __persists__ even when browser closed/reopened.  
    - [`store.js` (`12KB`)](https://github.com/marcuswestin/store.js "GitHub :: MarcusWestin/store.js") @ [MD](PRJ.store.js.html "@ browser")   
    Wrapper/Polyfill for all the Web Storage APIs:  
        - `localStorage`, `sessionStorage`,  `cookie`, `globalStorage` (legacy; Firefox 3+), and `userData` (legacy; IE6+). 
- [`IndexedDB`](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Basic_Concepts_Behind_IndexedDB "'Concepts Behind IndexedDB' @ MDN") ([API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API "MDN :: IndexedDB API")); ___value can be anything___ (JS object); a transactional, asynchronous <sup>&alpha;</sup>  store that returns notifications per DOM Events (`onsuccess`, `onerror`, `oncomplete`, &hellip;); [___well&nbsp;supported___](https://caniuse.com/#search=indexeddb "browser compatibility"); [`IDBDatabase` interface](https://developer.mozilla.org/en-US/docs/Web/API/IDBDatabase "IDBDatabase @ MDN"); RDBM-type  __key-indexed__ for __high-performance__ <sup>&beta;</sup> ; accessible per same-origin policy; storage limited per browser scheme(s). [Intro](https://medium.com/@sahalsajjad/introduction-to-indexeddb-storing-data-in-browsers-2f8e5d0fb22 "'Introduction to IndexedDB ...' @ Medium.com 2018"). [Best&nbsp;Practices](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/indexeddb-best-practices "@ developers.google.com").  
    - `5MB` - `10MB`, per browser vendor.
    - Successor to [Web SQL Database](https://en.wikipedia.org/wiki/Web_SQL_Database) API.
    - ___Available at `Web Workers`___.
    - __Wrappers/Libraries__ (smallest to biggest): <a name="idb"></a>
        - [`idb`](https://github.com/jakearchibald/idb "@ GitHub") [(`4KB`/`2KB`)](get, transactions, async iterators, &hellip;
            - [`idb-keyval`](https://www.npmjs.com/package/idb-keyval "@ NPMjs.com"); subset of `idb`.
        - [LocalForage (`28KB`)](https://github.com/localForage/localForage "GitHub :: localForage"); fallback to [`WebSQL`](https://en.wikipedia.org/wiki/Web_SQL_Database "Wikipedia :: WebSQL was Chrome/Opera precursor to IndexedDB"), then to [`localStorage`](#localStorage); simple but powerful API.   
        - [Dexie.js](https://dexie.org/ "dexie.org") [(`55KB`)](https://github.com/dfahlander/Dexie.js "@ GitHub"); [+ __synch__ (beta)](https://dexie.org/docs/Syncable/Dexie.Syncable.js "Dexie.Syncable.js @ dexie.org").
        - [PouchDB (`121KB`)](https://pouchdb.com/ "PouchDB.com") / [RxDB (`500KB`)](https://github.com/pubkey/rxdb "@ GitHub"); __synch__ per CouchDB sync protocol; [fallback to `WebSQL`](https://github.com/pouchdb/pouchdb "GitHub :: PouchDB").  
        - __Synch schemes__ 
            - [CouchDB](https://en.wikipedia.org/wiki/Apache_CouchDB "Apache :: CouchDB") / [PouchDB](https://pouchdb.com/ "PouchDB.com"); CouchDB is a JSON (document) store and (Erlang) server; has its own synch protocol; API (CRUD) is HTTP/__REST__; [distributed architecture](https://en.wikipedia.org/wiki/Apache_CouchDB#Main_features "CouchDB :: Main Features @ Wikipedia"), with bi-direction __replication__ and synchronization; designed to handle _off-line_ app operations.    
            - [Firebase](https://en.wikipedia.org/wiki/Firebase); Google's mobile web-app platform; vendor lock-in (superglued to GCP); messaging, OAuth, storage (RT database), and hosting.   
    - &alpha; &mdash; __Do not store JSON payload as one big complex object (value) under one key__ [because](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/indexeddb-best-practices#keeping_your_app_performant "'Best Practices ...' @ developers.google.com") &hellip; _The larger the object, the longer the blocking time_ &hellip; _increase write errors_ &hellip;  _cause the_ ___browser tab to crash or become unresponsive___.
    - &beta; &mdash; [IndexedDB isn’t as performant as believed](https://nolanlawson.com/2015/09/29/indexeddb-websql-localstorage-what-blocks-the-dom/ "NolanLawson.com 2015/2019") &hellip; ___blocks the DOM significantly___ _in Firefox and Chrome_ &hellip; ___slower than both LocalStorage and WebSQL___ _for basic key-value insertions._

    > For performance comparison between the two key-value stores, see lab @ `DEV/front-end/js/storage/localStorage-vs-IndexedDB` .

- [ImmortalDB (`50KB`)](https://github.com/gruns/ImmortalDB "GitHub :: gruns/ImortalDB")   
A persistent `k-v` store; wraps all the browser's `k-v` stores, and __stores redundantly__; `cookie`, `IndexedDB`, `localStorage`, and at `sessionStorage`; self heals. 
    - Utilizes [`idb-keyval`](#idb) and [`js-cookie`](#jscookie).

- [Web SQL Database](https://en.wikipedia.org/wiki/Web_SQL_Database) API. 
    - Precursor to `IndexedDB` API.
    - No adoption beyond Google Chrome and Android Browser (2010)

## [HTTP cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies "MDN :: HTTP cookies")  (`4KB`)

- HTTP Headers 
    - [`Cookie`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cookie) @ Request
        ```http
        Cookie: <cookie-list>
        Cookie: name=value
        Cookie: name=value; name2=value2; name3=value3
        ```
    - [`Set-Cookie`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie) @ Response 
        ```http
        Set-Cookie: <cookie-name>=<cookie-value> 
        Set-Cookie: <cookie-name>=<cookie-value>; Domain=<domain-value>; Secure; HttpOnly
        ```
- For storing sensitive data; a small piece of data __sent by server__. Client may store and send it back with next request to same server.
- Browser automatically adds `Cookie` header per request containing all cookies existing/stored of that request's domain.
- [GDPR](https://en.wikipedia.org/wiki/General_Data_Protection_Regulation#I_General_provisions "Wikepedia") (General Data Protection Regulation; 2018) and Cookie Law (ePrivacy Directive; 2002/2009)
    - __Persistent Cookies__ require consent notice; 
    - __Session Cookies__ do not.

### HTTP Request Header  

- See `Network.HTTP.Headers` ([MD](Network.HTTP.Headers.html "@ browser"))  
- App server should send via `HTTPS` only.   
- Always [set _security flags_](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#Syntax):

    |                |                              |
    |----------------|------------------------------|
    | `httpOnly` | Prevent <dfn title="Cross-Site Scripts">XSS</dfn>; forbid any JS access. |
    | `SameSite=strict` | Prevent <dfn title="Cross-Site Request Forgery">CSRF</dfn>. |
    | `secure=true` | Via `HTTPS` only. |

### Web API :: [`document.cookie`](https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie "MDN")

___Cookies are domain specific___; _sent by browser_ only _to domain which wrote them_.

___With every request___ to a specific domain, the client's web browser looks to see if there is a cookie from that domain on the client's machine. If found, the browser will send the cookie with every request to that domain.

Cookie ___data limitations___: if the data is hex (hash), okay to store raw, else [base64](https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/btoa "JS @ MDN")-encode the raw string data. 

```js
window.btoa(raw)  
// ... btoa() is scope to Window OR GlobalWorker
```

### Cookies :: Special Key Names

- `__Host-*` &mdash; Require HTTPS, `Secure`, sans `Domain`
- `__Secure-*` &mdash; Require HTTPS, `Secure`
    - Else cookie is not set.

<a name="jscookie"></a>

### JS Cookie Libraries  

- [`js-cookie` (`1KB`)](https://github.com/js-cookie/js-cookie "@ GitHub"); popular; simple API (`get`, `set`, `remove`).

    ```js
    Cookies.set(key, val, { path: '/', sameSite: 'strict' }
    ```

- Minimal :: Get / Set :: `document.cookie`

    ```js
    // Get 
    function cookieGet(name) {
        var c = "; " + document.cookie;
        var x = c.split("; " + name + "=");
        if (x.length === 2) {
            return x.pop().split(";").shift();
        }
    }
    // Set
    function cookieSet(name, value) {
        var expires = "";
        var date = new Date();
        date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toUTCString();

        document.cookie = name + "=" + value + expires + "; path=/";
    }
    ```

## HTTP Caching :: `ETag` / `If-Match` headers ([MD](Network.HTTP.Headers.html#etag "@ browser"))  



### &nbsp;
<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](Tech.Stacks.html "@ browser"))   

-->

