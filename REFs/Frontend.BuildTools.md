# Front-End Build Tools 

##  `npx` / `npm`

```bash
# npx :: Run a module sans install
npx $_module@$_version $_ARGs
# npm :: Install a module 
npm i $_module@$_version
```

## Markdown to HTML 

- [`blackfriday`](https://github.com/russross/blackfriday "russross/... @ GitHub")
- [`markdown`](https://github.com/gomarkdown/markdown "gomarkdown/... @ GitHub") &mdash; fork of `blackfriday`
- [`mmark`](https://github.com/mmarkdown/mmark "mmarkdown/... @ GitHub") &mdash; IETF; based on `markdown`
- [`github_flavored_markdown`](https://github.com/shurcooL/github_flavored_markdown "shurcooL/... @ GitHub") | API 

    ```bash
    $ curl https://api.github.com/markdown/raw \
        -X "POST" \
        -H "Content-Type: text/plain" \
        -d "$(cat README.md)" > 'README.html'
    ```

## Syntax Highlighter :: [`highlightjs`](https://highlightjs.org/usage/ "highlightjs.org")

```js
document.addEventListener('DOMContentLoaded', (event) => {
    document.querySelectorAll('pre').forEach((block) => {
        hljs.highlightBlock(block)
    })
})
```

## [`npx`](https://github.com/npm/npx "npm/npx @ GitHub") :: use an `npm` module (e.g., CLI tool) ___sans install___ 

Run ___anywhere___, sans install &hellip;

```bash
npx MODULE[@VERSION] ARGs
```

## [`npm`](https://www.npmjs.com/ "Node Package Manager @ npmjs.com") :: install a [Node.js](https://nodejs.org "nodejs.org") module

- It is ___not uncommon___ for a module to ___not declare___ dependencies of submodules in the root `package.json`, and yet such are required for both Node.js functionality and by client-side bundler/build tools.
- (Sub)Projects can can share one `node_modules`, at project root. The Node.js Module System will resolve them, as long as their `require(..)` declaration(s) have no path references; are module-name only; i.e., `require('foo')`, not `require(./foo)`. They must be installed first, obviously. 
- Install all submodules of every `require(..)`, manually, ___at root folder___; either per `npm i SUBMODULE`, or add dependencies to `package.json`, and then run `npm i`. 
- After install, copy the app files, not the build meta, to the project root (plucked out from its `node_modules/project/SUBMODULE` folder), so it (and any changes) will be saved per tarball or whatever. (The `node_modules` folder is treated as disposable.) 
- Do ___not___ use `git clone ...` to fetch; that's a different version, and it's for its development, ___not___ for its usage; it  ___will___ fail, as will its `example`s, and by many, many modes.


@ Local install &hellip;

```bash
npm init   
npm i MODULE[@VERSION] [--save-dev]
```

- The `init` argument creates the `package.json` directives file, per user queries and module dependencies.
- The '`--save-dev`' argument _limits dependency declaration(s)_ to _development mode_; '`"devDependencies":`' at `package.json`. 
    - Build tools, and any other modules not of the application itself, should be kept out of the project's (build) dependencies ('`"dependencies":`').

@ Global install &hellip; (used for certain build tools)

```bash
npm i MODULE[@VERSION] -g
# ... then run (anywhere)
MODULE ARGs
```

Or [use `link`](https://docs.npmjs.com/cli/link "docs.npmjs.com"), if installed only locally &hellip;

```bash
npm i MODULE[@VERSION]
npm link MODULE[@VERSION]
# ... run here
MODULE ARGs
```

## Minify for production
- Sans "build tools" horror.

## [`terser`](https://www.npmjs.com/package/terser "@ npm") :: ES6 `js` 

@npx

```js
npx terser@4.3.1 --compress --mangle -- 's1.js' 's2.js' ... > 'bundle.js'
```

## [UglifyJS 3](https://github.com/mishoo/UglifyJS2 "@ GitHub")

## [`uglify-js@3`](https://www.npmjs.com/package/uglify-js "@ npm") ::  ES5 `js` (+ Beautify)

@ `npx`

```bash
npx uglify-js@3.6.0 --compress \
    --mangle reserved=['$','require','exports'] \
    -- 'pretty.js'
```

@ `npm`

```bash
# Install 
npm i uglify-js@3.6.0 -g
# CLI usage :: Compress +Mangle
uglifyjs --compress --mangle -- 'pretty.js'
# CLI usage :: Beautify 
uglifyjs --beautify wrap_iife -- 'ugly.js'
```

## [`uglify-es`](https://www.npmjs.com/package/uglify-es "@ npm") :: for pre-ES5 `js` (+Beautify)

@ `npx`

```bash
npx uglify-es@3.3.9 $_FILE --compress --mangle
```

@ `npm`

```bash
# Install as CLI
# ES6 compatible
npm install uglify-es -g
# Compress + Mangle
uglifyjs 'pretty.js'  --compress --mangle
# Beautify 
uglifyjs --beautify wrap_iife -- 'ugly.js'
```

- To use as CLI command, install globally (`-g`),   
or run "`npm link uglifyjs`".


## [`minify`](https://www.npmjs.com/package/minify "@ npm") :: for `js`, `css`, &AMP; `html` 

@ `npx`

```bash
npx minify@4.1.1 $_FILE
```

@ `npm`

```bash
# Install as CLI
npm i minify@4.1.1 -g
# Compress (+ Mangle if javascrpt)
minify $_FILE
```

## [`svgo`](https://github.com/svg/svgo "@ GitHub") :: Minify SVG

```bash
npx svgo SOURCE.svg  # Overwrites source
npx svgo SOURCE.svg -o OUT.svg
```

## [Parcel](https://parceljs.org/ "parceljs.org") &mdash; _zero-configuration bundler !_ 

###  [CLI usage](https://parceljs.org/cli.html) | [GitHub](https://github.com/parcel-bundler/parcel)


- Handles all assets.
- Entry point can be `.html` or `.js` .

@ Local install (but use as stand-alone CLI tool) &hellip;

```bash
npm i parcel-bundler
nmp link parcel
```

@ Global install &hellip;

```bash
npm i -g parcel-bundler
```

Run :: to build (production) &hellip;

```bash 
parcel build index.js
```

Run :: dev-mode build and start server w/ hot loading &hellip;

```bash 
parcel index.js  
```


~~__Warning__: @ test, the built bundle uses a __global path__ (`nvm`), as an injected parameter.~~  __UPDATE__:That's only in the developer-mode build ("`parcel index.js`").

```js
parcelRequire = (function (...) { 
    // ...
},{}]},{},["... /c/HOME/.nvm/... /node_modules/parcel/src/builtins/hmr-runtime.js","index.js"], null)
```

## Rollup | `Rollup.js` ([MD](Rollup.js.html "@ browser"))   

## Webpack | `Webpack` ([MD](Webpack.html "@ browser")) 

## [Gulp](https://www.npmjs.com/package/gulp "@ npmjs.com")  | [`Gulp.sh`](gulpfile.js)

- [Example @ PWA build](https://developers.google.com/web/ilt/pwa/lab-sw-precache-and-sw-toolbox "@ developers.google.com"). 

@ Globally, as stand-alone CLI tool &hellip; 

```bash
npm i -g gulp-cli
```

@ Locally, for use per `npm ...` 

```bash
npm init
npm i gulp --save-dev
``` 

## [Yarn](https://yarnpkg.com/en/docs/install#windows-stable "yarnpkg.com")
- Run @ Git `bash` or `cmd`.  
- Install  using "`choco install yarn`".
    - Yarn @ "`Program Files x86`"  ___interferes___ with Yarn @ WSL.

## [browserify](http://browserify.org/) | @[GitHub](https://github.com/substack)  

```bash
npm i browserify                # install
browserify main.js > bundle.js  # use 
```

# OLDER [2017]

## Modularization / Bundlers

> [Mithril.js.org @ 2017](https://mithril.js.org/archive/v1.1.6/installation.html#quick-start-with-webpack)
:  
Modularization is the practice of separating the code into files. Doing so makes it easier to find code, understand what code relies on what code, and test. [__CommonJS__](https://en.wikipedia.org/wiki/CommonJS "@ Wikipedia") is ___a de-facto standard___ for modularizing Javascript code _for use_ ___outside the browser___;  used by __Node.js__, and buld tools; __Browserify__, __Webpack__, ....   

> It's a robust, battle-tested precursor to ES6 modules, whereas the ES6 module loading mechanism is not. To use ___non-standardized module loading___, use tools like __Rollup__, __Babel__ or __Traceur__.

> Most __browsers do not support modularization__ (CommonJS or ES6), so modularized __code must be bundled into a single Javascript file__ before running in a client-side application. A popular way for creating a bundle is to setup an NPM script for __Webpack__.  

## `npm` :: [Node Package Manager](https://docs.npmjs.com/ "docs.npmjs.com") (NPM) 

```bash
npm i $_MODULE -g      # Install globally
npm i $_MODULE --save  # Install locally
npm ls                 # List all LOCAL installs
```

- PKGs are installed to `./node_modules` .
- The "`--save`" flag inserts dependency declarations into `package.json`; subsequent "`npm i $PKG`" command fetches all dependencies; allows delete of (heavy) `node_modules` folder, for portability. 
    - Use "`--save-dev`" instead when installing __build tools__ and any other modules not of the application itself:

        ```bash
        npm i $_BUILD_TOOLs --save-dev
        ```

### [`npm.sh`](node.sh)

- [`npm` CLI commands](https://docs.npmjs.com/cli/npm.html) | [@ `install`](https://docs.npmjs.com/cli/install.html)
- Online module search @ [npmSearch.com](http://npmsearch.com/)

## `npx` ::  [Execute an `npm` module binary](https://github.com/zkat/npx "@ GitHub") ___sans install___

```bash
# Run a pkg/command
npx $pkg_name@$pkg_version              # If pkg has one binary (command)
npx -p $pkg_name@$pkg_version $command  # If pkg has several binaries (commands)
# E.g.,
npx cowsay "Hello"                      # run cowsay (nothing lands @ PWD)
# E.g., 
npx create-react-app 'app-1'            # Create a react app
npx vue create 'app-1'                  # Create a vue app
```

## Typical `nmp` Project Setup

```bash
$ mkdir $_PKG && cd $_PKG
$ npm init --yes
$ npm install $_PKG --save
$ npm install webpack webpack-cli --save-dev
# ... + other tools/dependencies ...
$ npm install budo -g
```

    $ tree -L 1
    .
    ├── bin         # target of build tools
    ├── index.html
    ├── node_modules
    ├── package-lock.json
    ├── package.json
    └── src         # sources for build tools

- Source and target files set @ `package.json`, in `"scripts": {...}`, per task/tool.  
E.g., may want `./dev` and `./prod`; `./dist` is a commonly used target dir for prod version.
### Add/Mod `scripts` section @ `package.json`

```json
{
    // ...
    "scripts": {
        "dev": "webpack src/index.js --output bin/app.js -d --watch",
        "hot": "budo --live --open index.js",
        "prod": "webpack src/index.js --output bin/app.js -p"
    }
}
```

# Packages @ `Node.js` Ecosystem

## [http-server](https://www.npmjs.com/package/http-server#available-options "NPMjs.com") 

### Run @ `npx`

```bash
npx http-server -p 5555
```

### Install &amp; Run @ `npm`

```bash
npm install http-server -g # @ http://127.0.0.1:8080/
cd "$_web_app_dir"
http-server  # index.html @ PWD; careful about path chars; map to a:\
```

## [Typescript](https://code.visualstudio.com/docs/typescript/typescript-compiling "code.VisualStudio.com") Compiler 

Install 

```bash 
$ npm install -g typescript  # install globally
$ tsc --version              # version/verify
Version 3.4.5
```

Use 

```bash 
$ tsc 'hello.ts'   # Compile .ts file to .js
$ node 'hello.js'  # Run compiled .js file
Hello World
```  


## [markdown-to-html](https://www.npmjs.com/package/) 
```bash
npm install markdown-to-html --save
```

## [web-push](https://www.npmjs.com/package/web-push) 

```bash 
npm install web-push -g
```
-  VAPID Protocol
    - Generate keys [URL Safe Base64 encoded strings.]
        ```bash
        web-push generate-vapid-keys [--json] > web-push-VAPID-key-pair
        ```

## [Animate.css](https://daneden.github.io/animate.css/) (`9KB`)

```bash
$ npm install 'animate.css' --save  # Dumps files to PWD
```

## [Ant UI/UX Design @React @Typescript](https://ant.design/docs/react/use-in-typescript "ant.design/docs/react/...")  | [Typescript @ React](https://facebook.github.io/create-react-app/docs/adding-typescript "facebook.github.io")

- Install `create-react-app` (boilerplate)  

    ```bash
    # Create/Launch React app boilerplate (create-react-app)
    $ npx create-react-app antd-demo-ts --typescript
    $ cd antd-demo-ts
    $ yarn start
    ```
    - Browser @ http://localhost:3000/ 
     
    - Yarn failed @ WSL terminal; worked @ Git bash.

- Import `antd` UI/UX modules (Stop the server beforehand; `CTRL-C`) 

    ```bash
    $ yarn add antd
    ```

- [Modify `src/App.tsx`](src/App.tsx); import Button component from `antd`.  
_Hot-reloads !!!_

- Build (for production)   
    ```bash
    $ yarn build 
    ```

    - Target/build @ `./build` ; generates `.js` @ `675 KB` and `.css` @ `436 KB`  

    - Served per `http` (a Golang server), and saved Web page @ Firefox,   
    which confirms total size of served assets; `1.08 MB`. 

- [Code Splitting](https://facebook.github.io/create-react-app/docs/code-splitting)   
Instead of downloading the entire app;  
split code into small chunks which are load on demand.

- See [CRA-PWA info](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#making-a-progressive-web-app "GitHub/Facebook/... CRA PWA")

## More `npm` / `node` Commands 

### (See: [`npm.sh`](node.sh))

```bash
npm search moduleName     # Package Search
npm docs moduleName       # Package Documentation [online] 

-g	# GLOBAL; run as root (Administrator) whenever using the `-g` option

npm install npm@latest -g  # update npm to latest
npm install node <ver> -g  # NOT advised though npm can be used to install/upgrade Node.js

# version info
node -v  
npm -v

# test that it's working ... 
$ echo "console.log('Test foo!')" > index.js
node index.js  #=> Test foo!

# npm account (to contribute packages)
npm whoami 
npm adduser 

# @ CLONEd project dir
npm install  # fetch/install per 'package.json' instructions
npm start    # or whatever command, per 'package.json'

# start NEW project
npm init [--scope=Uzer] # @ project dir
npm init                # create package.json to track dependencies etal
# once command(s) configured, e.g., 
npm start                    # per 'package.json' :: "scripts" > "start" 
# e.g., 
"scripts": {
"start": "electron ."
...

vim index.js   
"
const express = require('express')
const app = express()

app.get('/', (req, res) => {
res.send('index.js app per NodeJS/Express')
})

app.listen(5555, () => console.log('Server running on port 5555'))
"
# @ AWS, Must add SG rule @ EC2 instance: TCP @ Port 5555

git init # to start new git repo
npm install express --save-dev

# npm works @ project dir; expects package.json
# install, etc, all from there, so first ...
cd PROJECT_PATH  # ... go to app folder
# if dir does not have package.json, then expect warnings thereof on every npm install

# project workflow; add dev-dependencies to install task @ package.json using 
npm install pkg1 pkg2 ... --save-dev 
# install libraries for client-side dev ...
npm install budo watchify --save-dev 
# so, future ...
npm install  # handles all the dev-dependencies

# remove module 
npm rm moduleName --save # or ...
npm uninistall moduleName --save 

# list dependencies
npm ls 

# publish, per "name":"MODULE" [package.json]
npm publish

# view published module 
npm view MODULE

# update version number @ package.json 
npm version # can't publish w/out new version number 

# distribution tag [custom]; default is 'latest'
npm dist-tag add <module>@<version> [<tag>]

# detect outdated dependencies 
npm outdated 

# update dependencies 
npm install # or ...
npm update 

# tests 
npm test  # runs ./test.js, 
# also insert @ package.json
"scripts": {
"test": "node test.js"
},

# run a javascrpt file
node fname.js

# passing arguments
# modules
```

### &nbsp;
<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

