const gulp = require('gulp')
const zip = require('gulp-zip')
const replace = require('gulp-replace')
const dateformat = require('dateformat')
const bump = require('gulp-bump')
const newer = require('gulp-newer')
const fs = require('fs')
const exist = require('gulp-exist')
const git = require('git-rev-sync')

const packageJson = require('./package.json')
const existConfig = require('./existConfig.json')
const existClient = exist.createClient(existConfig)

// bump version on patch level
gulp.task('bump-patch', function () {
  return gulp.src(['./package.json'])
    .pipe(bump({ type: 'patch' }))
    .pipe(gulp.dest('./'))
})

// bump version on minor level
gulp.task('bump-minor', function () {
  return gulp.src(['./package.json'])
    .pipe(bump({ type: 'minor' }))
    .pipe(gulp.dest('./'))
})

// bump version on major level
gulp.task('bump-major', function () {
  return gulp.src(['./package.json'])
    .pipe(bump({ type: 'major' }))
    .pipe(gulp.dest('./'))
})

// set up basic xar structure
gulp.task('xar-structure', function () {
  return gulp.src(['./eXist-app-template/**/*'])
    .pipe(replace('$$deployed$$', dateformat(Date.now(), 'isoUtcDateTime')))
    .pipe(replace('$$version$$', getPackageJsonVersion()))
    .pipe(replace('$$desc$$', packageJson.description))
    .pipe(replace('$$license$$', packageJson.license))
    .pipe(gulp.dest('./build/'))
})

// reading from fs as this prevents caching problems
function getPackageJsonVersion () {
  return JSON.parse(fs.readFileSync('./package.json', 'utf8')).version
}

// gets git info used in other tasks
function getGitInfo () {
  return { short: git.short(),
    url: 'https://github.com/BeethovensWerkstatt/module2/commit/' + git.short(),
    dirty: git.isDirty() }
}

// handles data
gulp.task('data', function () {
  return gulp.src('./data/**/*')
    .pipe(newer('./build/content/'))
    .pipe(gulp.dest('./build/content/'))
})

/**
 * deploys the current build folder into a (local) exist database
 */
gulp.task('deploy', function () {
  const git = getGitInfo()

  return gulp.src('**/*', { cwd: 'build' })

    .pipe(replace('$$git-url$$', git.url))
    .pipe(replace('$$git-short$$', git.short))
    .pipe(replace('$$git-dirty$$', git.dirty))

    .pipe(existClient.newer({ target: '/db/apps/modul2/' }))
    .pipe(existClient.dest({ target: '/db/apps/modul2/' }))
})

gulp.task('dist', function () {
  const git = getGitInfo()

  return gulp.src('./build/**/*')

    .pipe(replace('$$git-url$$', git.url))
    .pipe(replace('$$git-short$$', git.short))
    .pipe(replace('$$git-dirty$$', git.dirty))

    .pipe(zip(packageJson.name + '-' + getPackageJsonVersion() + '.xar'))
    .pipe(gulp.dest('./dist'))
})
