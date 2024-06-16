
# [HTTP Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers "MDN") | [Article](https://www.twilio.com/blog/a-http-headers-for-the-responsible-developer "'HTTP headers for the responsible developer' @ twillio.com 2019") | [Headers API](https://developer.mozilla.org/en-US/docs/Web/API/Headers/Headers "MDN :: Fetch API Headers") | [Fields (list)](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields "Wikipedia") | [HTTP Status Codes](https://httpstatuses.com/ "httpstatuses.com")

> The standard imposes no limit on size, but servers impose limits. E.g., @ Apache 2.3 server, the defaults are __8,190 bytes/field__, and max __100 header fields/request__.  That's over `800KB` of data!

## [Context](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers#request_context) request 

- `From` &mdash; Contains an Internet email address for a human user who controls the requesting user agent.
- [`Host`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Host) &mdash; Specifies the host (and perhaps port number) of the server to which the request is being sent. Sans port, default per service requested (e.g., `443` if per HTTPS `80` if per HTTP). A Host header field __must be sent with all HTTP/1.1 requests__. A 400 (Bad Request) status code may be sent to any HTTP/1.1 request message that lacks a Host header field or that contains more than one.
    ```plaintext
    Host: <host>[:<port>]
    ```
    ```plaintext
    Host: developer.cdn.mozilla.net
    ``` 
- [`Referer`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer) <a name="referer"></a> &mdash; the address of the page making the request, and so not always present; may be that of the previous web page from which a link to the currently requested page was followed. Sent with requests for page links, `<link ...>`. When making AJAX requests to another domain, this is the url of the active page running the script; allows servers to identify clients for analytics, logging, optimized caching, etc. Notorious for being utilized (manipulated) by malicous attackers, e.g., Cross-Site Request Forgery. See `CSRF.XSRF`  ([MD](CSRF.XSRF.html "@ browser"))   

    ```plaintext
    Referer: <url>
    ```
    ```plaintext
    Referer: https://developer.mozilla.org/en-US/docs/Web/JavaScript
    ```
    - The full URL sans fragments (`#foo`) and userinfo (`username:password`).
- `Referrer-Policy` &mdash; Governs which referrer information sent in the Referer header should be included with requests made.
- `User-Agent` &mdash; Characteristic string to identify the application type, operating system,  vendor/version of the client (user agent) performing the request.
    ```plaintext
    User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0
    ```

## [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers#cors) | [Docs/CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) | `Network.HTTP.CORS+Fetch` ([MD](Network.HTTP.CORS+Fetch.html "@ browser"))   

- [`Access-Control-Allow-Origin`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin)  &mdash; Sent by the _server of the requested resource_.  See `PRJ.HTTP.CORS` ([MD](PRJ.HTTP.CORS.html "@ browser"))   
- [`Origin`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Origin) &mdash; Indicates the server _requesting the resource_; sent with CORS requests and `POST` requests. It is similar to the [`Referer`](#referer) header, but, unlike this header, it doesn't disclose the whole path.
    ```plaintext
    Origin: <scheme> "://" <hostname> [ ":" <port> ]
    ```

## [Proxies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers#proxies)

- `Forwarded` &mdash; Contains information from the client-facing side of proxy servers that is altered or lost when a proxy is involved in the path of the request. Less common than `X-Forwarded-For`
- [`X-Forwarded-For`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For) (XFF) &mdash; Client IP Address. The de-facto standard _request header_ for identifying the _originating IP address of a client_ connecting to a web server through an HTTP proxy or a load balancer.
    ```plaintext
    X-Forwarded-For: <clientIP>, <proxy1_IP>, <proxy2_IP>
    ```
    - Right-most is most recent proxy IP address; left-most is client IP address.
        - May be IPv6 address(es).
- [`X-Forwarded-Host`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-Host) (XFH) &mdash; Server domain name. The de-facto standard _request header_ for identifying the _original host requested by the client_ (in the `Host` HTTP request header) behind a proxy or load balancer.
    ```plaintext
    X-Forwarded-Host: <domain-name-of-forwarded-server>
    ```
    ```plaintext
    X-Forwarded-Host: id42.example-cdn.com
    ```
- `X-Forwarded-Proto` &mdash; Identifies the protocol (HTTP or HTTPS) that a client used to connect to your proxy or load balancer.
- `Via` &mdash; Added by proxies, both forward and reverse proxies, and can appear in the request headers and the response headers.

## [`Sec-Fetch-{Dest|Mode|Site|User}`](https://www.w3.org/TR/fetch-metadata/#framework "2019 @ www.w3.org") request 

A new (2019) security mechanism for user agents (Fetch API) to add specific context to outgoing requests, thereby aiding server-side decision making. By delivering metadata to a server in _a set of fetch metadata headers_, applications may quickly ___reject requests based on testing a set of preconditions___. That work can even be lifted up above the application layer (to reverse proxies, CDNs, etc) if desired.

Fetch API __Metadata Headers__

### [`Sec-Fetch-Mode = sh-token`](https://www.w3.org/TR/fetch-metadata/#sec-fetch-mode-header "2019 @ www.w3.org")
### [`Sec-Fetch-Site = sh-token`](https://www.w3.org/TR/fetch-metadata/#sec-fetch-site-header "2019 @ www.w3.org")
### [`Sec-Fetch-User = sh-boolean`](https://www.w3.org/TR/fetch-metadata/#sec-fetch-user-header "2019 @ www.w3.org")

(`sh-token` &mdash; [Structured Headers](https://tools.ietf.org/html/draft-ietf-httpbis-header-structure-13 "tools.ietf.org") Token.)
```
Sec-Fetch-Dest: (N/A)
Sec-Fetch-Mode: cors|navigate|nested-navigate|no-cors|same-origin|websocket
Sec-Fetch-Site: same-origin|cross-site
Sec-Fetch-User: ?F|?T  
```

- @ Brave browser, `Sec-Fetch-User: ?1|!0`; odd notation [to avoid collision with other types](https://github.com/w3c/webappsec-fetch-metadata/issues/8 "2018 @ github.com/w3c/...").

## [`Location`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Location "MDN")  response 

 Indicates redirect destination URL. For use with  `3xx` (redirection) or `201` (created) only. 

`Location` and [`Content-Location`](#content-location) are different.

### [HTTP Redirects](https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections "MDN") (`3xx`)

<a name="content-location"></a>

## [`Content-Location`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Location) response 

Indicates an alternate location; principal use is @ ___content&nbsp;negotiation___.

## [`Cookie`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cookie#Syntax "MDN") request

Browsers automatically send `Cookie` header with each request, if any exist of its domain. The value thereof is a semicolon-delimited set of `name=value` pairs, each a stored HTTP cookie previously sent by the server per `Set-Cookie` header.

```http
Cookie: <cookie-list>
Cookie: name=value
Cookie: name=value; name2=value2; name3=value3
```

- Pairs in the list are separated by a semicolon and a space, "`;`&nbsp;". 

## [`Set-Cookie`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie "MDN") response

To send cookies from the server to the User Agent, e.g., a session cookie, which may be the result of a successful login.   

```http
Set-Cookie: <cookie-name>=<cookie-value> 
Set-Cookie: <cookie-name>=<cookie-value>; Domain=<domain-value>; Secure; HttpOnly
```

For example, at `twitter.com` (the server sent both) &hellip;

```http
set-cookie: fm=0; Max-Age=0; Expires=Wed, 11 Sep 2019 14:57:57 GMT; Path=/; Domain=.twitter.com; Secure; HTTPOnly
set-cookie: _twitter_sess=BAh...NyZl9p%250...jQ1%250...xNg%253D%253D--690...c351; Path=/; Domain=.twitter.com; Secure; HTTPOnly
```

Delete cookie by expiring it:

```bash
☩ curl -Is localhost:3030/app/logout
HTTP/1.1 200 OK
Set-Cookie: __Host-ia=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Max-Age=0; HttpOnly; Secure; SameSite=Strict
Set-Cookie: __Host-rr=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Max-Age=0; HttpOnly; Secure; SameSite=Strict
Date: Sun, 04 Apr 2021 13:18:11 GMT
Content-Length: 11
Content-Type: text/plain; charset=utf-8
```


- See `PRJ.Headers.Req+Resp` ([MD](PRJ.Headers.Req%2BResp.html "@ browser"))   


<a name="etag"></a>

## [`ETag`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag "MDN") response 

An __ETag__ is an __identifier__ (validator) for a __version__ of a __resource__. 

```http
ETag: "<etag_value>"
ETag: W/"<etag_value>"
```

- The `<etag_value>` should be unique. 
- The server's ETag response header ___triggers___ the client-side mechanism; the Etag value is cached and returned with all subsequent requests, per ___request header___:

```
If-None-Match: <etag_value>, <etag_value>, …
```

    - Such is a [Conditional Request](#conditional). 
        
### Use cases:  

- For [HTTP caching](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching#validating-cached-responses-with-etags "@ developers.google.com"). If the resource changes, a new `<etag_value>` must be generated.
- [Range requests](#range).
- As an immutable ID for __tracking__ per [_User&nbsp;Agent_](https://en.wikipedia.org/wiki/User_agent "@ Wikipedia"), similar to [fingerprint schemes](https://en.wikipedia.org/wiki/Fingerprint_%28computing%29 "@ Wikipedia"). 

>By default, ETag validation is a (costlier) hashsum check, assuring a bit-for-bit identical resource, so is used for `Range` requests. If used for caching, use the `W/` prefix ([weak validation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Conditional_requests#Weak_validation)), which does not perform the hashsum check, rather testing only for _semantic equivalence_. The `W/` method is faster, and so is commonly used for serving static resources (cache). E.g.,

```
Etag: W/"581c5-xArf/LgZfhahmbgqOii1auQ2lkQ"
```

<a name="conditional"></a>

## [Conditional (Request) Headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Conditional_requests#Conditional_headers "MDN") / [Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Conditional_requests "MDN") 

For a server response that varies per ___precondition(s)___ that ___match or not___; the header-stipulated condition ___validates___ or doesn't. 

### [Use Cases](https://developer.mozilla.org/en-US/docs/Web/HTTP/Conditional_requests#Use_cases "MDN")

- Cache update
- Integrity of a partial download, e.g., can be used in combination with a `Range` header to guarantee _all parts of multipart doc_ come from the same resource.
- Optimistic locking @ multiple clients modifying same document; the first returned wins.
    - First upload (Creation) of a resource

### [Validators](https://developer.mozilla.org/en-US/docs/Web/HTTP/Conditional_requests#Validators "MDN") :: Headers 
- [`Last-Modified`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Last-Modified "MDN") &mdash; not as accurate as `Etag`.
- `Etag`

### [Conditional Header(s)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Conditional_requests#Conditional_headers "MDN")

__Conditional request__; for caching resources at the client; the server sends back the requested resource  ___only on validation, e.g.,  `<etag_value>` match @ `If-Match: <etag_value>` header, or none so @ `If-None-Match: <etag_value>`. 

- [`If-None-Match`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match "MDN") request  
__Conditional request__; for caching resources; the server sends back the requested resource  ___only if no `<etag_value>` matches its___; _takes precedence_ over [`If-Modified-Since` (date/time)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since) request header (if both headers are sent).

    ```
    If-None-Match: <etag_value>, <etag_value>, …
    ```

- [`If-Match`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Match "MDN") request  

    ```
    If-Match: <etag_value>
    If-Match: <etag_value>, <etag_value>, …
    If-Match: *
    ```

- [`If-Modified-Since`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since "MDN") request

    ```
    If-Modified-Since: <day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
    ```
- `If-Unmodified-Since` request
- `If-Range` request

<a name="range"></a>

## [`Range`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Range)  request  

Indicates the part(s) of a document, in a __multipart document__, the server should return; uses the `206` (`Partial Content`) for the response. If ranges are invalid, the server returns the `416` (`Range Not Satisfiable`) error. The _server can also ignore the Range header_ and return the whole document with a `200` status code.

```
Range: <unit>=<range-start>-<range-end>, <range-start>-<range-end>
```

## [`Cache-Control`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control)   request or response  

Avoid requests for unchanged resources.  Caching __directives are unidirectional__; a given directive in a request does not imply the same directive in the response.

```
Cache-Control: <directive-1>, <directive-2>, ...
```

- Request [Directives](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control#Directives "MDN :: Cache-Control Directives")   

    ```
    Cache-Control: max-age=<seconds>
    Cache-Control: max-stale[=<seconds>]
    Cache-Control: min-fresh=<seconds>
    Cache-Control: no-cache 
    Cache-Control: no-store
    Cache-Control: no-transform
    Cache-Control: only-if-cached
    ```

- Response  [Directives](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control#Directives "MDN :: Cache-Control Directives")  

    ```
    Cache-Control: must-revalidate
    Cache-Control: no-cache
    Cache-Control: no-store
    Cache-Control: no-transform
    Cache-Control: public
    Cache-Control: private
    Cache-Control: proxy-revalidate
    Cache-Control: max-age=<seconds>
    Cache-Control: s-maxage=<seconds>
    ```  

    - To cache __static assets__, have server send:  
    `Cache-Control: public, max-age=31536000`

    - To __prevent caching__, have server send:   
    `Cache-Control: no-store`   
        - Else can use an [`Expires` header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Expires "MDN :: Expires - Response Header"); an HTTP-date timestamp:  
        `Expires: Wed, 21 Oct 2015 07:28:00 GMT`  
        (Ignored if with `Cache-Control` header having `max-age` or `s-maxage` directive.)

- Extension  [Directives](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control#Directives "MDN :: Cache-Control Directives")  ([not as supported](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control#Browser_compatibility "MDN :: Browser Compatibility"))   

    ```
    Cache-Control: immutable 
    Cache-Control: stale-while-revalidate=<seconds>
    Cache-Control: stale-if-error=<seconds>
    ```  

### "[Increasing Application Performance with HTTP Cache Headers](https://devcenter.heroku.com/articles/increasing-application-performance-with-http-cache-headers#conditional-requests "Heroku.com")"


## [`Alt-Svc`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Alt-Svc "MDN") response 

Alternate Services; used to list alternate ways (host, protocol and port) to reach the server (website), e.g., per [QUIC](https://en.wikipedia.org/wiki/QUIC "'Quick UDP Internet Connections' - Google 2012 @ Wikipedia") (vs HTTP). About half of all Google responses to ___Chrome browsers___ are per QUIC.

```
Alt-Svc: <service-list>; ma=<max-age>; persist=1
```

- `<service-list>` is a comma-separated list of ___service definitions___:
    - `<service-name>=​"<host-name>:<port-number>"`   
        - `<service-name>` is a valid <abbr title="Application-Layer Protocol Negotiation">ALPN</abbr> identifier, e.g., "`quic`".

@ Google Search &hellip;

```
Alt-Svc: quic=":443"; ma=2592000; v="46,43,39"
```


## [`Strict-Transport-Security` (HSTS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security) response 

HTTP Strict Transport Security (HSTS) ___policy___ ensures _user agents_ (browsers) forbid access to the web app if it is not served per HTTPS. Receiving such from the server, browser will `preload` (__internally redirect__), to HTTPS, all subsequent HTTP requests to same origin. Spec per [RFC 6797](https://tools.ietf.org/html/rfc6797 "HTTP Strict Transport Security").

More info @ [OWASP.org](https://cheatsheetseries.owasp.org/cheatsheets/HTTP_Strict_Transport_Security_Cheat_Sheet.html)

```
Strict-Transport-Security: max-age=1000; includeSubDomains; preload
```

- `max-age` directive is in seconds.
- Same action for subdomain requests per optional `includeSubDomains` directive.  

Can also submit site to list at [hstspreload.org](https://hstspreload.org/), which is adopted by most browsers.

## [`Content-Security-Policy` (CSP)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy "MDN") response 

[Control resources](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP "MDN :: Examples") the _user agent_ is allowed to load for a given page. Most policies specify server origins and script endpoints. This helps guard against cross-site scripting attacks (XSS).

```
Content-Security-Policy: <policy-directive>; <policy-directive>
Content-Security-Policy: upgrade-insecure-requests
```

- [Fetch Directives](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy#Fetch_directives "MDN :: CSP Fetch Directives")

    - `default-src https://theoneandonly.trusted.com`  
    Allow only SSL and only from a single specified origin; all content.
    - `default-src 'self' *.trusted.com`    
    Allow content from a trusted domain and all its subdomains.
    - `default-src 'self'; img-src *; media-src media1.com media2.com; script-src js.trusted.com`  
    Allow images from any origin, but audio/video from only the 2 specified providers, and all scripts only from one specific server.  
    - `frame-src`  
    Allow for nested browsing contexts that load using elements such as `<frame>` and `<iframe>`.
    - `worker-src`  
    Specifies valid (allowable) sources for `Worker`, `SharedWorker`, or `ServiceWorker` scripts.
- [Document Directives](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy#Document_directives   "MDN :: CSP Document Directives")
- Navigation Directives 
- Reporting Directives 
- Other Directives 
    - `upgrade-insecure-requests`  
Instructs user agents to treat all of a site's insecure URLs (those served over HTTP) as though they have been replaced with secure URLs (those served over HTTPS); intended for web sites with large numbers of insecure legacy URLs.

- [Testing the CSP (Policy)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP#Testing_your_policy "MDN :: Testing the CSP [Policy]")  
    ```
    Content-Security-Policy-Report-Only: policy 
    ```
- [Enable Reporting (back to server)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP#Enabling_reporting)

### Examples 

#### Lockdown with "`default-src 'none';`"

```golang
w.Header().Set("Content-Security-Policy",
    "default-src 'none';"+ // Forbid everything not explicitly declared.
        "script-src https://cdn.hard.net;"+
        "style-src https://cdn.hard.net;"+
        "img-src https://cdn.hard.net;"+
        "connect-src https://api.hard.com;"+ // Restrict API-loaded URLs
        "child-src 'self'", // 'self' is origin server
)
```

- The [`connect-src`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/connect-src "MDN") directive restricts URLs loaded per Web APIs: `Fetch`, `XMLHttpRequest`, `WebSocket`, &hellip;

> Note that CSP header(s) are not listed @ development tools of browsers (Chrome, Firefox).

#### SSL only 

```golang
w.Header().Set("Content-Security-Policy",
    "default-src https:;"+      // SSL @ those not explicitly declared
        "object-src https://foo.com;"+          // specific host
        "script-src 'self' 'unsafe-inline';"+   // Forbid inline scripts
        "worker-src 'self'",
)
```

## [Subresource Integrity (SRI)](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity "MDN")

- Require ___match___ `integrity=...` value against the asset's ___cryptographic hash___.

```html
<script src="https://foo.com/bundle.js"
    integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8wC"
    crossorigin="anonymous"></script>
```

The SRI (above) triggers CORS test at browser, so ___must include___ the access-control header &hellip;

```
Access-Control-Allow-Origin:  *
```

#### Generate SRI of the asset (`$@`)

```bash
#!/usr/bin/env bash

[[ $(type -t openssl) ]] && { 
    printf "sha384-$(cat "$@" | openssl dgst -sha384 -binary | openssl base64 -A)" 
} || {
    [[ $(type -t shasum) ]] && {
        printf "sha384-$(shasum -b -a 384 "$@" | awk '{ print $1 }' | xxd -r -p | base64)"
    }
}
```

## [`Accept-Encoding`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Encoding "MDN")  request   

Advertises acceptable __content compression__ schemes. Server selects one of the proposals, uses it and informs the client of its choice with the [`Content-Encoding` response](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Encoding "MDN :: Content-Encoding") header. (The server may choose not to compress the body of a response.)  

```
Accept-Encoding: deflate, gzip;q=1.0, br, *;q=0.5
```  

- [Directives](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Encoding#Directives "MDN :: Accept-Encoding Directives")  
    - [Quality values (`q=<#>`)](https://developer.mozilla.org/en-US/docs/Glossary/Quality_values "MDN :: Quality Values"), or `q-values` and `q-factors`;  
    describing the __order of priority__.  

## [`Accept`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept) request  

<a name="content-negotiation"></a>

[__Content Negotiation__](https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation "MDN"): The client ___advertises___ (requests) acceptable ___media types___ (content types), expressed as <abbr title="Multipurpose Internet Mail Extensions">MIME</abbr> type(s). The server selects one (if more than one) and informs client per [`Content-Type` response](#content-type) header attached to the resource.   

- `Accept: <MIME_type>/<MIME_subtype>`

    ```
    Accept: <MIME_type>/<MIME_subtype>
    Accept: <MIME_type>/*
    Accept: */*
    ``` 

    ```
    Accept: text/html, application/xhtml+xml, application/xml;q=0.9, image/webp, */*;q=0.8
    ```

<a id="mime-types"></a>

- [MIME Types](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types "MDN") List

    |          |                      |                  |
    |----------|----------------------|------------------|
    | `.html` | HTML | `text/html` |
    | `.css` | CSS | `text/css` |
    | `.js` | JavaScript | `text/javascript` |
    | `.json` | JSON | `application/json` |
    | `.jsonld` | [JSON-LD](https://en.wikipedia.org/wiki/JSON-LD "@ Wikipedia") | `application/ld+json` |
    | `.jsonp` | [JSONP](https://en.wikipedia.org/wiki/JSONP "@ Wikipedia") | `application/javascript` |
    | `.jpg` | JPEG | `image/jpeg` |
    | `.png` | PNG | `image/png` |
    | `.svg` | SVG | `image/svg+xml` |
    | `.ico` | Win icons | `image/x-icon` |
    | Form | POST | `multipart/form-data` |
    | Binary | POST (upload) |`application/octet-stream` |
    | Range | `206` (Partial Content) |`multipart/byteranges` |

- [Example](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type#Examples "MDN :: Content-Type Examples") `POST`:    

    - Request 

        ```html
        <form action="/" method="post" enctype="multipart/form-data">
          ...
        </form>
        ``` 

    - Response ([See `Content-Type`](#content-type).)

<a name="content-type"></a>

## [`Content-Type`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type) response

A header declaring the <abbr title="Multipurpose Internet Mail Extensions">MIME</abbr> type; ___media type___. [See&nbsp;`Content`&nbsp;`Negotiation`](#content-negotiation). 

The most common one:

```
Content-Type: text/html; charset=UTF-8
```

@ `HTTP POST` 

```
POST /foo HTTP/1.1
Content-Length: 68137
Content-Type: multipart/form-data; boundary=---...---974...
...
X-Content-Type-Options: nosniff
```

```bash
# If sending binary (non-alphanumeric) data, or significantly sized payload:
'Content-Type: multipart/form-data'
# Else send per URL-encoded string"
'Content-Type: application/x-www-form-urlencoded'
# Body is one giant query-string equivalent; 
k1=v1&k2=v2
```
- Can send binary by URL-encoding, but is INEFFICIENT; 
  one byte encodes to (`base64url`) three 7-bit bytes



## [`Content-Disposition`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition "MDN") response

What to do with the resource; treat as part of a web page (`inline`), or as an attachment to save locally as a file. Also used @ multipart body &hellip;

```http
200 OK
Content-Type: text/html; charset=utf-8
Content-Disposition: attachment; filename="cool.html"
Content-Length: 21

<HTML>Save me!</HTML>
```
- _"This simple HTML file will be saved as a regular download rather than displayed in the browser. Most browsers will propose to save it under the `cool.html` filename (by default)."_

## [`Accept-CH`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers#Client_hints "MDN :: Client Hints") (request header _or_ meta tag)  

__Client Hint__ for [automating resource selection](https://developers.google.com/web/updates/2015/09/automating-resource-selection-with-client-hints "developers.google.com"). The user agent advertises __device specifications__; `DPR` (Device Pixel Ratio) , `Viewport-Width`, and `Width`. This scheme is _experimental_; a work-in-progress (WIP).  

- @ `meta` tag (HTML)  
`<meta http-equiv="Accept-CH" content="DPR, Viewport-Width, Width">`  
    ```
    <meta http-equiv="Accept-CH" content="Viewport-Width, Downlink">
    <meta http-equiv="Accept-CH-Lifetime" content="86400">
    ```

- @ `Accept-CH` and `Accept-CH-Lifetime` (HTTP headers)  
    ```
    Accept-CH: Width, Viewport-Width
    Accept-CH-Lifetime: 100
    ```

## [Link Prefetching](https://developer.mozilla.org/en-US/docs/Web/HTTP/Link_prefetching_FAQ "MDN :: Link prefetching FAQ") | [Preload content](https://developer.mozilla.org/en-US/docs/Web/HTML/Preloading_content#The_basics "MDN :: Preloading content") ([support](https://caniuse.com/#search=preload "Browser compatibility @ caniuse.com")) 

- @ `rel="preload"` (HTML)   
    ```html
    <head>
        <link rel="preload" href="style.css" as="style">
        <link rel="preload" href="main.js" as="script">
        <link rel="preload" href="foo.mp4" as="video" type="video/mp4">

        <link rel="stylesheet" href="style.css">
    ...
    <body>
        <video controls>
            <source src="foo.mp4" type="video/mp4">
            ...
        <script src="main.js" defer></script>
    ...
    ```
    
- @  [`Link` request _or_ response](https://www.w3.org/wiki/LinkHeader "w3.org") (HTTP header) 

    ```
    Link: <http://www.example.com/white-paper.html&gt;; rel=”canonical”
    Link: </feed>; rel=”alternate”
    Link: </images/big.jpg>; rel=prefetch
    ```

## [`Feature-Policy`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy "MDN :: Feature-Policy") ([support](https://caniuse.com/#search=feature-policy "Browser compatibility @ caniuse.com")) response  

Define what features are allowed; limit __pop-up permission dialogs__.  

```
Feature-Policy: <directive> <allowlist>
Feature-Policy: vibrate 'none'; geolocation 'none'
```  

Can be sent with __request__ using HTML &hellip;   

```html
<iframe allow="camera 'none'; microphone 'none'">
```  

## [`Accept-Ranges`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Ranges "MDN") response

A marker used by the server to advertise its support of __partial requests__. The value of this field indicates the unit that can be used to define a range; browser may try to ___resume___ _an interrupted download, rather than begin again_.

```
Accept-Ranges: bytes
```

### @ [HTTP Range Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests "MDN")

&hellip; for a server to send the requested resource in portions; useful __for large media__ files; for those whose handler has __pause/resume__ functions.

__Test for server support__:

If the `Accept-Ranges` is present in HTTP responses (and its value isn't "none"), then the server supports range requests:

```bash
curl -I 'http://i.imgur.com/z4d4kWk.jpg'

HTTP/1.1 200 OK
...
Accept-Ranges: bytes
Content-Length: 146515
```


### 


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

