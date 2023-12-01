exit
# npm :: Node Package Manager
# Install per "install.node.sh" or "install.node@nvm.sh"
# Update npm
    npm install npm@latest -g  # update npm to latest

# FIX if "npm ERR! Maximum call stack size exceeded"
    npm cache clean --force
    npm rebuild -g           
    # Also, can delete all or part @ ... 
    ~/.npmrc

# version info
    node -v  
    npm -v
    npm version  # lots of info 

npx  # Execute npm pkg binaries (sans install)  https://github.com/zkat/npx 
    npm i -g npx  # Install npx 

    npx [options] <command>[@version] [command-arg]...
    npx [options] [-p|--package <pkg>]... <command> [command-arg]...

nvm  # Node Version Manager  https://github.com/nvm-sh/nvm 
    npm install -g npx
    -g	# GLOBAL; run as root (Administrator) whenever using the `-g` option

# detect/update outdated dependencies [-g for global] 
    npm outdated -g  # detect/list
    npm update -g    # update them all

# Package Search / Docs
    npm search PKG     # Package Search
    npm docs PKG       # Package Documentation [online] 

# npm account (to contribute packages)
    npm whoami 
    npm adduser 

# Init
    npm init [--scope=Uzer] # @ project dir
    npm init                # create package.json to track dependencies etal
    
# @ CLONEd project dir
    npm install             # fetch/install per 'package.json' instructions
    npm $_COMMAND           # per 'package.json'

# Install
    npm i                   # update [all dependencies] per 'package.json'
    npm i -g $_PKG          # install PKG globally
    npm i $_PKG --save-dev  # install PKG locally; not a dependency; use for build tool installs
    npm i $_PKG --save      # install PKG locally; updates 'package.json'
    # thereby, we can delete the heavy node_modules folder, for portability, 
    # and then any subsequent `npm install` command fetches it  
    npm i username/repo     # from GitHub repo

# list dependencies
    npm ls 

# List global installs
    npm list -g --depth 0

# remove module 
    npm rm PKG --save 
    # or
    npm uninistall PKG --save 
    
# publish, per "name":"MODULE" [package.json]
    npm publish

# view published module 
    npm view PKG

# distribution tag [custom]; default is 'latest'
    npm dist-tag add <module>@<version> [<tag>]
    

# tests 
    npm test  # runs ./test.js, 
    # also insert @ package.json
      "scripts": {
    "test": "node test.js"
  },
    
# passing arguments
# modules

  # See:  REF.Node.REPL.js

# ==================
#  MODULEs
# ==================

# Webpack  https://webpack.js.org/  https://webpack.js.org/guides/getting-started/
#  video:  https://www.youtube.com/watch?v=GU-2T7k9NfI
    npm init                        # init @ working project dir; creates 'package.json'
    npm install webpack --save-dev  # install, for dev only
    # then, @ package.json, identify per entry point and output [distribution] file
    "build":"webpack src/js/app.js dist/bundle.js" 
    ...
    "devDependencies": {
        "webpack":"^2.2.1"
        ...
    }

# browserify  http://browserify.org/  https://github.com/substack
#   bundles [bundle.js] all dependencies per 'entry file', e.g., main.js
#   AND includes browser-compatible versions of [many] core Node.js modules
    npm install -g browserify       # install
    browserify main.js > bundle.js  # use 
    
# markdown-to-html  https://www.npmjs.com/package/markdown-to-html
    npm install markdown-to-html --save

# web-push  https://www.npmjs.com/package/web-push
    npm install web-push -g
    # VAPID Protocol; Generate keys [URL Safe Base64 encoded strings.]
    web-push generate-vapid-keys [--json] > web-push-VAPID-key-pair

# http-server  https://www.npmjs.com/package/http-server
    npm install http-server -g # @ http://127.0.0.1:8080/
    cd "$_web_app_dir"
    http-server  # index.html @ PWD; careful about path chars; map to a:\

# Gulp  https://www.npmjs.com/package/gulp
    # https://developers.google.com/web/ilt/pwa/lab-sw-precache-and-sw-toolbox
    # install cli, available @ any directory
    npm install --global gulp-cli
    
    npm init # creates 'package.json'; info about the project and its dependencies.
    npm install gulp --save-dev # download required Gulp dependencies
    
        # creates ... and subdirs [~3MB]; each dir has one or more: .js, .json, .md
        ./app/node_modules
    
    # install the sw-precache and sw-toolbox pkgs, and path pkg
    npm install --save-dev path sw-precache sw-toolbox
    
    # run task: generate service-worker.js; after setting config @ gulpfile.js
    gulp service-worker 
    