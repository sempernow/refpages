# Gulp  
#  https://developers.google.com/web/ilt/pwa/introduction-to-gulp
#  https://developers.google.com/web/ilt/pwa/lab-sw-precache-and-sw-toolbox
exit
# install cli, available @ any directory
npm install --global gulp-cli

cd ... /app # go to project dir
npm init # creates 'package.json'; info about the project and its dependencies.
    # package.json
        {
            "name": "test",
            "version": "1.0.0",
            "description": "",
            "main": "index.js",
            "scripts": {
                "test": "echo \"Error: no test specified\" && exit 1"
            },
            "author": "",
            "license": "ISC",
            "devDependencies": {
                "gulp": "^3.9.1"
            }
        }

npm install gulp --save-dev # download required Gulp dependencies

    # creates ... and subdirs [~3MB]; each dir has one or more: .js, .json, .md
    ./app/node_modules

# install the sw-precache and sw-toolbox pkgs, and path pkg
npm install --save-dev path sw-precache sw-toolbox

# run task; after setting config @ gulpfile.js
    gulp TASKNAME
    
# run task: generate service-worker.js
    gulp service-worker 

# COMMON BUILD PATTERN

    # gulpfile.js
        // Include plugins

        var gulp = require('gulp'),
            pluginA = require('pluginA'),
            pluginB = require('pluginB'),
            pluginC = require('pluginC'),
            webserver = require('gulp-webserver');

        // Define tasks

        gulp.task('task-A', function() {
            gulp.src('some-source-files')
            .pipe(pluginA())
            .pipe(gulp.dest('some-destination'));
        });

        gulp.task('task-BC', function() {
            gulp.src('other-source-files')
            .pipe(pluginB())
            .pipe(pluginC())
            .pipe(gulp.dest('some-other-destination'));
        });

        gulp.task('webserver', function() {
            gulp.src('.')
                .pipe(webserver({
                    port: 8080,
                    livereload: true,
                    open: true,
                    fallback: 'mustache.html'
                }));
        });

        gulp.task('default', ['webserver']);