
# [Webpack](https://webpack.js.org/ "Webpack.js.org") | [Guides](https://webpack.js.org/guides/getting-started/)  

A stunningly stupid "build tool". Rigid as Rigamortis, and brittle as cheap china; forbidden filenames; forbidden directory names; the list of forbiddens is damn near infinite. The resulting `bundle.js` is a horror show. In a word, it's `npm`.

```bash
npm init -y
npm i webpack --save-dev
npm i webpack-cli --save-dev
```

## tl;dr  
The resulting build (`bundle.js`), to import a one-line function, is 100 lines of horrific code. Somehow, they managed to do this even to the ES6 Module system; transmuting its one-liner `import { name} ...` statement into their ___big garbled mess___. The process is heavily imperative. Its own core config files, `package.json` and `webpack.config.js`, mutate with build phases, each of each phase requiring manual edits, and all ___by design___.

- The app source files here total `300 bytes` (not minified), yet their _minified production_ `bundle.js` is over `300%` _larger_. The ratio doesn't improve with project size; it gets worse, because there are more dependencies to track, though needlessly so, thanks to [ES6 Modules, which work in the browser](https://caniuse.com/#feat=es6-module-dynamic-import "@ CanIUse.com") sans Webpack or any other bundler. 

### Mod [@ `webpack.config.js`](webpack.config.js)

- Must mod/overwrite on devel, test, prod, ...

### Mod [@ `index.js`](src/index.js)

```js
import { cube } from './math.js'
```

- Yes, this ES6 Modules beauty should be the end of it, but no, this is the black-hole of stupid that is the Node ecosystem, so Webpack is going to change this into a hundred or so lines @ `bundle.js`.

### Mod [@ `math.js`](src/math.js)

### Mod [@ `package.json`](package.json)

```json
{
  "name": "webpack-x",
  "sideEffects": [
      "protect-this-polyfill.js",
      "*.css"
      ]
//...
"scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "build": "webpack"
},
//...
```

- Must mod/overwrite on devel, test, prod, ...


### Build

```bash
npm run build
```


### [@ `bundle.js`](dist/bundle.js)
- Must mod/overwrite on devel, test, prod, ...

### [@ `bundle.devel.js`](dist/bundle.devel.js) (renamed/saved)

- Must rename, else overwritten by Webpack on prod, as must be its own config file.

## [Tree Shaking](https://webpack.js.org/guides/tree-shaking/ "Webpack.js.org")



### &nbsp;
<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

