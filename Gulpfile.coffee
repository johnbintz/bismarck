gulp = require('gulp')

$ = require('gulp-load-plugins')()

browserify = require('browserify')
source = require('vinyl-source-stream')
coffeeify = require('coffeeify')
watchify = require('watchify')

karma = require('karma')

gulp.task 'browserify', ->
  browserify('./src/bismarck.coffee', extensions: ['.coffee'])
    .transform({}, coffeeify)
    .pipe source('bismarck.js')
    .pipe gulp.dest('./dist')

gulp.task 'watch', ->
  gulp.watch './src/**/*.coffee', ['coffee', 'browserify']

gulp.task 'coffee', ->
  gulp
    .src('./src/**/*.coffee')
    .pipe $.coffee(bare: true)
    .pipe gulp.dest('./lib')

gulp.task 'scripts', ->
  bundlerTarget(createBrowserify().bundle())

gulp.task 'karma', ->
  karma.server.start {
    configFile: __dirname + '/karma.conf.js'
  }

gulp.task 'default', ['scripts', 'watch', 'karma']

