gulp = require 'gulp'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
mocha = require 'gulp-mocha'
istanbul = require 'gulp-coffee-istanbul'
del = require 'del'

sources =
  js: 'lib/**/*.js'
  coffee: 'src/**/*.coffee'
  test: 'test/**/*.coffee'

gulp.task 'clean', (callback) ->
  del [sources.js], callback

gulp.task 'lint', ->
  gulp.src sources.coffee
  .pipe coffeelint()
  .pipe coffeelint.reporter()
  .pipe coffeelint.reporter 'fail'

gulp.task 'compile', ->
  gulp.src sources.coffee
  .pipe coffee bare: true
  .pipe gulp.dest 'lib/'

gulp.task 'watch', ['compile'], ->
  gulp.watch sources.coffee, ['compile']

gulp.task 'test', ['compile'], ->
  gulp.src sources.test
  .pipe mocha()

gulp.task 'cover', ['compile'], ->
  gulp.src sources.coffee
  .pipe istanbul(includeUntested: true)
  .pipe istanbul.hookRequire()
  .on 'finish', ->
    gulp.src sources.test
    .pipe mocha()
    .pipe istanbul.writeReports()

gulp.task 'build', ['clean', 'lint', 'cover']