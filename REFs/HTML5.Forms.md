
# [HTML `<form>`](https://developer.mozilla.org/en-US/docs/Learn/HTML/Forms "MDN")

## [HTML Form `<input>` element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input "MDN") :: [Types](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Form_%3Cinput%3E_types "MDN") | [Attributes](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Attributes "MDN") | [Methods](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Methods "MDN")

## [HTML Form `enctype`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/enctype "MDN")

#### `<form ... enctype="...">`

    application/x-www-form-urlencoded   Default type.
    multipart/form-data                 @ File uploads.
    text/plain                          @ HTML5.


- @ [File Uploads](https://developer.mozilla.org/en-US/docs/Learn/HTML/Forms/Sending_and_retrieving_form_data#A_special_case_sending_files "MDN") 

    ```html
    <form 
        method="post" 
        enctype="multipart/form-data"
    >
      <div>
        <label for="file">Choose a file</label>
        <input type="file" id="file" name="myFile">
      </div>
      <div>
        <button>Send the file</button>
      </div>
    </form>
    ```

## [Form Validation](https://developer.mozilla.org/en-US/docs/Learn/HTML/Forms/Form_validation#Using_built-in_form_validation "MDN") :: HTML5 Built-in
 
### HTML :: [`<input ... required>`](https://developer.mozilla.org/en-US/docs/Learn/HTML/Forms/Form_validation#The_required_attribute "MDN")

```html
<form>
    <label for="choose">Would you prefer a banana or a cherry?</label>
    <input 
        id="choose" 
        name="i_like" 
        required pattern="banana|cherry"
    >
    <label for="pass">PASSWORD</label>
    <input 
        type="password" 
        name="pass"
        minlength="12" 
        maxlength="99" 
        size="30" 
        required
    >
    <button type="submit">Submit</button>
</form>
```

### CSS :: `:valid` and `:invalid` pseudo-types

```css
input:invalid {
    border: 2px dashed red;
}

input:valid {
    border: 2px solid black;
}
```

- However, the message popup of `<input ... required>` is ___hard coded___  (UI/UX) into browsers; cannot be fixed using CSS alone; the ___fix requires javascript___.

## [Constraint Validation API](https://developer.mozilla.org/en-US/docs/Web/API/Constraint_validation "MDN") :: HTML5 + JS

### [`checkValidity()`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLSelectElement/checkValidity "MDN")

- `<input type="number" ... min="1" max="10">`
- `<input ... required pattern="banana|cherry">`
- `<input ... required pattern="[A-Za-z]+>`
- `<input ... required minlength="6">`

#### HTML

```html
<form id="signUpForm">
    <input type="email" min="1" id="emailField" placeholder="Email Address">
    <button id="okButton" disabled>OK</button>
</form>
<p id="signUpForm-post"></p>
```

#### JS

```js
const signUpForm = document.getElementById('signUpForm')
const emailField = document.getElementById('emailField')
const okButton = document.getElementById('okButton')
const msg = document.getElementById('signUpForm-post')

msg.style.display = "none" 
okButton.disabled = true

emailField.addEventListener('keyup', function (event) {
    isValidEmail = emailField.checkValidity();
    console.log("status ::",isValidEmail,emailField.value)
    if (isValidEmail && emailField.value) {
        okButton.disabled = false
    } else {
        okButton.disabled = true
    }
})

okButton.addEventListener('click', function (event) {
    console.log("value ::",emailField.value)
    if (emailField.value) {
        signUpForm.setAttribute('hidden', '')
        signUpForm.style.display = "none" 
        msg.innerHTML = 'Thanks!'
        msg.style.display = "block" 
    }
    else {
        msg.innerHTML = 'Must be valid.'
        msg.style.display = "block" 
    }
     //signUpForm.submit()
    event.preventDefault() // disable POST action; do nothing
})
```

## [Custom Form Widgets](https://developer.mozilla.org/en-US/docs/Learn/HTML/Forms/How_to_build_custom_form_widgets "MDN")

### &nbsp;

<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

