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

path = require('path')
root_path = path.join(__dirname, '../')

gulp.task 'default', ->
  p = undefined

  spawnChildren = (e) ->
    if p
      p.kill()
    p = spawn('gulp', [ 'watcher' ], stdio: 'inherit')

  gulp.watch 'gulpfile.coffee', spawnChildren
  spawnChildren null

gulp.task 'watcher', ->
  sass_watch = path.join(root_path, 'sass/**/*.sass')
  coffee_watch = path.join(root_path, 'coffee/**/*.coffee')
  jade_watch = path.join(root_path, 'jade/**/*.jade')

  gulp.watch(sass_watch).on 'change', (e) ->
    dest = path.relative(root_path, e.path).split('/')
    dest.shift()
    dest.pop()
    dest.unshift 'css'
    gulp.src(e.path).pipe(plumber()).pipe(sass(compass: true)).pipe(minify(keepBreaks: false)).pipe gulp.dest(path.join(root_path, dest.join('/')))

  gulp.watch(coffee_watch).on 'change', (e) ->
    dest = path.relative(root_path, e.path).split('/')
    dest.shift()
    dest.pop()
    dest.unshift 'js'
    gulp.src(e.path).pipe(plumber()).pipe(coffee()).pipe gulp.dest(path.join(root_path, dest.join('/')))

  gulp.watch(jade_watch).on 'change', (e) ->
    dest = path.relative(root_path, e.path).split('/')
    dest.shift()
    dest.pop()
    gulp.src(e.path).pipe(plumber()).pipe(jade()).pipe gulp.dest(path.join(root_path, dest.join('/')))
