# [PWAs](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps "MDN") 2019 | [Service Worker Cookbook](https://serviceworke.rs/caching-strategies.html "MDN") ([@GitHub]([Service Worker Cookbook (code)](https://github.com/mozilla/serviceworker-cookbook "MDN @ GitHub"))


## Make Installable :: [Web App Manifest (JSON)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Installable_PWAs) | [w3.org](https://www.w3.org/TR/appmanifest/)

```html
<!-- Startup configuration -->
<link rel="manifest" href="manifest.webmanifest">

<!-- Fallback application metadata for legacy browsers -->
<meta name="application-name" content="AppNameShort">
<link rel="icon" sizes="16x16 32x32 48x48" href="lo_def.ico">
<link rel="icon" sizes="512x512" href="hi_def.png">
```

- HTTP Header: `Content-Type: application/manifest+json`

- @ [`manifest.webmanifest`](manifest.webmanifest)
```json
{
    "name": "App Name Full",
    "short_name": "AppNameShort",
    "description": "Derp derp ...",
    "icons": [
        {
            "src": "icons/icon-32.png",
            "sizes": "32x32",
            "type": "image/png",
            "purpose": "maskable" // maskable (20% padding)
        },
        // ...
        {
            "src": "icons/icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
            "purpose": "any" // transparent
        }
    ],
    "start_url": "index.html",
    "display": "fullscreen",
    "theme_color": "#ff0066",
    "background_color": "#ff0066"
}
```

- [`icons`](https://www.w3.org/TR/appmanifest/#icons-member "www.w3.org") | [`ImageResource`](https://www.w3.org/TR/appmanifest/#dom-imageresource "www.w3.org")
    - [Maskable, adaptive icons](https://css-tricks.com/maskable-icons-android-adaptive-icons-for-your-pwa/ "css-tricks.com") | [Web App Manifest :: Icon Masks](https://www.w3.org/TR/appmanifest/#icon-masks "w3.org")

## [App Shell Model](https://developers.google.com/web/updates/2015/11/app-shell "developers.google.com") 

- Segregate application (and its caches); `shell` (static/assets) vs. `data` (dynamic/content).

```js
const appCaches = [ 
        {
            name: `"${etag.shell}"`,
            type: "shell",
            urls: [
                "/",
                "offline.html",
                "404.html",
                "index.html",
                "scripts/main.js",
                "styles/base.css",
                "images/favicon.ico"
            ]
        },
        {
            name: `"${etag.data}"`,
            type: "data", 
            urls: [
                "/",
                "data/file1",
                "data/file1.1.png",
                "data/file2",
                "data/file2.1.png",
                "data/huge"
            ]
        },
    ]
```

- Obsolete cache is purged per change of `etag` value(s), per "[`activate`](#activate "below")" event.
- May add other named/Etagged caches, e.g., to  ___prefetch___ popular content (`name:` `popular`).
- [JSON Cache](https://github.com/mozilla/serviceworker-cookbook/tree/master/json-cache#json-cache "MDN @ GitHub") &mdash; segregate the cache declaration (JSON), placing it in a separate file (`.json`) instead of as a variable in the service worker (`.js`); cache its references upon service worker install.

## [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API "MDN")

### [Service worker lifecycle](https://blog.logrocket.com/every-website-deserves-a-service-worker/ "2019 @ LogRocket.com")

>To make sure service workers don’t break websites, they go through a strictly defined lifecycle. This makes sure that there is ___only one service worker controlling your website___ (and therefore only one version of your site exists).

#### 1. Register :: [`navigator.serviceWorker.register`](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/register "MDN")

- @ `app.js`

    ```js
    const sw = 'sw1.js'

    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register(sw)
                .then(onResolved, onRejected)
        })
    ```

    - Accepts params:

    ```js
    navigator.serviceWorker.register('/sw.js', {scope: './limit-per-here'})
    ```

    >[&hellip; a service worker can't have a scope broader than its own location](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerContainer/register "MDN"), only _use the scope option when you need a scope that is narrower_ than the default.

#### 2. Install :: [`CacheStorage` Interface](https://developer.mozilla.org/en-US/docs/Web/API/CacheStorage "MDN")

- @ `sw1.js`

    ```js
    self.addEventListener('install', (event) => {
        event.waitUntil(caches.keys()
            .then((keyList) => {
                return Promise.all(
                    appCaches.map((ac) => {
                        // ...
                        caches.open(ac.name)
                            .then((cn) => {
                                // ...
                               cn.addAll(ac.urls)
                                // ...
                            })
                    })
                })
            // ...
    ```

    - Note "`caches`", @ `caches.keys()`, is a ___global read-only variable___ ([`WindowOrWorkerGlobalScope.caches`](https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/caches)); an instance of `CacheStorage`, which is `undefined` unless by HTTPS  (@ Chrome/Safari).
    - Service Worker file (`sw1.js`) location sets its [___scope___](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerRegistration/scope "MDN"); ___place in webroot along with its parent___, e.g., `index.html` .


>If anything goes wrong during this phase, the promise returned from `navigator.serviceWorker.register` (@ `app.js`) is ___rejected___.

#### Force Activation upon Install :: [`self.skipWaiting()`](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerGlobalScope/skipWaiting "MDN")

```js
self.addEventListener('install', (event) => {
    event.waitUntil(/* ... */)
        .then(() => self.skipWaiting())
```

<a name="activate"></a>

#### 3. Activate :: [`waitUntil()`](https://developer.mozilla.org/en-US/docs/Web/API/ExtendableEvent/waitUntil "MDN")

- @ `sw1.js`

```js
self.addEventListener('activate', (event) => {
    const whiteList = appCaches.map((thisCache) => thisCache.name)
    event.waitUntil(caches.keys()
        .then((keysList) => {
            return Promise.all(
                keysList.map((key) => {
                    if (whiteList.indexOf(key) === -1) {
                    // ...
                    return caches.delete(key)
                    }
                })
            )
        })
}
```

>When you successfully install the new service worker, the activate event will be fired. The service worker is now ready to control your website –– but it won’t control it yet. The service worker will only control your website when you ___refresh the page after it’s activated___. Again, this is to assure that nothing is broken.

>The window(s) of a website that a service worker controls are called its `clients`. Inside the event handler for the `install` event, it’s possible to take control of uncontrolled clients by calling `self.clients.claim()`.

>`self.addEventListener('activate', e => self.clients.claim())`

### Intercepting Requests :: [per Strategy](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/#cache-falling-back-to-network "developers.google.com") | [@ WorkBox](https://developers.google.com/web/tools/workbox/reference-docs/latest/workbox.strategies)

```js
self.addEventListener('fetch', (event) => {
    event.respondWith( 
        caches.match(event.request)
            .then((response) => {
                // Per STRATEGY: Network First, Cache Falling Back to Network, ...  
```

### [Save/Cache `POST` @ offline](https://github.com/mozilla/serviceworker-cookbook/tree/master/request-deferrer "MDN @ GitHub")

- [Cache `POST` data if offline](https://blog.logrocket.com/every-website-deserves-a-service-worker/)

```js
.catch(err => {
    // ...
    if(method === 'POST') {
        cacheApiRequest(requestClone)
        return new Response(JSON.stringify({
            message: 'POST request was cached'
        }))
    }
 })
```

### [`BackgroundSynch` API](https://developers.google.com/web/tools/workbox/modules/workbox-background-sync "pwa-workshop.js.org") ([Not well supported](https://caniuse.com/#search=background%20sync "CanIUse.com"))

```js
self.addEventListener('sync', (event) => {
    if (event.tag === 'syncAttendees') {
        event.waitUntil(doSynch())
    }
})
```

>&hellip; a sync event will be emitted when the system decides to trigger a synchronization. This decision is based on various parameters: connectivity, battery status, power source, etc. ; so we can not be sure when synchronization will be triggered.

### [Add to Home Screen :: `beforeinstallprompt` event (@ Chrome)](https://developers.google.com/web/fundamentals/app-install-banners/#listen_for_beforeinstallprompt "developers.google.com") 

```js
window.addEventListener('beforeinstallprompt', (e) => {
    // Stash the event so it can be triggered later.
    deferredPrompt = e
    // Update UI notify the user they can add to home screen
    showInstallPromotion()
})
```

- [Show the Install Button](https://pwa-workshop.js.org/6-pwa-setup/ "pwa-workshop.js.org")

## [WorkBox](https://developers.google.com/web/tools/workbox/reference-docs/latest)

- [WorkBox + IndexedDB Lab](https://codelabs.developers.google.com/codelabs/workbox-indexeddb/index.html?index=..%2F..index#0)
- 

## Other 

- [Web App Manifest](https://www.w3.org/TR/appmanifest/ "www.w3.org")
- [`mkcert` :: HTTPS @ `localhost`](https://github.com/FiloSottile/mkcert#installation "FiloSottile/mkcert @ GitHub")
- [PWA Workshop](https://pwa-workshop.js.org/ "pwa-workshop.js.org")
- [Using Service Workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers "MDN")
- [Service Worker Cookbook (code)](https://github.com/mozilla/serviceworker-cookbook "MDN @ GitHub")
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API "MDN")
- [Service Workers API](https://www.w3.org/TR/service-workers/ "www.w3.org")
- [web.dev](https://web.dev/discover-installable/)

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (MD | HTML)

([MD](___.html "@ browser"))   


# Bookmark

- Reference
[Foo](#foo)
- Target
<a name="foo"></a>

-->

