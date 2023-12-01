# [OAuth](https://oauth.net/2/ "OAuth.net")/[SSO](https://en.wikipedia.org/wiki/Single_sign-on/) | JWT ([HTML](JWT.md "JWT.md")) 

### RFC6749 [OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749 "RFC6749 2012 @ tools.IETF.org")

>&hellip; [makes extensive use of HTTP redirections](https://tools.ietf.org/html/rfc6749#section-1.7 "RFC6747 Section 1.7") &hellip; [per] __HTTP 302__ status code, or any other method available via the user-agent &hellip;

Authorization, ___not authentication___.  
[OpenID Connect (OIDC)](#oidc) deals with authentication.

## Grant Types

- [Authorization Code Grant](https://oauth.net/2/grant-types/authorization-code/ "Oauth.net") ([Request/Response](https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth#oauth-actors "2017 @ okta.com"))
    1. __Front Channel__ (App to Authorization Server) Flow
        - __Request__ Authorization ___Code___
            ```http
            curl -X GET -s \
                https://accounts.google.com/o/oauth2/auth?
                    scope=gmail.insert gmail.send
                    &redirect_uri=https://app.example.com/oauth2/callback
                    &response_type=code
                    &client_id=812741506391
                    &state=af0ifjsldkj
            ```
            - Params (shown per line):
                - `scope` is, e.g., gmail.insert
                - `redirect_url` is that of the (HTTP 302) response header &hellip; 
                    - `Location: <Send_Authorization_Grant_Here>`
                - `response_type` code 
                - `client_id` per prior registration with this Auth Server.
                    - (Obtained per out-of-band process.)
                - `state` is a security flag; a'la CSRF ([HTML](CSRF.XSRF.md "CSRF.XSRF.md")) nonce 
            - Request is directly to Authorization Server, so if user is authenticated, it's a fast, no-stop redirection.
        - __Response__ 
            ```http
            HTTP/1.1 302 Found
            Location: https://app.example.com/oauth2/callback?
                code=MsCeLvIaQm6bTrgtp7
                &state=af0ifjsldkj
            ```
            - Params (shown per line):
                - `code` is the ___Authorization Code___
                - `state` must ___match that at request___, else reject the `code`!
    1. __Back Channel__ (Authorization Server to App API service) Flow 
        - __Request__ Authorization ___Token___ (using Authorization _Code_); _Exchange_
            ```http
            POST /oauth2/v3/token HTTP/1.1
            Host: www.googleapis.com
            Content-Type: application/x-www-form-urlencoded

                code=MsCeLvIaQm6bTrgtp7
                &client_id=812741506391
                &client_secret={client_secret}
                &redirect_uri=https://app.example.com/oauth2/callback
                &grant_type=authorization_code
            ```
            - Params (shown per line):
                - `client_id`: app id
                - `client_secret`: app key
                - `grant_type` is _Authorization Code Grant_ (type); OAuth has several Grant Types; is extensible/flexible.
        - __Response__ 
            ```json
            {
              "access_token": "2YotnFZFEjr1zCsicMWpAA",
              "token_type": "Bearer",
              "expires_in": 3600,
              "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA"
            }
            ```
            - &hellip; exchanging the Authorization Code (granted) for the Access Token. ___Thence make authorized requests___ &hellip;
            ```bash
                curl -I -X ${METHOD} -s \
                    -H "Authorization: Bearer ${_TOKEN}" \
                    http://${_RESOURCE_SERVER_ENDPOINT}

                # E.g., get email
                curl -X GET -s \
                    -H "Authorization: Bearer 2YotnFZFEjr1zCsicMWpAA" \
                    https://www.googleapis.com/gmail/v1/users/1444587525/messages
            ```
- [Resource Owner Credentials Grant](https://tools.ietf.org/html/rfc6749#section-4.3)
    - &hellip; _suitable for clients (trusted first parties) capable of obtaining the resource owner's credentials (username and password, typically using an interactive form)._
    - _Also used to migrate existing clients using direct authentication schemes such as HTTP Basic or Digest authentication to OAuth by_ ___converting the stored credentials to an access token.___

## [Golang OAuth Libraries](https://oauth.net/code/go/)

1. [ORY Hydra](https://github.com/ory/hydra "ory/hydra") [9K] | [ory.sh/hydra](https://www.ory.sh/hydra/)
    - Server &hellip; _OAuth 2.0_ Server _and OpenID Connect Provider optimized for low-latency, high throughput, and low resource consumption._ &hellip; _not an identity provider_ &hellip; _, but connects to your existing identity provider through a login and consent app.
1. [OmniAuth: Standardized Multi-Provider Authentication](https://github.com/omniauth/omniauth "omniauth/omniauth") [7K] | [Wiki](https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema)
    - Client &hellip; _a black box that you can send your application's users into when you need authentication and then get information back._
    - [Provider Strategies](https://github.com/omniauth/omniauth/wiki/List-of-Strategies#provider-strategies) (@ Ruby)
1. [OAuth2 for Go](https://github.com/golang/oauth2#oauth2-for-go "golang/oauth2") [3K] | [GoDoc](https://godoc.org/golang.org/x/oauth2)
    - Client &hellip; _implementation for OAuth 2.0 spec._
1. [Goth: Multi-Provider Authentication for Go ](https://github.com/markbates/goth "markbates/goth") [3K] | [GoDoc](https://godoc.org/github.com/markbates/goth)
    - Client &hellip; _lets you write OAuth, OAuth2, or any other protocol providers, as long as they implement the Provider and Session interfaces._

## Identity Providers

- [Amazon](https://login.amazon.com/)
- [Google](https://developers.google.com/identity/protocols/oauth2)

- [Scopes](https://oauth.net/2/scope/)
     - &hellip; _a mechanism in OAuth 2.0 to limit an application's access to a user's account. An application can request one or more scopes, this information is then presented to the user in the consent screen, and the access token issued to the application will be limited to the scopes granted._
- [Grant Types](https://oauth.net/2/grant-types/)
    - [A Guide to OAuth2 Grants](https://alexbilbie.com/guide-to-oauth-2-grants/) | [OAuth2 Simplified](https://aaronparecki.com/oauth-2-simplified/#authorization) | [Understanding OAuth2](http://www.bubblecode.net/en/2016/01/22/understanding-oauth2/)
    - Use [Authorization Code Grant](https://tools.ietf.org/html/rfc6749#section-4.1) type.
        - Redirect is to server-side handler, which appends its app creds (`ClientID` and secret)  to user's authorization code recieved from Identity Provider, and sends that back to the Identity Provider to obtain an Access Token (JWT).
            - Not sure if this last bit is necessary; authorization code from Identity Provider may be all we need. ___Do we want/need actual access to user account at Identity Provider?___
- [Actors](https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth#oauth-actors)
    - Client: 
        1. Public (Frontend app; javascript); can't be trusted with secret key.
        1. Confidential; (API server) can be trusted with secret key.
    - Resource Owner (RO): Owner and role of an app user; @ app frontend (browser).
    - Resource Server (RS): Our API server.
    - Authorization Server (AS): Identity Provider (Facebook, Twitter, Google, ...)
- [Tokens]
1. [What Is OAuth?](https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth "2017 @ okta.com")
    - _OAuth is a delegated authorization framework for REST/APIs. ... enables apps to obtain limited access (scopes) to a user’s data sans password.  It_ ___decouples authentication from authorization___ &hellip;
1. [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2)
1. [Implementing OAuth 2.0 with Go](https://www.sohamkamani.com/blog/golang/2018-06-24-oauth-with-golang/ "SohamKamani.com 2018")

![graphic](SSO-process.png "SSO Process")

<a name="oidc"></a>
## [OpenID Connect (OIDC)](https://openid.net/specs/openid-connect-discovery-1_0.html) 1.0 

>_OIDC_ [extends OAuth 2.0](https://developer.okta.com/blog/2017/06/21/what-the-heck-is-oauth#enter-openid-connect "okta.com") &hellip; _with a new signed `id_token` for the client and a `UserInfo` endpoint to fetch user attributes; is a simple identity layer on top of the OAuth 2.0 protocol. &hellip; a standard set of scopes and claims for identities._

>_Examples include: profile, email, address, and phone. &hellip; built-in registration, discovery, and metadata for dynamic federations. You can type in your email address, then it dynamically discovers your OIDC provider, dynamically downloads the metadata, dynamically know what certs it’s going to use, and allows BYOI (Bring Your Own Identity). It supports high assurance levels and key SAML use cases for enterprises._

## Misc/Other/Older References

- Client ID and Secret
    - OAuth providers issue a client ID per application. The ClientID is public information, and is used to build login URLs, or included in Javascript source code on a page. The client secret must be kept confidential. If a deployed app cannot keep the secret confidential, such as single-page Javascript apps or native apps, then the secret is not used, and ideally the service shouldn't issue a secret to these types of apps in the first place._

URL sent to GitHub (OAuth Identity Provider) from our application
```
https://github.com/login/oauth/authorize?client_id=<APPs_GITHUB_OAUTH_ID>&redirect_uri=http://<APPs_DOMAIN>/oauth/redirect
```
Redirect URL is where we want Identity Provider (GitHub) to send this user upon SSO authentication per GitHub.
```
http://<APPs_DOMAIN>/oauth/redirect
```

After registering your app, you will receive a client ID and optionally a client secret. The client ID is considered public information, and is used to build login URLs, or included in Javascript source code on a page. The client secret must be kept confidential. If a deployed app cannot keep the secret confidential, such as single-page Javascript apps or native apps, then the secret is not used, and ideally the service shouldn't issue a secret to these types of apps in the first place.

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (MD | HTML)

([HTML](___ "___"))   


# Bookmark

- Reference
[Foo](#foo)
- Target
<a name="foo"></a>

-->

