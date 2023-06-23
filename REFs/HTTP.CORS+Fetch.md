# [CORS + Fetch API](https://javascript.info/fetch-crossorigin "javascript.info") | [Summary](https://javascript.info/fetch-crossorigin#summary)

## TL;DR


1. __Browsers always add `Origin` header to CORS requests__. They act as trusted mediator; validate the request against preflight response header(s), and such.
1. If a `fetch` request body is JSON, declared per `Content-Type: application/json`, then it is an "Unsafe" CORS request. (That declaration should be unnecessary, as the service endpoint should be expecting content of that one type.)
1. `Cookie` header is normally not sent with requests of Fetch API. To send them, request options must include `credentials`:
  - [`fetch(url, {credentials: "include"})`](https://javascript.info/fetch-api)
  - In doing so,`Access-Control-Allow-Origin` response header value must be set to a specific origin, not the wildcard, `"*"`; browsers interpret it here as a literal.
1. Though headers beyond those of "Safe" list must be explicitly declared in preflight (`OPTIONS`) request (`Access-Control-Allow-Headers:`), the `Cookie` header needn't be declared if the `Authorization` header is declared and `fetch` option '`credentials: "include"`' is set.

>Be advised that browsers will ___falsely report___ CORS errors in certain cases. For example, if the CORS request is to endpoints not handled by the router, if the service is unavailable (500 Internal Server Error), and other cases. Each browser vendor has their own set of quirks. Chrome tends to provide the most insight (versus Firefox) into CORS issues.

## [CORS @ safe requests](https://javascript.info/fetch-crossorigin#cors-for-safe-requests)

>CORS requests that are automatically allowed by browsers; sans preflight (`OPTIONS`) request.

- Safe method: `GET`, `POST`, `HEAD`
- Safe headers:
    ```http
    Accept
    Accept-Language
    Content-Language
    Content-Type (1)
    ```
    - (1) Only if type is `application/x-www-form-urlencoded`, `multipart/form-data`, or `text/plain`.


#### Example CORS request:

- URL: `https://anywhere.com/request` (To)
- Origin: `https://javascript.info/page` (From)

Request Headers

```http
GET /request
Host: anywhere.com
Origin: https://javascript.info
...
```
```bash
# cURL-equivalent request
curl -X GET \
  -H 'Origin: https://javascript.info' \
  -H 'Host: anywhere.com' \
  https://anywhere.com/request
```


Response Headers (Permissive):

```http
200 OK
Content-Type: text/html; charset=UTF-8
Access-Control-Allow-Origin: https://javascript.info
```

### Safe response headers

Browser allows javascript only these, by default:


    Cache-Control
    Content-Language
    Content-Type
    Expires
    Last-Modified
    Pragma

To grant JavaScript access to any other response header, the server must send `Access-Control-Expose-Headers`, e.g., 


```http
200 OK
Content-Type: text/html; charset=UTF-8
Content-Length: 12345
API-Key: 2c9de507f2c54aa1
Access-Control-Allow-Origin: https://javascript.info
Access-Control-Expose-Headers: Content-Length,API-Key
```

## [CORS @ unsafe requests](https://javascript.info/fetch-crossorigin#unsafe-requests)

```js
let response = await fetch('https://site.com/service.json', {
  method: 'PATCH',
  headers: {
    'Content-Type': 'application/json',
    'API-Key': 'secret'
  }
})
```

Browser sends Preflight, `OPTIONS` method, request

### Preflight 

Request 

```http
OPTIONS /service.json
Host: site.com
Origin: https://javascript.info
Access-Control-Request-Method: PATCH
Access-Control-Request-Headers: Content-Type,API-Key
```

If the server agrees to serve the requests, then it ___should respond with empty body___, status `200` ___and headers___:

Response 

```http
Access-Control-Allow-Origin: https://javascript.info
Access-Control-Allow-Methods: PATCH
Access-Control-Allow-Headers: Content-Type,API-Key.
```

Server may have list of such to service all expected requests

```http
200 OK
Access-Control-Allow-Origin: https://javascript.info
Access-Control-Allow-Methods: PUT,PATCH,DELETE
Access-Control-Allow-Headers: API-Key,Content-Type,If-Modified-Since,Cache-Control
Access-Control-Max-Age: 86400
```

### Main 

Request 

```http
PATCH /service.json
Host: site.com
Content-Type: application/json
API-Key: secret
Origin: https://javascript.info
```

Response 

```http
Access-Control-Allow-Origin: https://javascript.info
```

### [Credentials](https://javascript.info/fetch-crossorigin#credentials)

A cross-origin request initiated by JavaScript code by default does not bring any credentials (headers: [`Cookie`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cookie) or [`WWW-Authenticate`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate)).

For example, `fetch('http://another.com')` does not send any cookies, even those that belong to `another.com` domain.

To send credentials using Fetcch API, add the option `credentials: "include"`, ...

```js
fetch('http://another.com', {
  credentials: "include"
})
```

### Preflight

Request headers 

```http
OPTIONS /service.json
Host: site.com
Origin: https://javascript.info
Access-Control-Request-Method: PATCH
Access-Control-Request-Headers: Authorization
```

Response headers (Permissive)

```http
200 OK
Access-Control-Allow-Origin: https://javascript.info
Access-Control-Allow-Credentials: true
Access-Control-Allow-Headers: Authorization
```
- ___Cannot use___ `"*"` if `fetch(..)` uses `credentials: ...` because it is interpreted as a literal in that case.
- Needn't add `Cookie` to list of allowed headers; browsers automatically send cookies (originated at that domain) if `fetch` option '`credentials: "include"`' is set.

### Main

Request 

```http
OPTIONS /service.json
Host: site.com
Origin: https://javascript.info
Access-Control-Request-Method: PATCH
Access-Control-Request-Headers: Authorization
```

Response 

```http
Access-Control-Allow-Origin: https://javascript.info
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: *
```

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

