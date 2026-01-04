# Vue.js Framework

For a detailed explanation, check out [guide](http://vuejs-templates.github.io/webpack/) and [docs for vue-loader](http://vuejs.github.io/vue-loader).  
https://vuejs.org/v2/guide/installation.html#CLI  

## tl;dr
- `109 KB` javascript file for '`Hello World`' app.

## Install Vue CLI Dev Env.

``` bash
# Install vue-cli globally, per npm
npm install --global vue-cli
```

## vue-project

``` bash
# create a new project using the "webpack" template
vue init webpack vue-project
```

## Build Setup

``` bash
# install dependencies
cd vue-project
npm install
# serve with hot reload at localhost:8080
npm run dev  
```
## Inspect 

```bash
# Download a Web page w/ all requisites; css, js, images
wget --mirror --adjust-extension --page-requisites --convert-links --user-agent=Mozilla http://localhost:8080

# => 3 files ...
app.js      # 1 MB !!! [development]
index.html  # 1 KB
robots.txt  # 1 KB 
# for this 'Hello World' app.
```
## Production Build
```bash
# build for production with minification
npm run build  
cd dist
# serve @ localhost
npm install http-server --global
http-server -p 8080
```
## Inspect 
```bash
# Download a Web page w/ all requisites; css, js, images
wget --mirror --adjust-extension --page-requisites --convert-links  \
--user-agent=Mozilla http://localhost:8080
# => response files download to ...
/localhost+8080/
    # 100% client-side rendering: `<div id=app></div>`   
    index.html                                    # 1 KB   
      /static
      /static/css/
        app.cca059254702f9ed953b7df749673cf4.css  # 1 KB
      /static/js/             
        app.f16ac5c624284d30f5af.js               # 1 KB
        manifest.2ae2e69a05c33dfc65f8.js          # 1 KB
        vendor.5973cf24864eecc78c48.js            # 109 KB
```

```bash
# build for production and view the bundle analyzer report
npm run build --report

# run unit tests
npm run unit

# run e2e tests
npm run e2e

# run all tests
npm test
```

# Nuxt.js  
## tl;dr 
- Server-side rendering for `Vue.js` applications. **Not really ready to use.** GitHub repo instructions are rather intricate.  

```bash 
# render html @ /static/ mirroring per route @ /pages/sourceN.vue 
nuxt generate
```
>"... a framework for creating Universal Vue.js Applications."  

> "...[think] of an e-commerce web application made with nuxt generate and hosted on a CDN. Everytime a product is out of stock or back in stock, we regenerate the web app. But if the user navigates through the web app in the meantime, it will be up to date thanks to the API calls made to the e-commerce API. No need to have multiple instances of a server + a cache anymore!"  

https://nuxtjs.org/guide  
https://github.com/nuxt/nuxtjs.org  [FAILed]  
https://github.com/nuxt-community/starter-template  [FAILed]  

