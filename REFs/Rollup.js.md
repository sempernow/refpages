# [Rollup.js](https://rollupjs.org/guide/en#quick-start "Quick Start @ rollupjs.org") | [@ GitHub](https://github.com/rollup)

The `rollup` CLI tool is the newest/simplest of all the module bundlers. 

## Bundle __CommonJS__  (`npm`) app for __browser__

```bash
npm init
npm i 
npm i -g rollup
```

```bash
# For Browsers (IIFE)
rollup 'main.js' --file 'bundle.js' --format 'iife'

# For Node.js (CommonJS)
rollup 'main.js' --file 'bundle.js' --format 'cjs'

# For Browsers & Node.js (UMD)
rollup 'main.js' --file 'bundle.js' --format 'umd' --name 'appBundle'
```

## + Convert modules from __CommonJS__ to __ES6__

### Rollup ___plugins___ to load __CommonJS__ modules:

- [`rollup-plugin-node-resolve`](https://github.com/rollup/rollup-plugin-node-resolve "@ GitHub")
- [`rollup-plugin-commonjs`](https://github.com/rollup/rollup-plugin-commonjs "@ GitHub") 

- Install

    ```bash
    npm i --save-dev 'rollup-plugin-commonjs'
    npm i --save-dev 'rollup-plugin-node-resolve' 
    ```

- Use [@ `rollup.config.js`](rollup.config.js)

    ```js
    import resolve from 'rollup-plugin-node-resolve'
    import commonjs from 'rollup-plugin-commonjs'
    ```

    - Also, set "`exports: 'named'`" at `output.exports` to handle any `global` (Window object); Node.js has no such object.

### Build _declaratively_ [(`rollup.config.js`)](rollup.config.js)

```bash
rollup -c
```


## `Frontend.BuildTools` ([MD](Frontend.BuildTools.html "@ browser"))   


### &nbsp;
<!-- 

# [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "______")

([MD](___.html "@ browser"))   

-->

