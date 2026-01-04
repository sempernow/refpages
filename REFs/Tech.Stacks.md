# Tech Stacks

### [Live Streaming CDN](https://www.dacast.com/blog/blog-top-7-cdn-providers-for-html5-live-video-streaming/ "'CDN Providers for HTML5 Live Video Streaming' 2019 @ dacast.com") | `PRJ.LiveStreaming` ([MD](PRJ.LiveStreaming.html "@ browser"))   


- [AWS Live Streaming](https://aws.amazon.com/blogs/media/frequently-asked-questions-about-the-cost-of-live-streaming/) (cost/hr)   
    - $151/hr/1,000 viewers, calculated from &hellip;   
     $753/hr/5,000 viewers &hellip;
        - AWS Elemental MediaLive (__transcoding__)   
        $4.87 + $1.176 = $6.046/hr
        - CloudFront CDN (__distribution__)   
        $747.07/hr  (__99% of the cost__)  
- [Wowza OVP](https://www.wowza.com/)   
    - $96.00/hr/1000 viewers &hellip;
        - 3 TB @ $200/mo for 3 TB   15GB/$1 ($0.067/GB)   
    @ 1 hr @ 400 KB/s = 1.44 GB   
    x 1,000 viewers =  1.44 TB   
    $96.00/hr (of the $200/mo alottment)
    - [uscreen.tv](https://www.uscreen.tv) (_Now Unauthorized.TV ?_) 
    - $400/mo for 2,500 viewers (1,000 concurrent)

### [YouTube](https://www.youtube.com) 

- Bitrate @ `720p` playback 
`230 KB/s` (`1.8 Mbps`)
- Bitrate @ `720p` playback 
`325 KB/s` (`2.6 Mbps`) 

### [Unauthorized.tv](https://www.unauthorized.tv)  

- Bitrate @ `720p` playback 
`460 KB/s` (`3.7 Mbps`) 
- DevTools > Network > Req/Resp while playing video ([MD](Unauthorized.tv-headers-req.resp.html "@ browser")) 
- Using uscreen.tv white-box VOD service.
- Using Stripe.com; player within 2 nested `iframes`   

    ```html
    <iframe  
        src="https://js.stripe.com/v2/m/outer.html#url=https://www.unauthorized.TV ..." ...>
    </iframe>
        ...
        <iframe
            src="https://m.stripe.network/inner.html#url=https://www.unauthorized.TV ..." ...>
        </iframe>
    ```

### [Slack](https://api.slack.com/start/overview "api.slack.com") | [@Wikipedia](https://en.wikipedia.org/wiki/Slack_%28software%29)

_Searchable Log of All Conversation and Knowledge_ (SLACK)  

- Group/team messaging/voice/video. Searchable record.
- [Tech Stack](https://www.quora.com/What-is-the-tech-stack-behind-Slack "Slack CTO @ Quora"); custom protocol; originally IRC;   
public API; 3rd-party integrations.  
    - Backend 
        - AWS servers @ __Kubernetes__;  __Terraform__, __Chef__.
        - Chat (msgs) @ __Java__+__Go__; __WebSockets__
        - Voice + video @ __Elixr__; some __Node.js__ 
        - __gRPC__, __Thrift__, JSON-over-HTTP    
        - __PHP__/Hacklang @ HHVM
        - __Kafka__ and __Redis__ async queue system.  
        - __MySQL__/Vitess/Memcached+MCRouter  
        - __SolrCloud__ search
        - __HAproxy__ LB; __Consul__ for config + service discovery.  
        - Data warehouse @ __Presto__, __Spark__, Airflow, __Hadoop__ and __Kafka__.   
        - Metrics @ __Prometheus__; logging @ __ELK__.
    - Frontend (Web; Desktop; Android; iOS)
        - __React__/ES6; __Electron__; __Java__/__Kotlin__; __C__/__Swift__   
- Freemium Model  
    - Free to search up to 10,000 archived messages.   
    - Paid for unlimited, and add unlimited apps and integrations.
- Biz Growth  
    - 2013: 8,000 signups in 24 hrs of launch.   
2015: 10,000 new DAU/wk; 135,000 paying customers; 60,000 teams.  
2015: 200,000 paid subs; 750,000 DAU.  
2018: 8M active users; 3M paid accounts.  
2019: 10M DAU; 600,000 orgs; 150 countries. 


### [WhatsApp](https://www.whatsapp.com/) | [@Wikipedia](https://en.wikipedia.org/wiki/WhatsApp#Technical) | [@quora.com](https://www.quora.com/What-technology-is-used-in-WhatsApp "What technology is used in WhatsApp? [2017]") | [@highscalability.com](http://highscalability.com/blog/2014/2/26/the-whatsapp-architecture-facebook-bought-for-19-billion.html "The WhatsApp Architecture Facebook Bought For $19B [2014]")     

- Messaging and VoIP service
    - __IM__ originally; +__voice__ @ 2015; +__video__ @ 2016; IM-delete(@<7min) @ 2017  
    - __Multimedia img/audio/vid messages__ are uploaded to HTTP server; server sends __content link__ (incl. Base64-encoded thumbnail if img|vid) to app.  
    - End-to-end Encryption  
    - WhatsApp Payments (P2P)   
        - @ India only; in-app payments and money transfers using Unified Payments Interface (UPI); enables account-to-account transfers from a mobile app without having any details of the beneficiary's bank.
    - Cryptocurrency project @ 2019.  
- Erlang @ FreeBSD; XMPP (customized version); [Mnesia DB](https://en.wikipedia.org/wiki/Mnesia "Wikipedia").  
    - [Ejabberg](https://en.wikipedia.org/wiki/Ejabberd "Wikipedia") server; Jabber/[XMPP + HTML5 WebSockets](https://blog.contus.com/how-whatsapp-works-technically-and-how-to-build-an-app-similar-to-it/ "blog.contus.com 2019").  
        - @ 2019, 1.5B users; @ 2014, 10 billion messages a day @ 500M Active Users
        - __Message queue length__ is primary gauge of system health.   
        - Hot-loading means updates/fixes can be pushed without restarts or traffic shifting; loosely-coupled; easy to roll changes out incrementally.  
            - SSL socket to the WhatsApp __server pools__.   
            - All messages are queued on server until client reconnects/retrieves.   
            - Messages are wiped from the server memory on client receipt.  
                - Retrieval notice sent back to server; forwards this status back to sender. (Sender sees "checkmark" icon next to message).    
- Registering Users (Sign-up)   
User ID = [Jabber](https://en.wikipedia.org/wiki/Jabber.org "Jabber.org :: The original IM service [1999]; used XMPP.") ID = `{phone-number}@s.whatsapp.net` . Originally, created a user/pass based on user's phone __IMEI number__; changed recently. Now uses client request to send _temporary_ __5 digit PIN__ via SMS to client phone. Using the PIN, client app requests/recieves/stores a unique key (password), used thereafter to validate.  
    - Newer method, PIN per SMS, allows registering a client app on a different device.   
    - The key is stored in the app/device; registering new device invalidates old key.

<a name="wechat"></a>

### [WeChat](https://en.wikipedia.org/wiki/WeChat "Wikipedia")/Tencent QQ (IM) [China](https://weixin.qq.com/ "weixin.qq.com") | [US](https://www.wechat.com/en/ "wechat.com/en/")

- Erlang @ [OpenStack](https://www.openstack.org/ "OpenStack.org"); [Tencent Cloud (TStack)](https://thenewstack.io/tencent-serving-billion-users-openstack/ "thenewstack.io [2017]").  
    -  [Ejabberg](https://en.wikipedia.org/wiki/Ejabberd "Wikipedia") server; XMPP + HTML5 WebSockets.  
    - Client-side storage [(`EnMicroMsg.db`)](https://guardianproject.info/2013/12/10/sqlcipher-has-300-million-mobile-users-thanks-to-wechat/ "'SQLcipher has 300M Mobile Users ... WeChat' @ GuardianProject.info") is an encrypted SQLite database ([SQLcipher](https://www.zetetic.net/sqlcipher/open-source/ "@ Zetetic.net")).  
- [Mini-Program](https://en.wikipedia.org/wiki/WeChat#WeChat_Mini_Program "Wikipedia") (3rd-party) Devs | [`MINA` API](https://developers.weixin.qq.com/miniprogram/en/dev/index.html?t=19051021 "MINA :: WeChat native framework @ developers.weixin.qq.com")/framework | [other frameworks](https://medium.com/le-wagon/wechat-mini-programs-which-development-framework-choose-in-2018-6ae493d6fea0 "'WeChat Mini-Programs ...frameworks in 2018' [medium.com]") | [GitHub user Wiki](https://github.com/apelegri/wechat-mini-program-wiki "apelegri/wechat-mini-program-wiki") | [Search](https://www.google.com/search?q=wechat+mini+program&source=lnt&tbs=qdr:y&sa=X "< 1yr")  
    - __MP__ (app) embeds in WeChat app; __Javascript + WeChat API__.   
    - An MP can __sell direct to consumers__ per WeChat payment services.   
    - [_Open and use! No download, no install._](https://medium.com/le-wagon/entrepreneurs-how-to-make-your-own-wechat-mini-program-903997156f24 "'...make your own WeChat Mini-Program' @ medium.com")   
    - [1M apps (MPs) @ 2019](https://uxplanet.org/wechat-mini-program-design-15-best-practices-to-create-an-awesome-user-experience-6c298cb634ba "MP Best Practices"); already half that of Apple Store;   
        - 35% of MP traffic is __sharing via chat__ (sends a sharing card).  
- [WeChat Pay](https://en.wikipedia.org/wiki/WeChat#WeChat_Pay_payment_services)      
    - Funds transfer is not immediate;  
    bank account linked; Visa, MasterCard &amp; JCB (Discover/UnionPay/RuPay)    
    - Digital Wallet; money transfers between contacts, and to 3rd parties;   
    - _Virtual Red Envelope_; send money as gift; __very popular__  
    - [Alipay](https://en.wikipedia.org/wiki/Alipay)/Alibaba  (Ant Financial) __is competitor__.   
        - Funds transfer is not immediate;   
        settlement time depends on the payment method;  
        __unlike__ _Instant Pay_ systems, e.g., [Venmo](https://en.wikipedia.org/wiki/Venmo) (PayPal Mobile), [Zelle](https://en.wikipedia.org/wiki/Zelle_%28payment_service%29).  
        - USA affiliate [First Data](https://en.wikipedia.org/wiki/First_Data)  

### [Viper](https://en.wikipedia.org/wiki/Viber)/Rakuten   

- IM/VoIP/video; developed in Israel.  
- Users are registered and identified through a cellular telephone number.  
- 1B registered users @ 2018  
Japan &amp; Russia are its big markets.

## Comments as a Service 

### [Commento](https://commento.io/) commenting platform | [@GitHub](https://github.com/adtac/commento "adtac/commento")  

- Golang; "_A fast, bloat-free, privacy-focused commenting platform_"  
- Commento, Inc. 2016, Delaware, #6797473  
adtac:  Adhityaa Chandrasekar  
- [Show HN: Commento](https://news.ycombinator.com/item?id=19210697):  
"_a fast, privacy-focused alternative to Disqus_" (commento.io)  

### [DISQUS](https://disqus.com/) | [Disqus tech [2014]](http://highscalability.com/blog/2014/4/28/how-disqus-went-realtime-with-165k-messages-per-second-and-l.html)  

- Python/Django (DISQUS) => Golang (Realtime) => 5x NGINX (Push Stream)  
    - New Posts -> Disqus -> redis queue   
    ->  “python glue” Gevent formatting server (2 servers)   
    -> http post -> nginx pub endpoint   
    -> nginx + push stream module (5 servers)   
    <- clients    
        - 1M connections concurrently; 500M users @ 2014  
        - 3,200 connections/sec  
        - 150K/130K (TX/RX) packets  
        - 150/80 Mbps (TX/RX)  
        - < 15ms latency end-to-end; faster than JS front-end can render  
- @ Python   
    - [Greenlets](https://learn-gevent-socketio.readthedocs.io/en/latest/greenlets.html) (`gevent` pkg); _lightweight thread-like structure_.   
- @ [NGINX](https://www.nginx.com/resources/wiki/modules/push_stream/ "NGINX.com :: Puch-Stream Module") | [@YouTube](https://www.youtube.com/watch?v=yL4Q7D4ynxU)  
    - Ubuntu `sysctl` settings to handle max load  
    - Shrink prealloc @ gzip on NGINX to 32KB; default is 264KB/conn; content is only ~ 2KB  
    

### JAMstack   

- Lambda (JSON) -> SMS-slack (Approval) -> Lambda -> Static HTML Generator/Server

### Facebook comments page

- `2 MB` of files + `200 KB` page (`.html`)
- [Comment form &amp; 1 comment block (examples)](facebook.comment.html)
- [1 embedded JSON (truncated example)](facebook.comment.json)
- [Graphic of comments section](facebook.comments.section.PNG)  
[Graphic of comments section on-click](facebook.comments.section-on-click.PNG)

### &nbsp;