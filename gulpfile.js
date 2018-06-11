var gulp = require('gulp');
var zip = require('gulp-zip');
var sass = require('gulp-sass');
var concat = require('gulp-concat');
var replace = require('gulp-replace');
var dateformat = require('dateformat');
var del = require('del');
var packageJson = require('./package.json');
var bump = require('gulp-bump');
var fs = require('fs');
var browserify = require('browserify');
var babel = require('gulp-babel');
var uglify = require('gulp-uglify');
var eslint = require('gulp-eslint');
var gulpIf = require('gulp-if');

/** 
 *  This task loads custom assets, installed via npm, by copying 
 *  them to the corresponding folders in the build directory.
 */
gulp.task('load-assets', function() {
    //include verovio dev    
    gulp.src(['./node_modules/verovio-dev/index.js'])
        .pipe(concat('verovio-toolkit-dev.js'))
        .pipe(gulp.dest('./build/resources/js/'));
});

//handles html
gulp.task('html', function(){
    return gulp.src('./source/html/**/*')
        .pipe(gulp.dest('./build/'));
});

//compiles scss to css
gulp.task('css', function(){
    return gulp.src('./source/sass/main.scss')
        .pipe(sass({outputStyle: 'compressed'}).on('error', sass.logError))
        .pipe(gulp.dest('./build/resources/css'));
});

function isFixed(file) {
    // Has ESLint fixed the file contents?
    return file.eslint != null && file.eslint.fixed;
}

//handles javascript
gulp.task('js', function(){
    
    //compile javascript
    gulp.src(['./source/js/main.js'])
        .pipe(babel())
        .pipe(concat('main.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('./build/resources/js/'));
});

gulp.task('lint', function() {
    // ESLint ignores files with "node_modules" paths.
    // So, it's best to have gulp ignore the directory as well.
    // Also, Be sure to return the stream from the task;
    // Otherwise, the task may end before the stream has finished.
    return gulp.src(['./source/js/**/*.js'])
        // eslint() attaches the lint output to the "eslint" property
        // of the file object so it can be used by other modules.
        .pipe(eslint({fix: true}))
        // eslint.format() outputs the lint results to the console.
        // Alternatively use eslint.formatEach() (see Docs).
        .pipe(eslint.format())
        // To have the process exit with an error code (1) on
        // lint error, return the stream and pipe to failAfterError last.
        .pipe(eslint.failAfterError())
        .pipe(gulpIf(isFixed, gulp.dest('./source/js/')));
});

//handles xqueries
gulp.task('xql', function(){
    gulp.src('./source/xql/**/*')
        .pipe(gulp.dest('./build/resources/xql/'));
    
    gulp.src('./source/xqm/**/*')
        .pipe(gulp.dest('./build/resources/xqm/'));
});

//handles xslt
gulp.task('xslt', function(){
    return gulp.src('./source/xql/**/*')
        .pipe(gulp.dest('./build/resources/xslt/'));
});

//handles data
gulp.task('data', function(){
    return gulp.src('./data/**/*')
        .pipe(gulp.dest('./build/content/'));
});

//bump version on patch level
gulp.task('bump-patch', function () {
    return gulp.src(['./package.json'])
        .pipe(bump({type: 'patch'}))
        .pipe(gulp.dest('./'));
});

//bump version on minor level
gulp.task('bump-minor', function () {
    return gulp.src(['./package.json'])
        .pipe(bump({type: 'minor'}))
        .pipe(gulp.dest('./'));
});

//bump version on major level
gulp.task('bump-major', function () {
    return gulp.src(['./package.json'])
        .pipe(bump({type: 'major'}))
        .pipe(gulp.dest('./'));
});

//set up basic xar structure
gulp.task('xar-structure', function() {
    gulp.src(['./source/eXist-db/**/*'])
        .pipe(replace('$$deployed$$', dateformat(Date.now(), 'isoUtcDateTime')))
        .pipe(replace('$$version$$', getPackageJsonVersion()))
        .pipe(replace('$$desc$$', packageJson.description))
        .pipe(replace('$$license$$', packageJson.license))
        .pipe(gulp.dest('./build/'));
    
});

//empty build folder
gulp.task('del', function() {
    return del(['./build/**/*','./dist/' + packageJson.name + '-' + getPackageJsonVersion() + '.xar']);
});

//reading from fs as this prevents caching problems    
function getPackageJsonVersion() {
    return JSON.parse(fs.readFileSync('./package.json', 'utf8')).version;
}

//creates a dist version
gulp.task('dist', ['xar-structure', 'html', 'css', 'js', 'xql', 'xslt', 'data','load-assets'], function() {
    gulp.src('./build/**/*')
        .pipe(zip(packageJson.name + '-' + getPackageJsonVersion() + '.xar'))
        .pipe(gulp.dest('./dist'));
        
    console.log('done building xar')
});

//creates a dist version with a version bump at patch level
gulp.task('dist-patch', ['bump-patch', 'dist']);

//creates a dist version with a version bump at minor level
gulp.task('dist-patch', ['bump-minor', 'dist']);

//creates a dist version with a version bump at major level
gulp.task('dist-patch', ['bump-major', 'dist']);


gulp.task('default', [ 'del', 'bump-patch', 'xar-structure', 'js' ]);