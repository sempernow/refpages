function makeRequest(resource) {
    // create a  XMLHttpRequest
    var xhr = new XMLHttpRequest()
    // open the request
    xhr.open('GET', resource)
    // handles the response
    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
            alert(xhr.responseText)
        }
    }
    // send the request
    xhr.send()
}


document.querySelector('h1').onclick = makeRequest // ugly; no args

makeRequest('test.doc') // @ local (client-side file)
makeRequest('/foo')     // @ server