# [JWT](https://jwt.io "JSON Web Token @ JWT.io") | OAuth/SSO ([HTML](JWT.OAuth.md "JWT.OAuth"))   

### RFC7519 [ JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519 "RFC7519 @ 2015")
### RFC7523 [JWT Profile for OAuth 2.0 Client Authentication and Authorization Grants](https://tools.ietf.org/html/rfc7523#section-1 "RFC7523 @ 2015")

### [`/DEV/.../kit/auth/auth.go`](auth.go)


## [JWKS &mdash; JWT Key Set](https://is.docs.wso2.com/en/latest/learn/json-web-key-set-endpoint/) Server
>The JSON Web Key Set (JWKS) endpoint is a read-only endpoint that returns the Identity Server's public key set in the JWKS format. This contains the signing key(s) that the Relying Party (RP) uses to validate signatures from the Identity Server. For more information on this endpoint, see the OpenID Connect Discovery specification.

Endpoint: 
``` 
https://<IS_HOST>:<IS_PORT>/t/<TENANT_DOMAIN>/oauth2/jwks
```

Example:
``` 
https://localhost:9443/t/foo.com/oauth2/jwks
```

Response:
```json
{
  "keys": [
    {
      "kty": "RSA",
      "e": "AQAB",
      "use": "sig",
      "kid": "MTk5NjA3YjRkNGRmZmI4NTYyMzEzZWFhZGM1YzAyZWMyZTg0ZGQ4Yw",
      "alg": "RS256",
      "n": "0OA-yiyn_pCKnldZBq2KPnGplLuTEtGU7IZP66Wf7ElhFJ-kQ87BMKvZqVNDV84MSY3XQg0t0yL6gITg-W8op61PWO2UrEcxhhMHN_rra22Ae2OCaUfOr43cW1YFc54cYj5p7v-HSVvjTuNLGMMrNfTGAOCPzuLxbSHfq62uydU"
    }
  ]
}
```


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

