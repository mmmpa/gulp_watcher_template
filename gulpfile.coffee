gulp = require('gulp')

coffee = require('gulp-coffee')
jade = require('gulp-jade')
sass = require('gulp-ruby-sass')
compass = require('gulp-compass')

concat = require('gulp-concat')
minify = require('gulp-minify-css')
plumber = require('gulp-plumber')

argv = require('yargs').argv
spawn = require('child_process').spawn

_ = require 'lodash'

path = require('path')
rootPath = path.join(__dirname, '../')
tempPath = path.join(__dirname, 'temp')
publicJsPath = path.join(rootPath, 'public/js')

gulp.task 'default', ->
  p = undefined

  spawnChildren = (e) ->
    if p
      p.kill()
    p = spawn('gulp', ['watcher'], stdio: 'inherit')

  gulp.watch 'gulpfile.coffee', spawnChildren
  spawnChildren null

gulp.task 'watcher', ->
  sassWatch = path.join(rootPath, 'src/sass/**/*.sass')
  coffeeWatch = path.join(rootPath, 'src/coffee/**/*.coffee')
  jadeWatch = path.join(rootPath, 'src/jade/**/*.jade')

  split = (filePath)->
    _(path.relative(rootPath, filePath).split('/')).drop(2).dropRight(1).value()

  genPath = (dirs, filePath)->
    dirs.concat(split(filePath)).join('/')

  gulp.watch(sassWatch).on 'change', (e) ->
    dest = genPath(['public', 'css'], e.path)

    gulp
    .src e.path
    .pipe plumber()
    .pipe sass(compass: true)
    .pipe minify(keepBreaks: false)
    .pipe gulp.dest(path.join(rootPath, dest))

  gulp.watch(coffeeWatch).on 'change', (e) ->
    dest = genPath(['public', 'js'], e.path)

    gulp
    .src e.path
    .pipe plumber()
    .pipe coffee()
    .pipe gulp.dest(path.join(rootPath, dest))

  gulp.watch(jadeWatch).on 'change', (e) ->
    dest = genPath(['public'], e.path)

    gulp
    .src e.path
    .pipe plumber()
    .pipe jade()
    .pipe gulp.dest(path.join(rootPath, dest))
