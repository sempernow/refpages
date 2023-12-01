
// View : msgList
;(function (o, undefined) {
    'use-strict'
    // @ init
    const 
        cName = 'msg_list'
        ,cSelector = `#msg-list`
        ,cNode = o.css(cSelector)

    if (!cNode) return 
    
    const 
        auth = o.Auth()
        ,view = o.View()
        ,eb = o.EB()
        ,eTypes = eb.eTypes()
        ,keys = view.components
        ,log = view.log(cName)
        ,logDeb = view.logDeb(cName)
        ,logErr = view.logErr(cName)
        ,logFocus = view.logFocus(cName)
        ,prof = o.profile('View/msgList')
        ,debugOFF = o.log.debugOFF  // ''
        ,profOFF = o.log.profOFF    // ''
        ,inIframe = (window !== window.top)

    true && (prof.start(profOFF), logDeb(debugOFF))

    // @ init per page load
    keys[cName] = (() => { 
        if (!view.validate.node(cNode, cSelector)) return function() {} 
        /**********************************************************************
         * Messages are rendered in declarative time by one of two renderers, 
         * per thread or ad hoc, per state; dispatched per dType, full|diff. 
         * Multiple instances of both renderers, one per state, may run 
         * 'concurrently' (multiplexed), issuing requests for older 
         * messages per scroll events, per event-bus messaging. 
         *
         * Upon initial state, this function makes one request for newer 
         * messages, which triggers the Net module to schedule recurring 
         * requests for such, all of which are handled by ad-hoc renderer.
         * 
         * Caller is responsible for assuring uniqueness of messages.
         *********************************************************************/
        const  
            ss = o.State().store
            ,centre = o.css('#centre') //... top lists (popular, trending, newest)
            ,msgListMenu = o.css('#msg-list-menu')
            ,msgListMenuEls = o.cssAll('#msg-list-menu li') 
            ,msglistNode = o.css('#msg-list')
            ,articleNode = o.id('article')
            /***********************************
             * Render root msg @ thread view
            ***********************************/
            ,articleNodeAttr = (article) => {
                if (!articleNode) return false
                articleNode.dataset.articleId = article.id
                articleNode.dataset.authorId = article.author_id
                articleNode.classList.add('msg')
                return true
            }
            ,renderArticle = o.once((article) => articleNodeAttr(article) && o.toDOM(articleNode, `
                    <div class="msg">
                            <!-- 
                            <a href="/${article.path}#m-${article.id}">
                            -->
                                <h2 class="title">
                                    <div>
                                        ${article.title ? article.title : 'Thread Root'}
                                    </div>
                                    <div class="date" data-utc-time="${article.date}">
                                        <span>${o.ageNow(article.date)}</span>
                                    </div>
                                </h2>
                            <!-- 
                            </a>
                            -->
                        <div class="body">
                            ${article.body ? article.body : ''}
                            <div class="body-footer">
                                ${article.uri_other
                                ? '<a href="'+ss.channel.host_url+article.uri_other
                                    +'">Read @ '+ss.channel.host_url.split("/")[2]+'</a>' 
                                : ''
                                }
                            </div>
                        </div>
                        <div class="meta">
                            <div class="keywords"></div>
                        </div>
                    </div>
                `)
            )
            ,msgZero = {article: undefined}
            ,svgsPath = o.cfg.view.svgsPath
            ,avatars = o.cfg.view.avatars
            ,unitHeight = view.unitHeight
            ,h0 = unitHeight * 15 // ~ 2265
            ,t0 = o.nowMsec()
            // Multiplex rendering states/processes
            ,dormant = 1
            ,mutating = 0
            ,mutex = {messages: {full: dormant, diff: dormant}}  
            // List of thread object(s) whereof root node is a reply message 
            // awaiting a recipient that does not exist in the log at this state.
            ,awaitingRecipient = [] //... recipients are older than oldest fetched at current state.
            // Accumulated totals (across all states)
            ,dataAcc = {threads: 0, messages: 0, newest: 0, oldest: Infinity}
            // Collect IDs of async-scheduled renderings to allow for cancelling
            ,asyncIDs = [] 
            ,updateMsgsAge = () => {
                /************************************************************
                 * Age (text) of all messages is updated periodically
                 * per scheduler, onSchUpdateMsgsAge(), 
                 * launched once on first render. 
                 * Thereafter, updateMsgsAge() re-reads the (mutating) DOM 
                 * and updates the age text on each, per scheduled call.
                ***********************************************************/
                const messages = o.cssAll('#msg-list div.msg') || ''
                ;[...messages].map(msg => {
                    const
                        dateEl = o.css('div.date', msg)  
                        ,ageEl = o.css('div.date>span', msg) 

                    ;(dateEl && ageEl)
                        && o.setText(ageEl, o.ageNow(dateEl.dataset.utcTime))
                })
                !debugOFF && logDeb('Update Age of all :', messages.length,'@', o.nowUTC())
            }
            ,onSchUpdateMsgsAge = o.once(() => {
                logDeb("@ onSchUpdateMsgsAge() : LAUNCH")
                const waitSeq = [1,2,5].map(t => 60000*t)
                o.aScheduleSeq(o.seqArr(waitSeq, 0), updateMsgsAge)
            })
            // Set counts @ msgList menu. If rendering flat list (chron), then disable Threads count.
            ,menuTallys = (m, t, isChron) => {
                if (!(msgListMenuEls && msgListMenuEls.length)) return
                m && (msgListMenuEls[0].dataset.count = m)
                t && (msgListMenuEls[1].dataset.count = t)
                isChron && (msgListMenuEls[1].dataset.count = 'n/a')
            }
            // Read the (mutating) DOM
            ,tallyDOM = () => { 
                const 
                    tally = {//... counts of all rendered ...
                        messages: o.cssAll('#msg-list div.msg').length     // ALL messages
                        ,threads: o.cssAll('#msg-list>div.thread').length  // All primary threads
                    }
                //menuTallys(tally.messages, tally.threads)
                return tally 
            }

            // Dynamic scroll trigger for lazy fetch/render; account for dynamic DOM @ "infinite scroll".
            ,trigger = (ymax) => {
                const h = Math.round(msglistNode.scrollHeight) // dynamic; ~ 2650 @ 13 threads
                // Don't be too lazy too early lest view starved of content.
                return !!(Math.round(0.90*h*(1 - h0/h) - 3*unitHeight - ymax) < 0) 
            }

            /*************************************************************************
             * toggler : Expand/Collapse
             * - Expanded state has Collapse-titled button/graphic (#def-collapse).
             * - Collapsed state has Expand-titled button/graphic  (#def-expand).
             ***********************************************************************/
            ,toggleState = {expanded: 'collapse', collapsed: 'expand'}
            ,toggleInit = view.cfgMsgs.collapseAll ? toggleState.collapsed : toggleState.expanded
            ,togglerSet = (state, ra) => {
                const 
                    title = (state === toggleState.collapsed) ? 'Expand' : 'Collapse'
                    ,ct = {siblings: 0, total: 0, html: ''}
                
                if (ra) { // Replies-array arg (ra) required to set msg counts (siblings/total).
                    const total = (ra) => ra && ra[0] && ra.reduce((acc, el) => {
                            (el.replies) 
                                ? (acc += total(el.replies)) 
                                : (acc += 0) 
                            return acc
                        }, ra.length)

                    ct.siblings = ra ? ra.length : 0
                    ct.total    = ra ? total(ra) : 0
                    ;(ct.total) && (ct.html = `${ct.siblings}/${ct.total}`)
                }
                return `
                    <span class="count-replies">${ct.html}</span>
                    <div class=title data-title="${title}">
                        <svg>
                            <use href="${svgsPath}#def-${state}"></use>
                        </svg>
                    </div>`
            }

            ,toNest = (acc, msg, i) => {
                /***********************************************************
                 * This is the reduce function that tranforms the msg list 
                 * from flat to recursively nested message-reply threads.
                ***********************************************************/
                if ('to_id' in msg) {//... message is a reply.
                    // If reply has no recipient (at this state) then relegate it to the awaiting list.
                    const i_to_id = acc.findIndex(k => (k.id === msg.to_id)) 
                    if (i_to_id < 0) {//... recipient message does not exist (at this state).
                        msg.awaitingRecipient = 1   //... flag as unrenderable (at this state).
                        awaitingRecipient.push(msg) //... relegate for future-state rendering.
                        return acc
                    }
                    // Create recipient's replies list (array) if not exist; nestable component of a thread. 
                    acc[i_to_id].replies ? acc[i_to_id].replies : acc[i_to_id].replies = []
                    // Push this renderable reply message to its recipient's replies array.
                    acc[i_to_id].replies.push(msg) 
                    msg.redundant = 1 //... flag to discard the reply now absorbed by recipient thread.
                }
                return acc
            }

        // @ render per state key
        return (data) => {
            if (!view.validate.key(data, cName)
                || (!(data.msg_list && data.msg_list.list))
            ) return false 
            // Continue even if no messages 

            const 
                state = o.State()
                // MsgList params 
                ,msgs = data.msg_list
                ,cacheTotal = data.msg_list.count || 0
                ,flat = 1   // Message format (received).
                ,nest = 2   // Message format (received).

                // Resource params (URI); to publish requests for older or newer messages
                ,chnID = data.channel.chn_id
                ,ownerID = data.owner.user_id
                ,lType = data.msg_list.type 
                ,lTypeURI = o.lTypeName(lType)
                ,xid = (lType === o.lTypes.chn) 
                            ? chnID 
                            : ( (lType === o.lTypes.th) 
                                    ? ((msgZero.article && msgZero.article.id) || msgs.list[0].id) 
                                    : ownerID
                            )
                ,uriArr = (oldest) => (lType > o.lTypes.th) 
                                        ? ['ml', 'top', o.lTypeName(lType), oldest]
                                        : ['ml', o.lTypeName(lType), xid, oldest] 

                /*****************************************************************************
                 * @ Single-thread view, the 0th message (of 1st payload) is the article;
                 * all others are replies thereto or of subthreads thereunder.
                 * Only its gutted shell (enlarged action buttons) is rendered in that list.
                 * So rendering the article's shell preserves all list-event dynamics.
                 * The complete article (thread root) is rendered outside (above) the list.
                 ****************************************************************************/
                ,singleThread = (lType === o.lTypes.th) ? true : false
                //,article = singleThread ? (msgZero.article ? msgZero.article : msgs.list[0]) : {}
                ,article = (msg) => (singleThread ? (msgZero.article ? msgZero.article : msg) : {})
                
                // Get status; allow for interlacing of renderer(s) instances across states:
                ,mutexFull = () => mutex.messages.full  // `perThread()`
                ,mutexDiff = () => mutex.messages.diff  // `perMessage()`
                ,chron = msgListMenu ? {
                    /*****************************************************************************
                     * Both chron-active views (Newest/Oldest) are flat lists (versus threads)
                     * rendered with no distinction between new/reply messages.
                     * The perMessage() renderer handles all chron-active views 
                     * regardless of mode (replay or not).
                     * 
                     * The chron object tracks both the active state of msgListMenu (node)
                     * and whether the current state rendering is of the replay requesting it.
                     * 
                     * The perThread() renderer abides replay requests, 
                     * but not chron requests; it always prepends newer threads.
                     **************************************************************************/
                    // True IIF this state is a (replay) request for chron-ordered flat list Newest|Oldest
                    wanted: (data.msgListMenu && data.msgListMenu.want)
                                ? ((data.msgListMenu.want !== 'Threads')
                                    ? !!(data.msgListMenu.want)
                                    : false
                                )
                                : false 
                    // msgListMenu (node) state (dataset value)
                    ,state: (  (msgListMenu.dataset.state == 'Oldest') 
                            || (msgListMenu.dataset.state == 'Newest') 
                            )   ? msgListMenu.dataset.state 
                                : ''
                } : {wanted: false, state: false}
                // Flag the replays 
                ,replayFlag = (data.mode === 0)

                ,replay = (data) => {
                    /********************************************************************
                     * replay(..) handles initialization on replay mode:
                     * 
                     *  - Cancels all (async) renderers.
                     *  - Purges the DOM node. 
                     *  - Resets all cross-states counters.
                     * 
                     * Replay mode is that of any state created per msgListMenu event;
                     * any user request for a different view of the same list;
                     * Newer, Older, Threads.
                     * 
                     * From the perspective of the View module, 
                     * replay is identical to initial-state rendering.
                     **************************************************/ 
                    // @ asynch schedulers (cancellable)
                    asyncIDs.map(id => clearTimeout(id))
                    o.aSchedulerP.abort()
                    // @ DOM 
                    o.purge(msglistNode)
                    // @ Accum (cross-states) counters
                    awaitingRecipient.length = 0
                    dataAcc.threads = 0
                    dataAcc.messages = 0 
                    dataAcc.oldest = Infinity

                    // Set the renderer
                    ;(data && data.msgListMenu && data.msgListMenu.want)
                        && (data.msgListMenu.want === 'Threads')
                            ? data.dType = o.dTypes.full
                            : data.dType = o.dTypes.diff // @ Chron (Newer|Older)
                }
                /*********************************************************************************** 
                 * abort() signals renderers of all other states to abort on replay mode.
                 * The signal is used to set their renderable-objects array to zero length.   
                 * An older-state perMessage renderer may continue, depending upon scroll events,
                 * by absorbing the new awaiting list. Either scenario functions well.
                 **********************************************************************************/
                ,abort = () => (
                        (state.logs[state.logs.length-1].mode === o.aModes.replay) 
                     && ((state.logs.length-1) !== data.cursor)
                )
                // redirect(..) is used to pop out of IFRAME 
                ,redirect = (path) => (window.top.location.href = path)

                ,blank = inIframe ? ` target="_blank"` : ''
                /***********************************************************************
                 * thread() recursively populates a message(s)-(sub)thread(s) template.
                 * Called by both msg-list renderers. 
                 *************************************/
                ,thread = (j) => { 
                    /**********************************************************************
                     *  Dataset (Web API) Attributes/Values:  
                     *  
                     *  data-thread-replies="true"   
                     *  - Utilized by JS toggleAll() to expand/collapse all.
                     *
                     *  data-thread-collapsed="true" 
                     *  - Utilized by JS toggleReplies(), per toggle.
                     * 
                     *  data-self-collapsed="true"   
                     *  - Utilized by JS toggleThread() 
                     *    and by CSS @ `.thread.reply[data-self-collapsed=true]` 
                     *    to hide; `display: none;`.
                     * 
                     *  data-title="<ACTION>" 
                     *  - Utilized by JS toggleThread(), 
                     *    and by CSS @ `.options .title::after` .
                     * 
                     *  data-msg-ref="${j.id}"
                     *  - Utilized by JS getThread(), renderReply() .
                     * 
                     *  data-utc-time="${j.date}"
                     *  - Utilized by JS to periodically update message age (text).
                     * 
                     *  data-author-id="${j.author_id}"
                     *  - Utilized by JS getTxn(..).
                     * 
                     * data-author-display="${j.author_display}"
                     * data-author-handle="${j.author_handle}"
                     *  - Utilized by JS doMsg(..)
                     **********************************************************************/
                    const
                        data_collapsed = `
                            data-thread-collapsed="${(j.replies) ? 'true' : ''}"
                            data-self-collapsed="${(j.to_id) ? 'true' : ''}"
                            `
                        ,data_expanded = `
                            data-thread-collapsed=""
                            data-self-collapsed=""
                            `
                        ,comment = (id) => `<!-- id="m-${id}" has replies (recurse). -->`
                        ,toggle = (state) => {
                            if (state === toggleState.collapsed) 
                                return [data_collapsed, togglerSet(toggleInit, j.replies)]
                            if (state === toggleState.expanded) 
                                return [data_expanded,  togglerSet(toggleInit)] 
                            return ['FAIL@toggle(state)[0]', 'FAIL@toggle(state)[1]']
                        }
                        ,recent = (j.date > t0) ? ' new' : ''
                        // Set class @ this thread node if j is article (0th message) @ single-thread view.
                        ,singleThMode = j => (
                            (singleThread) && (msgZero.article && (msgZero.article.id === j.id))
                        ) ? ' single-thread' : ''

                        /********************************************************************
                         * Actions : buttons displayed per group : yea, non, pub, toggle
                         *******************************************************************/
                        // Actions : qToken | pToken 
                        ,yea = j => `
                            <div class="yea">
                                <div class="title" data-title="qToken">
                                    <svg>
                                        <use href="${svgsPath}#def-token-q"></use>
                                    </svg>
                                    <span>${j.tokens_q ? j.tokens_q : ''}</span>
                                </div>
                                <div 
                                    class="title${
                                        (  (j.tokens_q < view.minMsgQ4P) && (j.tokens_p === 0)
                                            && !(msgZero.article && (msgZero.article.id === j.id))
                                        ) 
                                            ? ' hide' 
                                            : ''
                                    }" 
                                    data-title="pToken">
                                    <svg>
                                        <use href="${svgsPath}#def-token-p"></use>
                                    </svg>
                                    <span>${j.tokens_p ? j.tokens_p : ''}</span>
                                </div>
                            </div>
                            `
                        // Actions : Punish
                        ,non = j => `
                            <div class="non">
                                ${(j.to_id) ? `
                                <div class="title" data-title="Punish">
                                    <svg>
                                        <use href="${svgsPath}#def-punish"></use>
                                    </svg>
                                    <span></span>
                                </div>`
                                : ''}
                            </div>
                            `
                        // Actions : Reply | Repost
                        ,pub = j => !centre 
                            ? `
                            <div class="pub">
                                <div class="title" data-title="Reply">
                                    <svg class="reply">
                                        <use href="${svgsPath}#def-reply-open"></use>
                                    </svg>
                                </div>
                                <!-- Not yet implemented -->
                                <div class="title hide" data-title="Repost">
                                    <svg>
                                        <use href="${svgsPath}#def-repost"></use>
                                    </svg>
                                </div>
                            </div>
                            ` 
                            : `
                            <div class="pub">
                            </div>
                            `
                        /*******************************************************************
                         * Upon 'Punish' action resulting in negative q, 
                         * content of yea(j) is replaced with that of punish(j).
                         * Thereafter some buttons are hidden and no actions are allowed.
                         ******************************************************************/
                        ,punished = j => `
                            <div class="yea">
                                ${(j.to_id) ? `
                                <div class="title" data-title="Punish">
                                    <svg>
                                        <use href="${svgsPath}#def-punish"></use>
                                    </svg>
                                    <span></span>
                                </div>`
                                : ''}
                                <div class="title" data-title="qToken">
                                    <svg>
                                        <use href="${svgsPath}#def-token-q"></use>
                                    </svg>
                                    <span>${j.tokens_q ? j.tokens_q : ''}</span>
                                </div>
                                <div 
                                    class="title${((j.tokens_q < view.minMsgQ4P) && (j.tokens_p === 0)) ? ' hide' : ''}" 
                                    data-title="pToken">
                                    <svg>
                                        <use href="${svgsPath}#def-token-p"></use>
                                    </svg>
                                    <span>${j.tokens_p ? j.tokens_p : ''}</span>
                                </div>
                            </div>
                            `
                    // Avatar alternatives
                    // <!-- 
                    // <img src="${view.avatarMBFRand()}" alt="">
                    // <img src="${view.avatarMBF(j.author_display)}" alt="">
                    // <img src="${view.avatarMBFRand()}" alt="">
                    // <img src="${view.avatarMBF(j.author_display)}" alt="">
                    // <img src="${avatars}/${j.author_avatar}" alt=""> 
                    // -->

                    return `\n
                    <!-- Thread 
                         @ m-${j.id} 
                         @ c-${j.chn_id} 
                    -->
                    <div 
                        id="m-${j.id}" 
                        class="thread${j.to_id ? ' reply' : ''}${replayFlag ? '' : recent}${singleThMode(j)}" 
                        data-chn-id="${j.chn_id}"
                        data-thread-replies="${j.replies ? 'true' : ''}"
                        data-author-id="a-${j.author_id}" 
                        data-author-display="${j.author_display}" 
                        data-author-handle="${j.author_handle}" 
                        ${toggle(toggleInit)[0]}
                    >
                        <div ${(msgZero.article && (msgZero.article.id === j.id)) ? 'id="msg-zero"' : ''}
                            class="msg"
                            data-punished="${(j.tokens_q < 0) ? 'true' : ''}">
                            <div class="graphics">
                                <div>
                                    <img src="${j.author_avatar 
                                                    ? view.avatar(j.author_avatar) 
                                                    : view.avatarMBF(j.author_handle)}" alt="">
                                    <div class=badges>${
                                        j.author_badges 
                                            /* Whitespace required by Chrome, else no wrap. */
                                            ? o.makeBadgeNodes(j.author_badges).join(' ') 
                                            : ''
                                    }</div>
                                </div>
                            </div>
                            <div class="main">
                                
                                    ${j.title ? '<a class="msg-title" href="/m/thread/'+j.id+'"'+blank+'><h2>'+j.title+' <span>&nbsp;&#x25b6</span></h2></a>' : ''}
                               
                                <h3>
                                    <div class="author">
                                        ${(j.uri_local && (j.uri_local !== window.location.pathname)) 
                                            ? '<a href="'+j.uri_local+'#m-'+j.id+'"'+blank+'>'+j.author_display+' <span>/'+j.author_handle+'</a>' 
                                            : '<a href="/'+j.author_handle+'/pub'+'#m-'+j.id+'"'+blank+'>'+j.author_display+' <span>/'+j.author_handle+'</a>' 
                                        }
                                        ${j.to_id ? '<div><a href="/'+j.to_handle+'/pub#m-'+j.to_id+'"'+blank+'>Reply to /'+j.to_handle+'</a></div>' : ''}
                                    </div>
                                    <div>
                                        ${(j.to_id || j.title) ? '' : '<a href="/m/thread/'+j.id+'" class="button"'+blank+'>&nbsp;&#x25b6</a>'}
                                    </div>
                                    <div class="date" data-utc-time="${j.date}">
                                        <span>${o.ageNow(j.date)}</span>
                                    </div>
                                </h3>
                                <div class="body">
                                    <p>
                                        ${(j.form === o.mForm.short) 
                                            ? j.body 
                                            : (j.summary ? j.summary : '')
                                        } 
                                        <!-- | m-${j.id.substring(0,7)} -->
                                    </p>
                                    <p class="sponsor ${(j.sponsub) ? '' : 'hide'}">
                                        ${j.sponsub}<span>P</span>
                                    </p>
                                </div>
                                <div class="options">

                                    <div class="actions">
                                        ${(j.tokens_q < 0) ? punished(j) : yea(j) + pub(j) + non(j)}
                                    </div>

                                    <div class="toggle" data-msg-ref="m-${j.id}">
                                        ${j.replies ? toggle(toggleInit)[1] : ''}
                                    </div>

                                </div>
                            </div>
                        </div>
                        
                        ${j.replies ? comment(j.id): ''}
                        ${j.replies ? j.replies.map(thread).join('') : ''}
                    </div>
                    <!-- END Thread @ m-${j.id.substring(0,7)} -->\n`
                }

            function perThread() {
                /****************************************************************************
                 * perThread() renderer for messages and their recursively nested replies. 
                 * Chronologically ordered, all messages render eventually,
                 * per scroll, which dynamically triggers request(s) for older; 
                 * older than oldest message of all multiplexed renderers' states.
                 * 
                 * This renderer must never process any message newer 
                 * than the newest of initial state; state.logs[0].
                 * 
                 * Multiple states of this renderer may run multiplexed,
                 * sharing the common awaiting-recipient list,
                 * which is also shared with any similarly running perMessage() renderers.
                 **************************************************************************/ 
                mutex.messages.full = mutating // lock

                // Push the unrendered awaiting-reply message(s) from prior state onto current list ...
                o.arrsConcat(msgs.list, awaitingRecipient) 
                awaitingRecipient.length = 0 //... and reckon that.

                if (msgs.list.length === 0) {
                    logDeb('@ perThread() : NO MESSAGES in this state.')
                    mutex.messages.full = dormant 
                    return 
                }
                const 
                    thList = [] // Threads list; HTML-string elements.
                    ,oldest = msgs.list[0].date 

                var mList = [] // Messages list (of objects) mutates from flat to nest (threads).
                // Reformat messages list from flat (msgs) to nest (mList):
                switch (msgs.format) {//... received.
                    case flat: // If flat, transform to nested; to thread(s) list.
                        /************************************************************************
                         * Recursively embed replies into recipients.
                         * Filter out the residue; replies absorbed into their recipient, 
                         * and replies having no recipient at this state (saved future states).
                         ***********************************************************************/
                        mList = msgs.list.reduce(toNest, msgs.list).filter(msg => ( 
                                    (msg.redundant !== 1) && (msg.awaitingRecipient !== 1) 
                                ))

                        if ((lType === o.lTypes.pub) || (lType === o.lTypes.sub)) {
                            /****************************************************************************
                             * @ /pub or /sub, all reply messages to other channels from the owner 
                             * were relegated to awaiting list (@ toNest), some of which would forever 
                             * await their other-channel recipient. So, those are added back to list 
                             * of renderables to be rendered here as new, each at its own thread. 
                             * This is reckoned by removing them from the awaiting list hereby.
                             * 
                             * Some replies thereto (absent here) would forever await at this renderer, 
                             * at this state, so are made transferable to the per-message (ad-hoc) 
                             * renderer by being on the awaiting list; a list shared by both renderers, 
                             * and across states. (Multiple states may be renderering, multiplexed.)
                             * 
                             * All non-chn type lists (pub, sub, th, centre) have similar edge-case 
                             * issues, each with differing particulars.
                             **************************************************************************/
                            awaitingRecipient.forEach((msg, i) => (
                                (msg.chn_id !== chnID) && (msg.author_id === ownerID)) && (
                                    mList.push(msg)
                                    ,awaitingRecipient.splice(i, 1)
                            ))
                        }

                        // if (lType === o.lTypes.th) {
                        //     /*************************************************
                        //      * @ /thread, all are renderable at this state;
                        //      * the oldest message is the root (0th) message.
                        //      * UPDATE : No. Something is wrong here.
                        //      ************************************************/
                        //     awaitingRecipient.forEach((msg, i) => ( 
                        //         mList.push(msg)
                        //         ,awaitingRecipient.splice(i, 1)
                        //     ))
                        // }

                        //logFocus(msgs.list)
                        
                        // Re-sort threads chronologically, in place.
                        mList.sort((a, b) => (a.date - b.date))

                        /************************************************************
                         * Set and render the article content once per page load,
                         * else 0th message of subsequent fetches appear as article
                         ***********************************************************/
                        if (lType === o.lTypes.th) {
                            const 
                                article = (mList[0] && singleThread) 
                                                ? (msgZero.article ? msgZero.article : mList[0]) 
                                                : {}
                            // Set once per page load
                            ;(article.id && !msgZero.article) && (
                                (article.path = state.key)
                                ,(msgZero.article = article)
                                ,renderArticle(article)
                            )
                            //logFocus({now: article, ini: msgZero.article})
                        }

                        // Build thread(s) markup; an array of template literals, each a thread.
                        o.arrsConcat(thList, mList.map(thread))

                        // Accumulate threads count across states
                        dataAcc.threads += thList.length + awaitingRecipient.length 

                        break 

                    case nest: //... if arrived already as such.
                        // ***************************************************
                        //  DEPRICATED case; not maintained [2020-09]
                        // ***************************************************
                        mList = msgs.list.filter(msg => !('to_id' in msg))
                        //... assure no nested-reply-message residue.
                        o.arrsConcat(thList, mList.map(thread)) 
                        break

                    default:
                        logErr('@ state #', data.cursor, ': perThread() : msgs.format :'
                            + `${msgs.format} (INVALID)`
                        )
                } 

                // Purge this consumed component from state logs (at this state).
                // Timing issue @ very large threads; thList hasn't time to absorb it?
                // Delay causes redundancies in thList
                //o.aDelay(1000, () => {
                    msgs.list = []
                    //;(debugOFF) ? gc(data.msg_list, 'count', 'etag') : (msgs.list = [])
                //})

                // If none renderable at this state.
                if (thList.length === 0) { 
                    if (awaitingRecipient.length !== 0) {
                        // Launch ad-hoc renderer, to which awaitingRecipient list is transfered
                        perMessage()

                        logDeb('@ perThread() : NO RENDERABLE threads. |'
                            ,awaitingRecipient.length, 'AWAITING recipients.'
                        )
                    }
                    mutex.messages.full = dormant 
                    return 
                }

                mutex.messages.full = dormant 

                // Dispense threads per scheduler, per scroll event.
                ;(() => {
                    const 
                        saveCountThreads = thList.length
                        ,maxThreads = 12   //... per scroll event or on first render.
                        ,waitThread = 220  // Threads are dispensed per indexed delay (wait * i).
                        ,timeScroll = 100  // scroll-event throttle time.
                        ,y = {acc: 0, max: 0, last: 0, trigger: unitHeight}

                        ,dispenseThreads = (yacc) => {
                            // Adaptive-trigger reckons the mutating content height.
                            if (dataAcc.messages && !trigger(y.max)) return
                            if (yacc) {
                                // Set the number of threads to render 
                                // by the distance scrolled; upper bounded.
                                var n = Math.round(yacc/unitHeight + 1) || maxThreads
                                ;(n > maxThreads) && (n = maxThreads)
                                const afew = (thList.length > n) ? n : thList.length
                            } else { // @ init call
                                //afew = maxThreads
                                afew = (thList.length < maxThreads) ? thList.length : maxThreads
                                n = afew
                            } 
                            
                            // Render a few thread(s) per indexed delay(s).
                            for (let i = 0; i < afew; i++) {
                                /*******************************************************************
                                 * The declarative-time scheduler limits the rate of DOM mutations 
                                 * regardless of the rate at which events trigger them. 
                                 * Renderings so scheduled are cancellable, which is exploited
                                 * by future (multiplexed) states rendering per replay request.
                                 **************************************************************/
                                asyncIDs.push(o.aDelay((waitThread * i), () => {
                                    mutex.messages.full = mutating
                                    prof.start('toDOM')

                                    /************************************************************
                                     * Render (consume) a thread, appending it to last sibling;
                                     * a primary thread already in the DOM; LIFO (newest first).
                                     ***********************************************************/
                                    o.toDOM(msglistNode, thList.pop()) 
                                    prof.stop() // ~ 3 ms; want < 16 ms 
                                    mutex.messages.full = dormant
                                }))
                            }
                            // Report status
                            !debugOFF && logDeb('#', data.cursor, '@ dispenseThreads(', n, ') :' 
                                ,thList.length, '/', saveCountThreads,'(remain/total) threads. |'
                                ,awaitingRecipient.length,'AWAITING recipients.'
                            )
                            !debugOFF && o.aDelay(1000, ()=> logDeb('#', data.cursor
                                ,': DOM @ perThread() :', tallyDOM() 
                            ))
                        }
                        // Scroll handler
                        ,onScroll = o.throttle(timeScroll, () => {
                            (abort()) && (thList.length = 0)

                            if (window.scrollY < y.max) 
                                return 

                            if (thList.length !== 0) {
                            // Record max and accumulate scroll changes
                                y.max = window.scrollY
                                y.acc += y.max - y.last 
                                ;(y.acc > y.trigger) && ( 
                                    dispenseThreads(y.acc)
                                    ,(y.acc = 0) //... reset regardless
                                )
                                // Recalibrate to current scroll position, and dismiss upward scrolls.
                                y.last = y.max;(y.acc < 0) && (y.acc = 0) 

                            } else {// After rendering all RENDERABLE threads ...
                                window.removeEventListener('scroll', onScroll) 
                                //... detach this listener

                                // Report this state's render status:
                                !(awaitingRecipient.length)
                                    ? log('#', data.cursor,': perThread() : RENDERED ALL', 
                                        saveCountThreads, 'threads of state','#', data.cursor
                                    )
                                    : log('#', data.cursor,': perThread() : RENDERED'
                                        ,saveCountThreads, 'of', dataAcc.threads,'threads. |'
                                        , awaitingRecipient.length, 'AWAITING recipients.'
                                    )
                                // If oldest at this state is oldest across all states,
                                // then request more (older messages).
                                
                                ;(dataAcc.oldest >= oldest)
                                    && eb.pub(eTypes.View, {
                                        node: msglistNode
                                        ,dType: o.dTypes.full
                                        //,dType: o.dTypes.scroll
                                        ,want: ['older']
                                        //,uri: ['ml', lTypeURI, xid, oldest, 111]
                                        ,uri: uriArr(oldest)
                                    }) // uri: {pg, ml}, {pub, sub, chn}, xid, [, t [, n]]

                                // Request reset of toggler/listener (messages node), regardless.
                                eb.pub(eTypes.View, {
                                    node: msglistNode
                                    ,dType: o.dTypes.full
                                    ,want: ['reset']
                                })

                                // Conditionally launch the ad-hoc (per-message) renderer, 
                                // to which this list of awaiting messages is transferred.
                                awaitingRecipient.length && perMessage() 
                            } 
                        })

                    dataAcc.oldest = (oldest > dataAcc.oldest) ? dataAcc.oldest : oldest

                    dispenseThreads() // init 

                    menuTallys(cacheTotal, dataAcc.threads, chron.wanted)

                    window.addEventListener('scroll', onScroll) //... dispense a few threads.
                })()
                //return toDOM(msglistNode, list) //... simpler; why not use? It badly blocks DOM. 
                // ...to use, change to `list.join('')` here or above @ `all()` func.
            }

            function perMessage() { 
                /*******************************************************************
                 * perMessage() is the ad-hoc renderer. 
                 * It handles both newer and older messages;
                 * age relative to initial state (state.logs[0]). 
                 * Several of these ad-hoc renderers may run concurrently 
                 * (multiplexed) across states. 
                 * 
                 * This handles, e.g., the reply message awaiting the
                 * arrival and render of its recipient message, which may exist
                 * at another state, rendering per its own scroll-event listener.
                 *****************************************************************/
                if (msgs.format !== flat) {
                    logErr('@ state #', data.cursor, ': perMessage() : msgs.format :'
                        + `${msgs.format} (MISMATCHED)`
                    )
                    return false
                }

                mutex.messages.diff = mutating  // lock

                const 
                    mList = msgs.list   // Instead of mutating the iterable mList, ...
                    ,rendered = []      // ... filter out elements as rendered, per id.
                    ,oldest = msgs.list[0] && msgs.list[0].date || o.nowMsec()
                    ,newest = msgs.list[0] && msgs.list[msgs.list.length-1].date || o.nowMsec()
                    ,isNewer = !!(oldest > dataAcc.newest) //... is data from request for 'newer'
                // Message placement :: prepend|append
                var prepend //... per active view (Newest/Oldest/Threads @ msgListMenu)

                dataAcc.oldest = (oldest > dataAcc.oldest) ? dataAcc.oldest : oldest
                dataAcc.newest = (newest < dataAcc.newest) ? dataAcc.newest : newest

                // Garbage collect this view component at this state
                msgs.list = [] //... state logs are consumed.
                //;(debugOFF) ? gc(data.msg_list, 'count', 'etag') : (msgs.list = [])

                mutex.messages.diff = dormant  // unlock

                // Dispense messages per schedule, per scroll event.
                ;(() => {
                    const 
                        aSchSignal = o.aSchedulerP.signal
                        // Interval for new messages appearing atop `#msg-list`.
                        ,waitNew = (replayFlag || chron.state) ? view.dtReplayRender : 260
                        //waitNew = chron.state ? view.dtReplayRender : 260
                        //waitNew = 260
                        ,waitReply = 10     // Interval for replies inserted ad hoc (static||scroll).

                        ,timeScroll = 200   // Interval for scroll-event throttling.
                        ,perScroll = {count: 0, max: 7} // Max mucks with fetch-request scheme.
                        ,priority = {new: 0, reply: 0} // Prioritize (index the delay) per data type.
                        ,y = {acc: 0, max: 0, last: 0, trigger: unitHeight}

                        ,schedule = (waitType, increment) => { 
                            /**********************************************************************
                             * The render scheduler sets delays per index and type (new vs reply).
                             * Such declarative time assures limits on DOM mutations
                             * regardless of the rate at which external event(s) trigger them.
                             *********************************************************************/
                            var delay 
                            if (waitType === waitNew) { 
                                delay = priority.new
                                ;(increment) ? (priority.new += 1) : (priority.new -= 1)
                            } else {
                                delay = priority.reply
                                ;(increment) ? (priority.reply += 1) : (priority.reply -= 1)
                            } 
                            return delay * waitType 
                        }
                        // Recon the rendering of a message
                        ,reckon = (rtn) => {
                            // Decrement the scheduling index (priority).
                            schedule(rtn.wType)
                            // If message rendered ...
                            ;(rtn.msg) && (
                                rendered.push(rtn.msg.id) 
                                ,dataAcc.messages++ 
                                ,(rendered.length <= mList.length) 
                                    && (!debugOFF 
                                            && logDeb('#', data.cursor, '@ dispenseMessages() :'
                                                    ,'(', rendered.length, '/', mList.length, ')'
                                                    ,(rtn.wType === waitReply) ? `Reply` : `New` 
                                                )
                                    )
                            )
                            return rtn
                        }
                        ,renderReply = (msg) => { 
                            if (rendered.includes(msg.id)) return undefined
                            /***********************************************************
                             * flagAsNew handles edge cases at non-chn type channels: 
                             * Reply message published to other channel is rendered
                             * at this channel (pub, sub, tops) as new (root) thread,
                             * else would forever await recipient.
                             * So, such are displayed regardless of toggle state. 
                             **********************************************************/
                            var flagAsNew = false

                            const // Must (re)read the mutating DOM each call.
                                toThread = o.css(`#m-${msg.to_id}`, msglistNode)
                                ,option  = o.css(`#m-${msg.to_id} .toggle[data-msg-ref=m-${msg.to_id}]`, toThread) 
                                ,expanderExists = o.css(`#m-${msg.to_id} .count-replies`)

                            ;(option && !expanderExists && !centre) 
                                && o.toDOM(option, togglerSet(toggleState.collapsed, msg.replies))

                            toThread //... recipient exists or not
                                && o.toDOM(toThread, thread(msg)) 
                                || o.toDOM(msglistNode, thread(msg)) && (flagAsNew = true)

                            centre && link(msg)
                            return (toThread || flagAsNew) ? msg : undefined
                        }
                        ,renderNew = (msg) => {
                            if (rendered.includes(msg.id)) return undefined
                            o.toDOM(msglistNode, thread(msg), prepend)
                            centre && link(msg)
                            return msg
                        }
                        ,link = (msg) => o.toDOM(
                            o.css(`#m-${msg.id} .toggle[data-msg-ref=m-${msg.id}]`)
                            // ,(  msg.to_id 
                            //         ? `<a href="/${msg.path}#m-${msg.id}" class="button">&nbsp;&#x25b6</a>` 
                            //         : `<a href="/thread/${msg.id}" class="button">&nbsp;&#x25b6</a>`
                            // )//... WIP : if a reply, then Single-thread view fails to render @ Thread (default) view.
                            // ,`<a href="/${msg.path}#m-${msg.id}" class="button">
                            //     <svg>
                            //         <use href="${svgsPath}#def-play"></use>
                            //     </svg>
                            // </a>`
                        )// 279c, 1405, 27a4, ▶ 25b6

                        // Render per async scheduler (cancellable); index delays.
                        ,render = (msg) => {
                            if (rendered.includes(msg.id)) return undefined

                            /********************************************************************
                             * Unless Chron mode and Newest requested (chron.state: 'Oldest'), 
                             * limit perScroll.count to maintain lazy loading; 
                             * lest all render in one big dump over (waitNew * length) seconds.
                            ********************************************************************/
                            if (    chron.state 
                                    && (chron.state !== 'Oldest') 
                                    && (perScroll.count++ >= perScroll.max)
                            ) { return undefined }//... lest all render at once.

                            //logFocus(msg.tokens_p,msg.tokens_q)

                            if (msg.to_id && !chron.state) {
                                // @ REPLY message (if not chron)
                                o.aSchedulerP(schedule(waitReply, true, aSchSignal), 
                                    renderReply)(msg)
                                    .then((m) => reckon({
                                            msg: m,
                                            wType: waitReply
                                        })
                                    ) 
                            } else {
                                // @ NEW message (or chron active)
                                o.aSchedulerP(schedule(waitNew, true, aSchSignal), 
                                    renderNew)(msg)
                                    .then((m) => reckon({
                                            msg: m,
                                            wType: waitNew
                                        })
                                    ) 
                            }
                        }
                        // Dispense new and reply messages per declarative-time renderers.
                        ,dispenseMessages = () => {
                            //logFocus(mList.map(el => [el.tokens_p,el.tokens_q]))
                            var count = 0
                            mutex.messages.diff = mutating  // lock
                            mList.map(render)
                            mutex.messages.diff = dormant   // unlock

                            // Update age of all messages
                            o.aDelay(view.dtReplayRender*(tallyDOM().messages + 1), updateMsgsAge)
                        }

                        // Scroll handler
                        ,onScroll = o.throttle(timeScroll, () => {
                            (abort()) && (mList.length = 0)
                            if (window.scrollY < y.max) return
                            perScroll.count = 0

                            // Record max and accumulate scroll changes
                            y.max = window.scrollY
                            y.acc += y.max - y.last 
                            ;(y.acc > y.trigger) && (
                                (trigger(y.max)) && dispenseMessages()
                                ,(y.acc = 0) //... reset regardless
                            )

                            // TODO: SIMPLER SCHEME (sans differentials)
                            //logErr('===', y.max, msglistNode.getBoundingClientRect()) // 99% CanIUse.com

                            // Recalibrate to current scroll position, and dismiss upward scrolls.
                            y.last = y.max;(y.acc < 0) && (y.acc = 0)  

                            /*******************************************************
                             * If messages remain (awaiting), 
                             * and this state's oldest is oldest of all,
                             * then request more (older messages), 
                             * unless chron-active view is 'Oldest', 
                             * where user is scrolling toward newest.
                             * 
                             * Delegate (per dType) the rendering of such 
                             * to perThread handler unless chron-active view.  
                             ******************************************************/

                            if ((rendered.length < mList.length)) {
                                ((dataAcc.oldest > oldest) && (chron.state !== 'Oldest')) 
                                    && eb.pub(eTypes.View, {
                                        node: msglistNode
                                        ,dType: (chron.state ? o.dTypes.diff : o.dTypes.full)
                                        //,dType: o.dTypes.scroll
                                        ,want: ['older']
                                        //,uri: ['ml', lTypeURI, xid, oldest] // TODO : handle /top/:lt
                                        ,uri: uriArr(oldest)
                                    }) // uri: {pg, ml}, {pub, sub, chn}, xid, [, t [, n]]
                                       // uri: ml, top/:lt [, n] @ /app/Centre

                                // Report render status.
                                !debugOFF && logDeb('#', data.cursor,'@ perMessage() :', 
                                                rendered.length, '/', mList.length, '(rendered/total)'
                                                ,'|', dataAcc.messages, 'acc'
                                                ,'|', (mList.length - rendered.length),'UNRENDERED.'
                                            )

                            // Else all messages (of this state) rendered, so: 
                            } else {
                                // Remove this renderer's scroll-event listener.
                                window.removeEventListener('scroll', onScroll)
                                // Request reset of toggler listener.
                                eb.pub(eTypes.View, {
                                    node: msglistNode,
                                    dType: o.dTypes.diff,
                                    want: ['reset']
                                }) 

                                // Report render status
                                log('#', data.cursor,'@ perMessage() :', 
                                    rendered.length, '/', mList.length, '(rendered/total)'
                                    ,'|', dataAcc.messages, 'acc'
                                    ,'| RENDERED ALL messages of state', '#', data.cursor
                                )

                                !debugOFF && o.aDelay(1000, ()=> logDeb('#', data.cursor
                                    ,': DOM @ perMessage() :', tallyDOM() 
                                ))//... costly, so only if debug mode.
                            }
                        })

                    if (lType === o.lTypes.pub) { 
                        /************************************************************************* 
                         * If this is pub-type channel, 
                         * then transfer the awaiting list from the per-thread renderer.
                         * 
                         * Note the awaitingRecipient messages are in (recursively) nested format,
                         * so future-state invocations of this renderer may find recipients 
                         * unfound at this state, depending on user-scroll behavior.
                         * 
                         * Unlike the awaiting list passed between renderers across states,
                         * the ad-hoc message list itself is not passed across states.
                         * That is, there is no attempt at reducing the number 
                         * of ad-hoc renderers running multiplexed.
                         *************************************************************************/
                        o.arrsConcat(mList, awaitingRecipient) 
                        log('#', data.cursor
                            ,'@ perMessage() > ABSORB list of awaiting-recipients :'
                            ,awaitingRecipient.length, 'threads.'
                        )
                        awaitingRecipient.length = 0 //... and reckon that.

                        // Re-sort chronologically (oldest first), in place.
                        // Unlike perThread, perMessage renders per list order.
                        mList.sort((a, b) => a.date - b.date)
                    }

                    prepend = (chron.state) ? false : true
                    ;(isNewer && chron.state === 'Oldest')      // @ Newest
                        && (prepend = true)

                    // Conditionally sort for rendering in that order (append). 

                    // @ Newest, sort to newest first (reverse chron)
                    ;(!prepend && (chron.state === 'Oldest'))  
                        && mList.sort((a, b) => b.date - a.date)

                    //@ TopList : Popular, sort by tokens_p then by tokens_q (both descending).
                    ;(centre && (chron.state !== 'Oldest')) 
                        && mList.sort((a, b) => (b.tokens_p - a.tokens_p) 
                                                    ? (b.tokens_p - a.tokens_p) 
                                                    : (b.tokens_q - a.tokens_q)
                    )
                    //... mind the chron.state and prepend flags
                    //logFocus('WTF',chron.state,prepend,mList.map(el => [el.tokens_p,el.tokens_q,el.to_handle]))

                    dispenseMessages() //... init.

                    menuTallys(cacheTotal, dataAcc.threads, chron.wanted)

                    window.addEventListener('scroll', onScroll)

                })()
            }

            // Purge messages node on first render if view type is page.
            ;( (data.cursor === 0) && (data.view.type === o.vTypes.page) ) 
                && o.purge(msglistNode)

            // @ Replay mode, cancel all (async) renderers, 
            // purge msgList node, and perform the requested replay (rendering).
            ;(replayFlag) && replay(data)

            // Publish first-render event; requesting newer messages.
            // (Triggers Net module to schedule recurring requests for newer messages.)
            ;((data.cursor === 0) && !centre)
                && eb.pub(eTypes.View, { 
                    dType: o.dTypes.diff
                    ,want: ['newer']
                    //,uri: ['ml', lTypeURI, xid]
                    ,uri: uriArr(dataAcc.newest)
                })// uri: {pg, ml}, {pub, sub, chn}, xid, [, t [, n]] 

            /*********************************************************************
             * Call the relevant renderer per chron.state and dType.
             * 
             * One renderer per state, interlacing such across states.
             * Sharing the messages-awaiting list across states
             * necessitates the wait function to assure atomicity
             * of such per-state initializations;
             * abides 'mutex' lock until 'dormant' condition.
             * 
             * See declarative-time labs for usage/demo.
             * 
             * NOTE: 
             * Current scheme differs from that of per-renderer mutex code,
             * Better to have one global mutex to handle the awaiting list ???
            *********************************************************************/ 
           
            /************************************************************************
             * Force use of perMessage() renderer if ListType is Thread,
             * else if root message is itself a reply, 
             * then it would not render lest Chron mode.
             * 
             * FAILing; breaks the Expander.
             * Unncessary for MVP: Single-thread view is mainly for hosted comments 
             * whereof thread root (article) is a new long-form message.
             ***********************************************************************/
            //;(lType === o.lTypes.th) && (data.dType = o.dTypes.diff)
            //;(lType === o.lTypes.th) && msglistNode.classList.add('single-thread')

            // Set renderer per dType : perThread only on first msg list
            ;(!chron.state && ((data.dType === o.dTypes.full) || (!dataAcc.messages && !dataAcc.threads))) 
                ? o.waitUntil(mutexFull, o.seq125(), perThread)   
                : o.waitUntil(mutexDiff, o.seq125(), perMessage)  

            //waitUntil(mutexFull, seq125(), perThread)  
            //waitUntil(mutexDiff, seq125(), perMessage)
            onSchUpdateMsgsAge()

            // If URL declares a requested message, #m-HHH..., 
            // then highlight it whenever it renders; mind the lazy loading.
            
            window.location.hash && o.aScheduleSeq(o.seq125(), () => {
                const msgWant = (window.location.hash.substring(1, 2) === 'm') 
                                    && o.css(window.location.hash)
        
                msgWant && msgWant.classList.add('new')
            })

            /*****************************************************************************
             * Example : DISQUS : hosts comments for destructoid.com
             * Dynamics: 
             * 1. Click on author opens modal (left sliding in) @ left-half of screen
             * 2. Click on member thereof opens member's DISQUS page in new tab.
             * 
             * TODO: Implement those dynamics; 
             *  pop out of iframe on anchor click, and open modal @ a higher-z iframe.
             * 
             * This caused sponsub modal to partially fail; all checkbox and radio
             * buttons were inoperable; workaround for that "unknown" cause 
             * was to explicitly set such per click. See deadSet(..) @ txn.js .
             ****************************************************************************/
            false && inIframe && window.addEventListener('click', (ev) => {
                ev.preventDefault()
                let et = ev.target
                et.href || (et = et.parentNode)
                ;((et.nodeName === 'A') && (et.href))
                    && redirect(et.href)
            })

            log('#', data.cursor, 'dType :', 
                data.dType, data.msg_list.list.length, '/', cacheTotal, '(state/cache)'
            ) 
            //logFocus(state.store)
        }
    })()
})(window[__APP__] = window[__APP__] || {}) 


