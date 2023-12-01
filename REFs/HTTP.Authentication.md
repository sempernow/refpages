# [HTTP Authentication Protocols/Schemes](https://www.owasp.org/index.php/The_General_HTTP_Authentication_Framework "@ OWASP.org") 

## See Labs @ `DEV/go/.../labs/2-auth/` . <a name="labs"></a> 

![HTTP Authentication Flow (PNG)](http-authentication-flow.png)

1. Client requests secure resource (URI).
1. Response Header (Request from Server)
    - @ `HTTP 401 Unauthorized`
        - If apropos. (Not at login form page.)
    - [`WWW-Authenticate: <type> realm=<realm>`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate "@ MDN") 
        - [Spec @ Digest Auth](https://tools.ietf.org/html/rfc7616#section-3.3 "RFC 7617, Section 3.3 @ ietf.org")
        - [Example @ Digest Auth](https://tools.ietf.org/html/rfc7616#section-3.9 "RFC 7617, Section 3.9 @ ietf.org")
1. Request Header (Response from Client)
    - [`Authorization: <type> <credentials>`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization "@ MDN")

>Note the `WWW-Authenticate` header triggers a ___browser popup___; "Authentication Required"; a hard-coded login form.

### Reference: [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication "@ developer.mozilla.org")

## [Mutual Auth](https://en.wikipedia.org/wiki/Mutual_authentication "@ Wikipedia") | [RFC 8120](https://tools.ietf.org/html/rfc8120#section-1 "ietf.org") (2017)
 
 - @ Server: [PAKE2 library](https://github.com/schollz/pake "schollz/pake [Golang] @ GitHub")
 - @ Browser: [WASMcrypto](https://github.com/schollz/wasmcrypto "schollz/WASMcrypto @ GitHub")

A general framework providing a strong cryptographic solution for password authentications; password-based authenticated key exchange (__PAKE__). Default mode of SSH. _When using CA certificates_, this protocol is called _Mutual TLS_ (__mTLS__). Isn't as popular as JWT-based schemes, for web applications.

>[Digest Auth works, but] &hellip; powerful computers &hellip; ___offline
   password dictionary attack___ &hellip; threatening the effectiveness of such hash-based password protections. 
   
>[Even with TLS (HTTPS),] &hellip; if the users are fraudulently routed to a "wrong Website" via some kind of social engineering attack (e.g., ___phishing___) and _tricked into performing authentication on that site_ &hellip;

- No password information exchanged, as with Digest Auth protocol. 
- Both server and client must own the valid registered credentials (authentication secret).

### Mutual Authentication :: named messages:

- __Authentication Request__ (`INIT`/`STALE`): __server requests__ _client start_.
    - `401-INIT`: start  _auth protocol_.
        - Also used to indicate an auth failure.
    - `401-STALE`: start _new key exchange_.
-  __Authenticated Key Exchange__ (`KEX`): used __by both peers__ (server or client) to _authenticated and share a cryptographic secret_.
    - `req-KEX-C1`: sent from client.
    - `401-KEX-S1`: sent from server; an intermediate response to a `req-KEX-C1`.
-  __Authentication Verification__ (`VFY`): used __by both peers__ to _verify the authentication_ results.
    - `req-VFY-C`: sent by client to _request server authenticate_ and authorize the client.
    - `200-VFY-S`: response sent by server to indicate _client authentication succeeded_; also contains info necessary for the client to _check authenticity of the server_.

## HMAC/SCRAM (`SCRAM-SHA-256`) | [RFC 7804](https://tools.ietf.org/html/rfc7804#section-3 "ietf.org")  (2016)

Salted Challenge Response HTTP Authentication Mechanism (SCRAM) 

Challenge/response testing an assertion against its ___keyed digest___ (HMAC), so _both client and server must have a pre-shared private key_. Commonly used to secure APIs.

@ AWS APIs :: [AWS4-HMAC-SHA256](https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html "docs.aws.amazon.com/AmazonS3")

## Digest Auth | [RFC 7616](https://tools.ietf.org/html/rfc7616#section-3 "ietf.org") (2015) | [RFC 2617, Section 3](https://tools.ietf.org/html/rfc2617#section-3.1 "ietf.org") (1999) <a name="digest-auth"></a>

The Digest scheme is based on a simple challenge-response paradigm &hellip; challenges using a [nonce](https://en.wikipedia.org/wiki/Cryptographic_nonce "@ Wikipedia") value [to mitigate ___replay&nbsp;attacks___] &hellip; response contains an ___unkeyed digest___:  `user:pass:nonce:HTTPmethod:requestURI`. 

Requires (pre-existing) _shared secret_ (`user:pass`) known to both client and server, so this scheme is useful for Login sessions, but not for Sign up. [Example @ RFC 7617, Section 3](https://tools.ietf.org/html/rfc7616#section-3.9 "ietf.org")

#### `SHA512(user:pass:keyL:keyU)`

In this version, a `cnonce` is sent back from client. Since server must maintain state anyway, the scheme can add (server-sent) `nonce` requirement too.

- Server [(`digest.go`)](#labs "See Labs")
- Client [(`form-login-digest.js`)](#labs "See Labs") 

## Basic Auth | [RFC 7617](https://tools.ietf.org/html/rfc7617#section-1 "ietf.org") (2015) | [RFC 2617](https://tools.ietf.org/html/rfc2617#section-1 "ietf.org") (1999)

This Golang `BasicAuth()` function is not used here; just a reference&nbsp;&hellip;

```golang 
func (r *Request) BasicAuth() (username, password string, ok bool)
```

>[`BasicAuth`](https://golang.org/pkg/net/http/#Request.BasicAuth "net/http  pkg @ golang.org") returns the username and password provided in the request's Authorization header, if the request uses `HTTP Basic Authentication`. See [RFC 2617, Section 2](https://tools.ietf.org/html/rfc2617#section-2 "ietf.org"). 

User ID and password are passed over the network as clear text (`user:pass`), so HTTPS/TLS required. However, ...

Modified scheme features: 

- Encrypt the client's `POST` response data.
- Server can be stateless.
    - Can be hardened if state is maintained.

This is a sort of [Digest Auth](#digest-auth "above") scheme [RFC 2617, Section 3](https://tools.ietf.org/html/rfc2617#section-3.1 "ietf.org"), but with the "private key" generated client-side and sent (obfuscated) along with the (challenge) response. Also, server can be stateless, unlike Digest Auth. 

#### `XOR( XOR( user:pass, H(keyL) ), H(keyL+keyU) )`

- Server [(`basic.go`)](#labs "See Labs") 
- Client [(`form-login-basic.js`)](#labs "See Labs")

The `form`'s `submit` event is intercepted. The keys are concatenated (e.g., `user:pass`), creating the payload. This is XOR'd with a one-time login key `H(keyL)`; a message digest (`SHA-512`) of a randomly genterated number, per `Window.crypto`. The product is again XOR'd, but with a similarly constructed string based on `KeyL` and User Agent, `H(keyL+keyU)`. Finally, the payload is base64 encoded and then inserted into a hidden form key. 

To decipher server-side, the one-time login key is received as a cookie (`H(keyL)`), and the other key is regenerated from that one-time key concatenated with the UA Header. The one-time key (`H(keyL)`) cookie is deleted upon server response. The intent is for the server to respond with an auth cookie, `__Host-0: HMAC(user:pass)`, or perhaps a session cookie `__Host-0: HMAC(session:user:pass)`.

The cipher payload is sent from the client per AJAX/`POST` under its own key (`ajax`). Prior to the delayed `form.submit()` action, the user-entered data (`user` and `pass`) are cleared. 

All the parameters required to defeat this are in the request, and so it remains vulnerable. The difference is that the payload is not sent in plaintext; its recovery requires knowledge of the hash and XOR scheme (or a very good guess), and performing its required multi-step processing on the base64-decoded payload.

The scheme can be hardened by using a server-sent cookie (`H(keyL)`), sent along with the login form (page). Such a key would be absent from the subsequent client response (login request). This, however, requires the server to maintain state per user login. (Can handle per `http.context`?)

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

