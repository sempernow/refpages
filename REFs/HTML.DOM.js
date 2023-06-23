
// querySelector()  https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector
document.querySelector('body') // Returns first el found, else null
document.querySelector('div.user-panel.main input[name="login"]') 

// innerHTML   - parses content as HTML, so it takes longer.
// nodeValue   - uses straight text, does not parse HTML, and is faster.
// textContent - uses straight text, does not parse HTML, and is faster.
// innerText   - Takes styles into consideration. It won't get hidden text for instance.
// https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent 

// textContent ~ 3x faster than innerHTML; 
// reportedly causes LAYOUT THRASHING, but that makes no sense.

// Iterate over HTMLCollection
var collection = ul.getElementsByTagName('A')
for (let anchor of collection) { 
    anchor.classList.remove('active')
}

// MEDIA QUERY :: Listen for VIEWPORT changes
    width = '(max-width: 600px)'
    mq = window.matchMedia(width)
    mq.addListener(onMQEvent)  // onMQEvent is handler function
    // OR, perhaps utilizing `window.innerWidth` @ handler function ...
    window.addEventListener('resize', someOTHERfunc) 

// Attach event (ev) listener/handler (f) to an HTML element (id)
function eventListenIdHandle(ev, id, f) {
    ;(document.getElementById(id)).addEventListener(ev, f)
}

// Set background color (c) of first 'PRE' tag element
function _setBkgnd(c) {
    c ? c : (c = "#ddd")
    document.getElementsByTagName("pre")[0].style.background = c
}

// Register _setBkgnd(c)
function _setBkgndC(c) {
    return function () {
        return _setBkgnd(c)
    }
}

// Set+Toggle class (c) of first 'PRE' tag element
function _setClass(c) {
    c ? c : (c = "appdefault")
    el = document.getElementsByTagName("pre")[0]
    el.className ? el.classList.toggle(c) : el.className = c
}

// Register _setClass(c)
function _setClassC(c) {
    return function () {
        return _setClass(c)
    }
}

// Set backgound colors at 'data-append' attrib elements, per their 'data-color' attrib 
function _dataColor() {
    el_S = document.querySelectorAll('[data-append="_SUCCESS_"]')[0]
    el_F = document.querySelectorAll('[data-append="_FAILURE_"]')[0]
    el_S.style.background = el_S.getAttribute("data-color")
    el_F.style.background = el_F.getAttribute("data-color")
}

// Document Fragment
    var node = document.getElementsByTagName('TBODY')[0]
    var frag = document.createDocumentFragment()
    var td, code

    function iter(i){
        td = document.createElement('TD')
        td.className = 'dbname' 
        code = document.createElement('CODE')
        td.appendChild(code)
        code.textContent = `td${i}` 
        frag.appendChild(td)
    }
    [...Array(parseInt(app.ITEMS)).keys()].map(iter)

    node.appendChild(frag)

