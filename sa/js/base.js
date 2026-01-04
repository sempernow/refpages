const __APP__ = '⚒' // ⚒ ☡ ☧ ☩ ☘ ☈ ☉ ☄ ☆ ◯ 웃 𝐀𝐏𝐏 𝐋𝐀𝐁
//... an application namespace (context), window.__APP__, is REQUIRED.
;(function(o, undefined){
    'use strict'
    /**************************************************************************
     * DEFAULT config. REQUIRED parameters; window.__APP__ is also REQUIRED.
     *************************************************************************/
    o.cfg = o.cfg ? o.cfg : {
        base:  {       
            // Base mode(s)
            bModesCSV: 'test,prod'
            ,bMode: 'test'
            ,p2qRate: 1000
            ,lockPeriod: 30
            // Logger params
            ,logLevelsCSV:  'verbose,info,globals,workers,warn,error,focus,debug,none'
            ,logLevelAllow: 'info' // Set minimum log level (default is 'info')
        }
        ,net: {}
        ,view: {badgeList: []}
     }
     const base = o.cfg.base

    /**************************************************************************
     *  App-specific declarations.
     **************************************************************************/
    {
        // State : Action Modes
        o.aModes = {
            replay:  0,
            mutate:  1,
            promise: 2
        }

        // Transaction.XIS : Transaction.XID model's type
        o.TxnXIS = {
            Message: 1,
            Channel: 2,
            User: 3,
            Group: 4,
        }

        // Transaction.Act : Actions per model
        o.TxnAct = {
            // @ Message only; TokensQ only
            Punish: 0, 

            // @ Channel, User, or Group; TokensQ or TokensP
            Sponsor: 1,      // Sponsor is one-off or nth Subscribe
            Subscribe: 2,    // Idempotent (q=1); Unfollow @ q = -1; Unsubscribe @ q = -2
            P2q: 3,          // Exchange P for q tokens at app rate.

            // @ User only; TokensP only
            ExchZero: 4,
            ExchBuyin: 5,
            ExchPayout: 6,
        }

        o.AuthModes = {
            SignUp:      'SU',
            BasicAuth:   'BA',
            ObfuscateBA: 'OB',
            DigestAuth:  'DA',
            OAuth2:      'OA',
            WebAuthn:    'WA'
        }
        o.TknTypes = {
            tknR: 'R',
            tknA: 'A'
        }

        // Data types
        o.dTypes = {
            full: 'full', // @ init or OLDER than
            diff: 'diff', // @ NEWER or OLDER than that in cache (patch; differential)
            update: 'update',
        }//... declared per Net payload. Type `full` contains all the data required by its component(s); 
        // initialization data, or OLDER data fetched subsequent to page load. I.e., full data set(s). 
        // Type `diff` contains patch data, either NEWER OR OLDER than that in cache. I.e., differential data set(s).

        o.mForm = {
            short: 1,
            long: 2,
        }
        // MsgList types 
        o.mlTypes = {
            chn: 1,
            pub: 2,
            sub: 3,
            th: 4,

            newest: 5,
            trending: 6,
            popular: 7,
            valued: 8,

            sponsubs: 9,
            owned: 10,
        }
        // Top-list types (messages or channels)
        o.topTypes = {
            newest: 5,
            trending: 6, // channels only
            popular: 7,
            valued: 8,
        }

        // View types
        o.vTypes = {    
            self:    0, // Any template literal
            page:    1, // Shell + Channel
            shell:   2, // Shell only
            partial: 3, // Channel
            diff:    4  // Patch
        }

        // Privacy / Visibility
        o.Privacy = {
            All:        0,
            Members:    1,
            SubersFree: 2,
            SubersPaid: 3,
            GrpMembers: 4,
            GrpLeaders: 5,
            Recipient:  6,  
            Self:       7,
            Hidden:     8,
            Ops:        9,
        }

        // Add k-v pairs to a context (object) per Computed Properties (ES6)
        // based on a CSV list of keys, per list index; <prefix><KEY>: (i+1).
        o.toContextIndexed = (csv, ctx = window, prefix = '') => 
            csv.split(',').map((key, index) => 
                ctx[prefix + key.toUpperCase()] = (index + 1)) 

        // Base Modes : Profiler is off in PROD mode.
        o.toContextIndexed(base.bModesCSV, o.bModes = {})
        o.bMode = o.bModes[base.bMode.toUpperCase()] || o.bModes.PROD
        //console.log(o.bModes, o.bMode) // {TEST: 1, PROD: 2} 2 

        // Buyin limit (days)
        o.LockPeriod = (o.bMode === o.bModes.TEST) ? 0 : o.cfg.base.lockPeriod 

        // Strip prefix, `x-`, from markup IDs of `x-UUID` format
        o.getID = val => val.substring(2)

        /**********************************************
         * URL generators, per endpoint, per service.
         *********************************************/
        const {
            rootAOA,
            baseAOA,
            rootAPI,
            baseAPI,
            rootPWA,
            basePWA,
        } = o.cfg.net
        o.urlAOA = (path) => `${rootAOA}${baseAOA}${path}`
        o.urlAPI = (path) => `${rootAPI}${baseAPI}${path}`
        o.urlPWA = (path) => `${rootPWA}${basePWA}${path}`

        /*******************************************************
         * Badges (per bitmask scheme) : Awarded to members
         * 
         * See config (cfg.js) and source template (cfg.gojs)
         ******************************************************/
        // The full list (array) of all badge objects (Golang: badges.Badge)
        o.badgeList = o.cfg.view.badgeList.reverse()

        // Get array of badge objects per bitmask value.
        o.getBadges = (dec) => o.badgeList.filter(b => (dec & Math.pow(2, +b.bit))) 

        // Get array of badge glyphs per bitmask value.
        o.getGlyphs = (dec) => o.getBadges(dec).map(o => o.glyph)   

        // Get array of badge nodes per bitmask value.
        o.makeBadgeNodes = (dec) => o.getBadges(dec)
            .map(b => `<span title="${b.name + (b.dscr ? ': '+b.dscr : '')}">${b.glyph}</span>`)

        // UNUSED ...
        o.name = __APP__ || 'FAILs'
        o.utfDEL = '␡' // 'SYMBOL FOR DELETE' (U+2421) &#x2421
    }

    /**************************************************************************
     * Library of ES6-congruous utilities
     **************************************************************************/
    
    // ===================
    // ===  POLYFILLs  ===
    // =================== 
    // Polyfill for HTMLCollections @ Edge/Safari, ELSE NOT ITERABLE.
    // Iterate over collection: ;[...nodeList].map(i => doStuff(i))
    if (typeof HTMLCollection.prototype[Symbol.iterator] !== 'function') {
        HTMLCollection.prototype[Symbol.iterator] = function () {
            let i = 0
            return {
                next: () => ({done: i >= this.length, value: this.item(i++)})
            }
        }
    } // by https://gist.github.com/rtoal 

    // ==============
    // ===  META  ===
    // ==============
    {   const isType  = x => Object.prototype.toString.call(x) 
        o.isType  = isType 
        o.isFunction   = x => isType(x) === '[object Function]'
        o.isObject     = x => isType(x) === '[object Object]'
        o.isArray      = x => isType(x) === '[object Array]'
        o.isPromise    = x => isType(x) === '[object Promise]'
        o.isString     = x => isType(x) === '[object String]'
        o.isNumber     = x => isType(x) === '[object Number]'
        //isNaN(o) // ES6 builtin; obj.length
       
        o.isAlphaNum = (x) => /^[a-z0-9]+$/i.test(x)
        o.isDigits = (x) => /^\d+$/.test(x)

        //o.isUndefined = x => isType(x) === '[object Undefined]' // FAILs if is
        ;(typeof x === 'undefined') //... cannot implement as function

        o.objNameToString = x => Object.keys({x})[0] 

        o.has = (x, y) => o.isObject(x) && x.hasOwnProperty(y) // @ object
                            || o.isArray(x) && x.includes(y)   // @ array 
        // a = {b:{foo:{bar:1}}}; o.has(a,'foo') is false; o.has(a.b,'foo') is true
    }
    // UNUSED 
    {
        o.fnameURI = function _fnameURI(path) {
            if (typeof path !== 'string') return ''
            path = decodeURI(path)
            return path.substring(path.lastIndexOf('/')+1) || ''
        }

        function curry(fn0) {
            var arityFn0 = fn0.length
        
            return function curriedFn1() {
                var argsFn1 = Array.prototype.slice.call(arguments, 0)
                if (argsFn1.length >= arityFn0) {
                    return fn0.apply(null, argsFn1)
                }
                else {
                    return function curriedFn2() {
                        var argsFn2 = Array.prototype.slice.call(arguments, 0)
                        return curriedFn1.apply(null, argsFn1.concat(argsFn2))
                    }
                }
            }
        }//... http://blog.carbonfive.com/2015/01/14/gettin-freaky-functional-wcurried-javascript/

        function getProp(key,obj) {
            return obj[key]
        }    
        function setProp(key,obj,val) { // clone
            var o = Object.assign( {}, obj )
            o[key] = val
            return o
        }

        function setObj(key,val) {
            return setProp( key, {}, val )
        }
    }

    // =========================
    // ===  DATA PROCESSING  ===
    // =========================
    {  
        o.uuidv4 = () => {
            switch (!!(window.crypto || window.msCrypto)) {
                case true:
                    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
                        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
                    )//https://gist.github.com/jed/982883
                case false:
                    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
                        const r = Math.random() * 16 | 0
                            ,v = (c == 'x') ? r : (r & 0x3 | 0x8)
                        return v.toString(16)
                    })
            }
        }// http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript

        o.uuid_nil = '00000000-0000-0000-0000-000000000000' 
        //... PostgreSQL: uuid_nil(); Golang: uuid.Nil.String()

        // digest : algos @ SHA-1, SHA-256, SHA-384, SHA-512
        // https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/digest
        // https://caniuse.com/?search=crypto.subtle  (97%)
        o.digest = async (algo, data) => {                                 // 94% (async)
            if (!crypto.subtle) return false // (!self.isSecureContext)
            const 
                msgUint8    = new TextEncoder().encode(data)               // 95%
                ,hashBuffer = await crypto.subtle.digest(algo, msgUint8)   // 95% 
                ,hashArray  = Array.from(new Uint8Array(hashBuffer))       // 93%
                ,hashHex    = hashArray.map(b => b.toString(16).padStart(2, '0')).join('') 
            return hashHex
        }// https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/digest

        // Returns a promise
        o.sha1   = (str) => o.digest('SHA-1', str)    
        o.sha256 = (str) => o.digest('SHA-256', str)  
        o.sha512 = (str) => o.digest('SHA-512', str)  
        //o.sha512(crypto.getRandomValues(new Uint32Array(1))[0])//.then(log) //=> h9brsxv49s86akvvlxiduy

        // Random integer
        o.randInt = max => Math.floor(Math.random() * (max+1))

        // Random alphanum (sync)
        o.rand = (len = 20) => {//... Alpha-num
            const s = [], n = (Math.floor(len/11) + len%11)
            for (let i = 0; i <= n; i++) {
                s.push(Math.random().toString(36).substring(2, 15))
            }
            return s.join('').substring(0, len)
        }
        // Random alphanum (async)
        //o.aRand = () => o.sha512(crypto.getRandomValues(new Uint32Array(1))[0])//.then(log) 

        // Base64 encode/decode a string (@ WindowOrWorkerGlobalScope).
        //o.base64Encode = (s) => self.btoa(s)
        //o.base64Decode = (s) => self.atob(s)

        // UPDATE : Handle Unicode (UTF-8)
        // https://attacomsian.com/blog/javascript-base64-encode-decode  
        // https://reference.codeproject.com/book/javascript/base64_encoding_and_decoding
        // https://caniuse.com/?search=encodeURIComponent (96%)
        o.base64Encode = s => btoa(encodeURIComponent(s)
            .replace(/%([0-9A-F]{2})/g, (match, p1) => String.fromCharCode('0x' + p1))
        )
        o.base64Decode = s => decodeURIComponent(atob(s).split('')
            .map(c => ('%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))).join('')
        )

        //... to Base64URL, must pre-process string per (<from>:<to>) map +:- and -:_
        // and optionally post-process `=` per map =:%3D .
        // https://stackoverflow.com/questions/55389211/string-based-data-encoding-base64-vs-base64url
        // - JWT (RFC7519) segments (<header>.<payload>.<signature>) are each Base64URL encoded.
        // - Basic HTTP Auth (RFC7617) request-header value (<user-id>:<pass>) is Base64 encoded.

        o.base64urlEncode = (s) => self.btoa(s).replace(/\//g, '_').replace(/\+/g, '-').replace(/=/g, '')
        o.base64urlDecode = (s) => {
            s = s.replace(/-/g, '+').replace(/_/g, '/')
            var pad = s.length % 4
            if(pad) {
                if(pad === 1) { throw new Error('Invalid Length') }
                s += new Array(5-pad).join('=')
            }
            return self.atob(s)
        }// https://stackoverflow.com/questions/5234581/base64url-decoding-via-javascript 

        // Decimal to Binary 
        o.dec2bin = dec => +(dec >>> 0).toString(2)

        // FAILING
        o.xor = (text, key) => { 
            // http://evalonlabs.com/2015/12/10/Simple-XOR-Encryption-in-JS/
            // FAILs @ Unicode 
            const kL = key.length 
            //if (!kL) return text //... ??? Better to fail hard.
            return Array.prototype.slice.call(text).map((c, i) => {
                return String.fromCharCode(c.charCodeAt(0) ^ key[i % kL].charCodeAt(0))
            }).join('')
        }

        // Reverse a string.
        o.rev = x => o.isString(x) ? x.split('').reverse().join('') : x

        // Replace all substrings (using well-adopted methods).
        // The ES6 native, str.replaceAll(...), has merely 86% adoption (CanIuse.com)
        o.replaceAll = (str, have, want) => str ? str.split(have).join(want) : ''

        // Parse a JSON Web Token (JWT)
        o.parseJWT = (tkn) => { 
            if (!o.isString(tkn)) return false
            const arr = tkn.split('.')
            if (arr.length < 3) return false
            return {
                header: JSON.parse(o.base64urlDecode(arr[0])),
                payload: JSON.parse(o.base64urlDecode(arr[1])),
                signature: o.base64urlDecode(arr[2])
            }
        }// https://en.wikipedia.org/wiki/JSON_Web_Token
        // https://developer.mozilla.org/en-US/docs/Web/API/AuthenticatorResponse/clientDataJSON

        /************************************************************ 
         * JSON Parsers : Handle all scenarios; catch all errors.
         ***********************************************************/
        // Synchronous
        o.parse = (x) => {
            if (typeof x !== 'string') return x
            try {return JSON.parse(x)} // TODO: +DOMParser
            catch(e) {return {data: x, err: e}}
        }
        // Asynchronous
        o.aParse = (x) => {
            if (typeof x !== 'string') return Promise.resolve(x)
            try {return Promise.resolve(JSON.parse(x))}
            catch(e) {return Promise.reject({data: x, err: e})}
        }

        // Object : Clone 
        o.clone = (x) => o.parse(JSON.stringify(x))  
        //... DEEP COPY BY VALUE; LIMITATION: Not all objects are JSON-safe.

        //o.arrSeq = (n) => [...Array(parseInt(n)).keys()] // [0, 1, ..., n]
        o.arrSeq = (len, start = 1) => [...Array(start+len).keys()].slice(start) 
        // [start, (start + 1), ..., (start + len - 1)]; E.g., o.arrSeq(3, 7) //=> [7, 8, 9]

        o.arrCopy = (a) => a.slice() // FASTEST; Objects (elements) are COPY BY REFERENCE.

        o.arrsConcat = (a, b) => a.push.apply(a, b) //... IN PLACE, unlike: c = a.concat(b)
        //... and 3x faster than b.map(el => a.push(el)).
 
        // Array : Deduplicate; guarantee every element is unique
        o.dedup = list => [...new Set(list)]

        // Array : Diff
        //o.arrDiff = (a, b) => a.filter(x => !b.includes(x)) // 93% @ canIuse.com
        o.arrDiff = (a, b) => { 
            var i
            const la = a.length, lb = b.length, diff = [] 
            if (!la) return b
            else if (!lb) return a
            for (i = 0; i < la; i++) { 
                if (b.indexOf(a[i]) === -1) diff.push(a[i])
            } 
            for (i = 0; i < lb; i++) { 
                if (a.indexOf(b[i]) === -1) diff.push(b[i])
            } 
            return diff
        }//... https://stackoverflow.com/questions/1187518/how-to-get-the-difference-between-two-arrays-in-javascript/33034768#33034768
    }

    // ===================
    // ===  DATE/TIME  ===
    // =================== 
    {// Date  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date

        o.nowSec = () => Math.floor(o.nowMsec() / 1000)      
        //... Epoch [seconds]
        o.nowMsec = () => Math.floor((new Date()).getTime())  
        //... Epoch [milliseconds] 
        o.nowISO = () => (new Date()).toISOString() 
        //... yyyy-mm-ddThh:mm:ss.MMMZ  [RFC3339]      // 1 Millisecond resolution
        o.nowUTC = () => (new Date()).toUTCString() 
        //... Www, DD Mmm yyyy hh:mm:ss GMT            // 1 Second resolution

        //o.timeUnix0 = 0           // 1970-01-01T00:00:00.000Z
        //o.timeUnix0 = 1111111111    // 2005-03-18T01:58:31.000Z

        /*************************************************************************
         * Conversions : UTC|ISO|Date-str of any Offset to Epoch
         *************************************************************************/
        o.UTCtoSec = (utc) => Math.floor((new Date(utc)).getTime()/1000)  
        //... "Sun, 30 Aug 2020 19:11:56 GMT" => 1598814716
        o.UTCtoMsec = (utc) => (new Date(utc)).getTime()  
        //... "Sun, 30 Aug 2020 19:11:56 GMT" => 1598814716000
        o.DateStrToEpoch = (str) => o.UTCtoMsec(str)
        //... "August 30, 2020 19:11:56" => 1598814716000

        /************************************************************************
         * Normalize Epoch (CSV list) to preferred units (sec|msec) 
         ************************************************************************
         * @param {string|int (sec|msec)} ttt  (CSV list)
         * 
         * Usage: [tZ1, tZ0] = o.toTimesMsec(t1, t0)
        */
        // Normalize Epoch (CSV list) to seconds (array)
        o.toTimes = (...ttt) => [...ttt].map(t => {//... t1, t2, t3, ...
            if (isNaN(t)) t = parseInt(t, 10)
            if (t.toString().length > 11) t = Math.floor(t/1000)
            return t //... Epoch array [seconds] 
        }) 
        // Normalize Epoch (CSV list) to milliseconds (array)
        o.toTimesMsec = (...ttt) => [...ttt].map(t => {//... t1, t2, t3, ...
            if (isNaN(t)) t = parseInt(t, 10)
            if (t.toString().length <= 11) t = Math.floor(t*1000)
            return t //... Epoch array [milliseconds]
        }) 

        /************************************************************************* 
         * Conversions : Epoch (UNIX) [integer]  <==>  UTC|RFC3339/ISO [string]
         * **********************************************************************/
        // ADT is UTC-03 | EDT/AST is UTC-04 | EST is UTC-05

        //o.time2ISO = (t) => (new Date(o.toTimes(t)[0]*1000)).toISOString() 
        o.time2ISO = (t) => (new Date(o.toTimesMsec(t)[0])).toISOString() 
        //... yyyy-mm-ddThh:mm:ss.MMMZ  (RFC3339)
        //o.time2UTC = (t) => (new Date(o.toTimes(t)[0]*1000)).toUTCString() 
        o.time2UTC = (t) => (new Date(o.toTimesMsec(t)[0])).toUTCString() 
        //... Www, DD Mmm yyyy hh:mm:ss GMT

        o.ttl = (t) => {
            if (isNaN(t)) return 0
            const now = o.UTCtoSec(o.nowUTC())
            return (t > now) ? (t - now) : 0  // seconds
        }
        
        /************************************************************************* 
         * Age
         ***********************************************************************/

         // Age of one epoch value (tZ1) relative to another (tZ0)
        o.ageDelta = (tZ1, tZ0) => {//... handle str|int; sec|msec
            [tZ1, tZ0] = o.toTimes(tZ1, tZ0)
            if (isNaN(tZ1 - tZ0)) return 'age unknown'
            const sec = 6
                ,min = 60
                ,hr = 3600
                ,day = 86400
                ,mo = 2592000
                ,yr = 31104000

                ,dt = tZ1 - tZ0
                ,almost = 0.9

            var t, age
            if (dt < sec) {
                return 'just now'
            } else if (dt < almost * min) {
                t = Math.round(dt); age = 'second'
            } else if (dt < almost * hr) {
                t = Math.round(dt / min); age = 'minute'
            } else if (dt < almost * day) {
                t = Math.round(dt / hr); age = 'hour'
            } else if (dt < almost * mo) {
                t = Math.round(dt / day); age = 'day'
            } else if (dt < almost * yr) {
                t = Math.round(dt / mo); age = 'month'
            } else {
                t = Math.round(dt / yr); age = 'year'
            }
            return t + ((t > 1) ? ` ${age}s` : ` ${age}`) + ' ago'
        }

        // Age of epoch value (t in seconds or milliseconds) 
        // relative to now; current age.
        o.ageNow = (t) => o.ageDelta(o.nowSec(), t)
    }

    // ================
    // ===  TIMING  ===
    // ================ 
    {
        /*****************************************************************
         * Declarative-time functions to implement scheduling 
         * of whatever is relegated to the asequenced (async) stack.
         * (Because ES6 Generator is insufficiently adopted.)
         *****************************************************************/

        /*********************
         * Synchronous sleeper 
         * @param {number} ms 
         * USAGE: doBefore; o.sleep(ms); doAfter
         ***/
        o.sleep = function _sleep(ms) {
            let t0 = Date.now()
            while (true) if ( ( Date.now() - t0 ) > ms ) break
        }
        /**********************
         * Asynchronous sleeper 
         * @param {number} ms 
         * USAGE: async () => {doBefore; await o.aSleep(ms); doAfter}
         *    OR: p(doBefore).then(o.aSleep(ms)).then(doAfter)
         ***/
        o.aSleep = function _aSleep(ms) {
            return new Promise(resolve => setTimeout(resolve, ms))
        }// or p(doBefore).then(o.aSleep(ms)).then(doAfter)

        // Synchronous delay 
        o.delay = o.sleep
        o.Delay = o.sleep
        
        // Asynchronous delay; a more readable `setTimeout` with more reliably-passed args.
        o.aDelay = (delay, fn, ...args) => {
            if (typeof fn !== 'function') return
            return setTimeout(() => fn.apply(this, args), delay)
        }

        /**********************************************************************
         * Sequence pattern useful as `waitFn` arg for others in this library. 
         * The closure cyclicly returns a "1, 2, 5" number sequence per call; 
         * 1, 2, 5, 10, 20, 50, ... in units of `t0` (3, 6, 15 @ t0=3),
         * resetting every `x10` orders of magnitude if `stay` is false, 
         * else remaining at max seqence upon `10x` cycles and thereafter.
         ***/
        o.seq125 = (t0 = 1, x10 = 4, stay = false) => {
            var seq = [1, 2, 5], [count, pwr] = [-1, -1]
            return function _seq125() {
                count++
                if (count%3 === 0) pwr++
                if (pwr === x10 && !stay) [count, pwr] = [0, 0]
                return t0 * seq[count%3] * Math.pow(10, pwr)
            }//... closure returns 1, 2, 5, 10, 20, 50, ... units of `t0`, per call.
        }//... and resets every `x10` orders of magnitude, or stays there if `stay`.
        
        // +See `o.arrSeq()`

        // Generalized version of `o.seq125()`; takes any sequence (array).
        o.seqArr = (seq, x10 = 4, stay = false) => {
            var [count, pwr] = [-1, -1]
            return function _seqArr() {
                count++
                ;(count%seq.length === 0) && pwr++
                ;(pwr > x10) && ( stay 
                    ? ([count, pwr] = [0, x10]) 
                    : ([count, pwr] = [0, 0])
                )
                return seq[count%seq.length] * Math.pow(10, pwr)
            }//... closure @ [1, 2, 5] returns 1, 2, 5, 10, 20, 50, ..., per call.
        }//... and resets every `x10` orders of magnitude, or stays there if `stay`.
        // USAGE: aScheduleSeq(seqArr(a.map(x=>3*x), 2, true), fnX, 'arg1', {obj: '@arg2'})

        // Wait on a condition (predicate func), per wait-func sequence, then fire the callback.
        o.waitUntil = function _waitUntil(predicateFn, waitFn, callbackFn, ...args) { 
            const 
                logger = () => {
                    if (o.bMode !== o.bModes.PROD) 
                        console.log(
                            `${o.name}%c [${o.nowISO().substring(17)}] waitUntil @ ${callbackFn.name}() awaiting '${predicateFn.name}' : ${t} ms ...`, "color:#0ff;"
                        )
                }

            if (!predicateFn()) { 
                var t = waitFn(); logger()
                return o.aDelay(t, () => _waitUntil(predicateFn, waitFn, callbackFn, ...args)) 
            } 
            callbackFn(...args) 
        }

        // Recurring (a)synchronous-delay scheduler per wait-func sequence.
        o.aScheduleSeq = (waitFn, callbackFn, ...args) => {
            var thisTime = waitFn()
            o.aDelay(thisTime, () => callbackFn(...args)) 
            return o.aDelay(thisTime, () => o.aScheduleSeq(waitFn, callbackFn, ...args)) 
        }

        /**********************************************************************
         * (A)synchronous scheduler whose partial returns a function 
         * scheduled to run asynchronously (deferred),
         * but sequentially ordered relative to any other so scheduled.
         * The priority arg is the timeout; lower number is higher priority. 
         * The fully invoked function launches the scheduler 
         * and returns a cancellation ID for `clearTimeout(ID)`.
         * 
         * USAGE:   const id = o.aScheduler(priority, fnName)(args)
         * CANCEL:  clearTimeout(id)
         ********************************************************************/
        o.aScheduler = (priority, fn) => function _aScheduler(...args) {
            return o.aDelay(priority, fn, ...args)
        }
        /**************************************************************************
         * (A)synchronous scheduler promise; same as `o.aScheduler`, 
         * but returns a Promise of return of `fn` that is cancellable
         * per AbortController Web API (if given that optional `signal` arg).
         * REF: https://developer.mozilla.org/en-US/docs/Web/API/AbortController
         * 
         * USAGE: 
         *      const ctrl = new AbortController()
         *      const signal = ctrl.signal
         *      o.aSchedulerP(priority, fnName, signal)(args)
         *          .then(aHandler)
         *          .catch(errHandler) //... DOMException: Aborted
         * 
         * CANCEL:
         *      ctrl.abort() 
         *************************************************************************/
        o.aSchedulerP = (priority, fn, signal) => function _aSchedulerP(...args) {
            if (signal && signal.aborted) {
                return Promise.reject(new DOMException('Aborted', 'AbortError'));
            }
            return new Promise((resolve, reject) => {
                setTimeout(() => resolve(fn), priority)
                signal && signal.addEventListener('abort', () => {
                    reject(new DOMException('Aborted', 'AbortError'))
                })
                // TODO: Add listener option `{signal: signal}`, 
                // but listener must be in a .then(..) else removed before it aborts. 
                // The signal is currently unreachable from a then(..).
                // https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener 
            }).then(fn => fn(...args))
        }
        {   /***********************************************************
            * Cancel all per one abort signal.
            * USAGE:   
            *      o.aSchedulerP(1000, fn, aScheduler.signal)
            *      o.aSchedulerP(2000, fn, aScheduler.signal)
            *      ...
            *      aSchedulerP.abort() //... cancels all.
            ***/
           const ctrl = new AbortController
           o.aSchedulerP.signal = ctrl.signal  //... use as `signal` arg
           o.aSchedulerP.abort  = () => ctrl.abort()
        }

        o.throttle = function _throttle(interval, fn) {
            let enableCall = true

            return function(...args) {
                if (!enableCall) return

                enableCall = false
                fn.apply(this, args)
                setTimeout(() => enableCall = true, interval)
            }//... https://programmingwithmosh.com/javascript/javascript-throttle-and-debounce-patterns/
        }// USAGE: o.throttle(222, fn)(args)

        // Fires AFTER interval
        o.debounce = function _debounce(interval, fn) {
            let id
            return function(...args) {
                clearTimeout(id)
                id = setTimeout(() => fn.apply(this, args), interval)
            }
        }// USAGE: o.debounce(222, fn)(args)
        //... https://programmingwithmosh.com/javascript/javascript-throttle-and-debounce-patterns/
            // Others (debounce):
                // https://github.com/utilise/utilise/blob/master/debounce.js  
                // https://github.com/utilise/utilise#--debounce
                // https://codeburst.io/throttling-and-debouncing-in-javascript-b01cad5c8edf 
                // Lodash  https://github.com/lodash/lodash/blob/4.17.15/lodash.js#L10897

        /****************************************************************
         * once(..) is a wrapper to fire fn one time 
         * regardless of times wrapper called. Apply to ctx else self.
         * @param {*} fn 
         * @param {*} ctx 
         * USAGE: x = o.once(fn, ctx); x(args)
         ***************************************************************/
        o.once = (fn, ctx) => { //... https://davidwalsh.name/javascript-once
            var result
            return function _once() { 
                if(fn) {
                    result = fn.apply(ctx || this, arguments)
                    fn = null
                }
                return result
            }
        }

    }

    // =============
    // ===  DOM  ===
    // ============= 
    // window.requestAnimationFrame(doStuff)
    // ... rAF is often worthless or worse; from no effect to page freeze.

    {   o.toDOM = (parent, child, at) => {
            /************************************************************************** 
             * Insert HTML into DOM
             * 
             * @param {Element}   parent  Exiting node.
             * @param {DOMString} child   HTML; gets parsed and inserted as new node.
             * @param {any}       at      Optional; prepend if truthy, else append.
             * 
             * USAGE: o.toDOM(o.css('#foo .bar'), '<h3>Foo</h3> <p>bar baz</p>', 1)
             * https://developer.mozilla.org/en-US/docs/Web/API/Element/insertAdjacentHTML 
             *************************************************************************/
            at = at ? 'afterbegin' : 'beforeend' 
            if (parent && child) {
                parent.insertAdjacentHTML(at, child)
                return true
            }
            return false
        }

        o.prepend = (parent, child, ref) => parent.insertBefore(child, ref)  // 97%
        o.append  = (parent, child) => parent.appendChild(child)             // 97% 
        o.del = (node) => node.remove()                                      // 96%

        // Remove all child nodes of target node
        o.purge = (target) => { 
            if (!target) return false
            while (target.firstChild) {
                target.removeChild(target.firstChild)
            }//... purportedly much faster than target.innerHTML = ''
        }

        o.getText= (node) => node && node.textContent
        o.setText = (node, text) => node && (node.textContent = text)
        o.replaceText = (node, have, want) => node && node.textContent.replace(have, want)

        o.create = (tag) => {
            return document.createElement(tag)
        }

        o.id = (id) => {
            return document.getElementById(id)
        }
        
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

        // Closest ancestor of subject node, per selector.
        o.ancestor = (subject, selector) => { 
            return subject.closest(selector)  
        } //... 95% per CanIUse.com   // node.parentElement // 96%
        // Polyfill  https://developer.mozilla.org/en-US/docs/Web/API/Element/closest

        o.getRect = (el) => { 
            /***************************************************************
             * getBoundingClientRect(..) wrapper returns a USEABLE object,
             * rather than that abomination DOMRect. 
             * 
             * USEAGE: [...Object.keys(getRect(el))].map(perKey)
             **************************************************************/
            const {
                top, right, bottom, left, width, height, x, y
            } = el.getBoundingClientRect()
            return {top, right, bottom, left, width, height, x, y} 
        }//... All positions are relative to top-left corner of viewport.

        // y-position of top of el, rounded to nearest pixel
        o.top = (el) => Math.round(el.getBoundingClientRect().top)
        //... USAGE: modalCtnr.style.top = `${o.top(ev.target)}px`

        o.copyToClipboard = (input) => {
            /*********************************************************************
             * 
             *  <input type="text" id="foo" value="The Target Content">
             *  <button type="submit">Copy</button>
             *  self.addEventListener('submit', doSubmit)
             * 
             * https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/select
             * https://www.w3schools.com/howto/howto_js_copy_clipboard.asp
             ********************************************************************/
            input.focus()
            input.select() /* Select the text field */
            input.setSelectionRange(0, 99999) /* For mobile devices */
          
             /* Copy the text inside the text field */
            return navigator.clipboard.writeText(input.value)
          } 

    }

    // ==================
    // ===  PROFILER  ===
    // ================== 
    o.profile = (ctx = 'prof', log, ctrl = true) => {
        /** Profile performance : .start() / .stop() [ms]
         * https://developer.mozilla.org/en-US/docs/Web/API/Performance/now
         * @param {string} ctx    (optional context)
         * @param {function} log  (optional logger)
         * @param {bool} ctrl     (optional on(true)|off per declaration)
         * 
         * `.start(o.log.profOFF)` to turn off per event.
         */
        var t0, t1 
        return {
            start: (off) => {
                if (o.bMode === o.bModes.PROD) return
                if (off === o.log.profOFF) ctrl = false 
                if (!ctrl) return 
                t0 = performance.now()
            },
            stop: () => {
                if (o.bMode === o.bModes.PROD) return
                if (!ctrl) return
                t1 = performance.now()
                log = log ? log : (msg) => console.log(`%c${msg}`, "color:#0ff;") // Aqua
                log(`Δt @ ${ctx} : ` + (t1 - t0) + ' ms') // 'GREEK CAPITAL LETTER DELTA' (U+0394)
            }
        }
    }

    // ================
    // ===  LOGGER  ===
    // ================ 
    const _loggerIIFE = (() => {
        /**********************************************************************
         * Logger with levels, namespaces, timestampZ, and errorFX
         * 
         * o.log(NS [, o.log.levels.<LEVEL>])(args)
         * - Top-level namespace per o.name
         * - LEVEL references @ config
         * *****************************************************
         *  Minimum LEVEL per setting @ cfg.base.logLevelAllow
         * *****************************************************
         * Usage: 
         *      log = o.log(NS); log(MSG)  
         *      //=> X [HH:MM:SS.mmmZ] [NS] MSG
         *
         *  Or fulfill all at once:
         *      o.log('foo')([1, 2], 'bar', {a: 1, b: 2})  
         *      //=> ☈ [13:58:27.353Z] [foo] [1, 2] bar { a: 1, b: 2 }
         *
         *  logDeb(o.log.debugOFF) // to turn off logDeb, per logger.
         ***********************************************************************/ 
        const logLevels = {}
            ,{  logLevelsCSV
                ,logColorInfo 
                ,logColorWarn
                ,logColorError
                ,logColorFocus
                ,logColorDebug
            } = base

        o.toContextIndexed(logLevelsCSV, logLevels)
        const logLevelAllow = base.logLevelAllow ? base.logLevelAllow : logLevels.INFO 

        function _logger(ns, level) {
            ns ? ns : ns = o.name
            level = logLevel(level)
            var debugOFF // @ `logDeb(o.log.debugOFF)`, per instance.

            // Return level number, or 0, per test against that allowed by config.
            function logLevel(level){
                level ? level : level = logLevels.INFO
                const allow = logLevelNumber(logLevelAllow)
                return !!(level >= allow) ? level : 0
            }
            // Return level number from level names declared at config.
            function logLevelNumber(level) {
                return logLevelsCSV.split(',')
                    .reduce((acc, name, i) => {
                        if (name === level) acc = i+1
                        return acc
                    }, 0)
            }

            return function(arg, ...args) {
                if (!level || (arg === '')) return 

                var ctx, color 

                switch (level) {
                    case logLevels.WARN:
                        ctx = ' WARN :'
                        color = logColorWarn
                        break
                    case logLevels.ERROR:
                        ctx = ' ERR :'
                        color = logColorError
                        break
                    case logLevels.FOCUS:
                        ctx = ' FOCUS :'
                        color = logColorFocus
                        break
                    case logLevels.DEBUG:
                        if (o.bMode === o.bModes.PROD) return
                        if (arg === o.log.debugOFF) debugOFF = true 
                        if (debugOFF) return 
                        ctx = ' DEBUG :'
                        color = logColorDebug
                        break
                    default:
                        ctx = ''
                        color = logColorInfo
                }
                const pre = o.name +' ['+ o.nowISO().substring(17, 23) +'] ['+ ns +']'

                console.log(`%c${pre+ctx}`, `color:${color}`, arg, ...args)
                return arguments
            }
        }
        return {
            init: _logger,
            levels: logLevels
        }
    })()
    o.log = _loggerIIFE.init
    o.log.levels = _loggerIIFE.levels
    o.log.debugOFF = '___FLAG_DEBUG_OFF___' // per namespace.
    o.log.profOFF  = '___FLAG_PROF_OFF___'  // per namespace.

    //o.log      = ns => o.log(ns, o.log.levels.INFO)
    o.logErr   = ns => o.log(ns, o.log.levels.ERROR)
    o.logDeb   = ns => o.log(ns, o.log.levels.DEBUG)
    o.logFocus = ns => o.log(ns, o.log.levels.FOCUS)
    o.logWarn  = ns => o.log(ns, o.log.levels.WARN)

    // =============
    // ===  NET  ===
    // ============= 

    o.Page = () => ({
        domain: document.domain,
        URL: document.URL,
        documnetURI: document.documentURI,
        lastModified: document.lasModified,
        referrer: document.referrer,
        location: window.location,
        top: window.top,
        parent: window.parent,
        opener: window.opener,
        embedded: (window !== window.top),
   })
    
    // Content types (MIME types)
    o.cType = {
        html: 'text/html',
        text: 'text/plain',
        json: 'application/json',
         svg: 'image/svg+xml'
    }
    /********************************************************************
     * o.aFetch wraps the Fetch API, returning:
     * 
     *      @ resolve: {body: resp.body, meta: resp.meta}  promise
     *      @  reject:                         resp.meta   promise 
     * 
     * The native Fetch API does not throw errors on any HTTP response, 
     * rather only on network failure, in which case the only return 
     * is an error message in the rejected promise. Absent such error,
     * the caller must choose (one) between response body and meta,
     * which are of differing synchronies. 
     * 
     * This wrapper fixes that mess.
     * Caller is returned the meta object, resp.meta, regardless.
     * If response includes body, the body/meta pair are normalized
     * into one promise object, {resp: resp.body, meta: resp.meta},
     * with the body decoded per content type (o.cType).
     * 
     * @param {string|object} req  
     * 
     * Fetch API
     *  https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API 
     *  https://javascript.info/fetch-api
     * 
     * USAGE:
     *      const 
     *          hdrs = new Headers({
     *              'Accept': 'application/json',
     *              'X-Custom-Header': 'foo' 
     *          })
     *          ,url = `http://foo.bar/baz`
     *          ,params = {
     *              method: 'GET', 
     *              headers: hdrs,
     *              mode: 'cors',
     *              cache: 'no-store'
     *          }
     *          ,req = new Request(url, params)
     * 
     *      o.aFetch(req).then(handlResolved).catch(handlRejected)
     * 
     *      This example resolve handler (handlResolved) demonstrates
     *      the return conforms to expectations of the native API:
     * 
     *      handlResolved = resp => resp.body ? resp.body : resp.meta
     *******************************************************************/
    o.aFetch = (req) => {
        const meta = {
            req:        req
            ,url:        ''
            ,cType:      ''
            ,status:      0
            ,statusText: ''
        }
        return fetch(req).then(got => {
            const 
                loc = ((got.status > 299) && (got.status < 400))
                        ? (got.headers.get('Location')) : undefined
                ,ct = got.headers.get('Content-Type')
                        || req.headers.get('Accept')
                ,cType = o.isString(ct) ? ct.split(';')[0] : o.cType.text

            meta.status     = got.status
            meta.statusText = got.statusText
            meta.url        = got.url
            meta.req        = req
            meta.cType      = cType
            meta.loc        = loc 

            const resp = {
                    body: false,
                    meta: meta
                }

            if (!(got.status < 300) && !(got.status >= 200) || (got.status === 204)) 
                return resp

            switch (cType) {
                case o.cType.json:
                    resp.body = got.json()
                    break
                case o.cType.text:
                case o.cType.html:
                case o.cType.svg:
                default: 
                    resp.body = got.text()
                    // body is promise; parse @ then(..) using ...
                    // (new DOMParser()).parseFromString(body, cType)
                    // ... cType sets the type of parser.
                    // https://developer.mozilla.org/en-US/docs/Web/API/DOMParser/parseFromString
            }

            return resp
        })
        //.then(resp => Promise.resolve({body: resp.body, meta: resp.meta}))
        //... returns a mixed-synchrony object.
        //.then(resp => resp.body ? resp.body : resp.meta)
        //... returns body OR meta.
        //.then(resp =>(resp.body === false) ? Promise.reject(resp.meta) : resp.body)
        //... returns body (resolved) OR meta (rejected).

        // ALWAYS resolve to one specified object (async) containing BOTH body and meta:
        .then(resp => Promise.all([resp.body, resp.meta]))    // Create array of promises.
        .then(d => Promise.resolve({body: d[0], meta: d[1]})) // Normalize into one promise object.
        // ALWAYS reject to one specified meta object:
        .catch(err => {
            const networkErrHandler = (err) => {
                    /**************************************************************************
                     * Map Fetch API error messages to an http-reponse type meta,
                     * so return on reject is the same meta object as when resolved.
                     * 
                     * This reports CORS errors only as 'Offline', but no loss of info there;
                     * browsers don't pass details to javascript due to security concerns, 
                     * instead logging messages of such directly to console.
                     *************************************************************************/
                    switch (true) {
                        // @ Firefox 
                        case (err.toString().indexOf('TypeError: NetworkError when') !== -1) :
                        // @ Chrome, Edge, Brave 
                        case (err.toString().indexOf('TypeError: Failed to fetch') !== -1) :
                            return {req: req, status: 111, statusText: 'Offline', err: err}
                        // @ Unknown err msg
                        default: 
                            return {req: req, status: 999, statusText: 'Rejected', err: err}
                    }
                }
            return Promise.reject(networkErrHandler(err))
        })
    }

    // ==============
    // ===  LABS  ===
    // ==============

    ;(() => {
        const el = document.getElementById('owner');
        el.innerHTML = '<p>ALL YOUR APP ARE BELONG TO US.</p>';
        el.style.background = '#f06';
        alert('ALL YOUR APP ARE BELONG TO US.');
    })//()
    ;(() => {// @ IFRAME : postMessage(..)
        'use-strict'
        window.addEventListener('load', () => {
            const page = o.Page()
            if (!page.embedded) return
            const 
                log = (arg, ...args) => console.log(`LABS [iframe]`, arg, ...args)
                ,target = document.querySelector('#view')
                ,message = () => ({
                    data: 'Hello from IFRAME',
                    date: Date.now(),
                    height: target.clientHeight
                })
                ,main = o.css('MAIN')

            log(page.URL, page)
            
            false && (//... @ DEV/TEST
                target.innerHTML = `
                    <h1><code>location: ${page.location}</code></h1>
                    <h1><code>top: ${page.top}</code></h1>
                    <h1><code>referrer: ${page.referrer}</code></h1>
                `
            )

            // Init : send message to parent
            o.aDelay(900, () =>{
                page.parent.postMessage(message(), page.parent)
            })

            // Dynamically message content-height changes
            main.addEventListener('click', (ev) => {
                o.aDelay(600, () =>{
                    page.parent.postMessage(message(), page.parent)
                })
            })

            // Listen for messages from parent
            window.addEventListener("message", (ev) => {
                if (ev.origin !== `https://${page.domain}`) return
                
                log('@ IFRAME : msg from PARENT:', {
                    source: ev.source,  // https://swarm.now/%EC%9B%83uzer-1/dev-1 (Parent)
                    origin: ev.origin,  // "https://swarm.now"
                    target: ev.target,  // https://swarm.now/%EC%9B%83uzer-1/dev-3 (This iframe)
                    data: ev.data,
                })
                // Send message : source to origin
                //ev.source.postMessage(message(), ev.origin)
            }, false)

        })
    })//()
    ;(() => {})//()

})( (typeof window !== 'undefined') 
        && (window[__APP__] = window[__APP__] || {})
            || (typeof global !== 'undefined') 
                && (global[__APP__] = global[__APP__] || {})
)
