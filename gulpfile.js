var gulp = require('gulp');
var zip = require('gulp-zip');
var sass = require('gulp-sass');
var concat = require('gulp-concat');
var replace = require('gulp-replace');
var newer = require('gulp-newer');
var dateformat = require('dateformat');
var del = require('del');
var packageJson = require('./package.json');
var bump = require('gulp-bump');
var fs = require('fs');
var browserify = require('browserify');
var babel = require('gulp-babel');
var uglify = require('gulp-uglify');
var eslint = require('gulp-eslint');
var exist = require('gulp-exist');
var existConfig = require('./existConfig.json');
var existClient = exist.createClient(existConfig);
var git = require('git-rev-sync');


/** 
 *  This task loads custom assets, installed via npm, by copying 
 *  them to the corresponding folders in the build directory.
 */
gulp.task('load-assets', function() {
    //include verovio dev    
    gulp.src(['./node_modules/verovio-dev/index.js'])
        .pipe(concat('verovio-toolkit-dev.js'))
        .pipe(newer('./build/resources/js/'))
        .pipe(gulp.dest('./build/resources/js/'));
        
    //include spectre.css
    gulp.src(['./node_modules/spectre.css/dist/**/*.min.css'])
        .pipe(gulp.dest('./build/resources/css/'))
});

//handles html
gulp.task('html', function(){
    
    var git = getGitInfo();
    
    return gulp.src('./source/html/**/*')
        //.pipe(newer('./build/'))
        .pipe(replace('$$git-url$$', git.url))
        .pipe(replace('$$git-short$$', git.short))
        .pipe(replace('$$git-dirty$$', git.dirty))
        .pipe(gulp.dest('./build/'));
});

//deploys html to exist-db
gulp.task('deploy-html',['html'], function() {
    gulp.src('**/*.html', {cwd: './build/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/'}));
})

//watches html for changes
gulp.task('watch-html',function() {
    gulp.watch('source/html/**/*', ['deploy-html']);
})

//compiles scss to css
gulp.task('css', function(){
    return gulp.src('./source/sass/main.scss')
        .pipe(sass({outputStyle: 'compressed'}).on('error', sass.logError))
        .pipe(gulp.dest('./build/resources/css'));
});

//deploys css to exist-db
gulp.task('deploy-css',['css'], function() {
    gulp.src('**/*', {cwd: './build/resources/css/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/resources/css/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/resources/css/'}));
})

//watches css for changes
gulp.task('watch-css',function() {
    gulp.watch('source/sass/**/*', ['deploy-css']);
})

//handles javascript
gulp.task('js', function(){
    
    //compile javascript
    gulp.src(['./source/js/main.js'])
        .pipe(babel())
        .pipe(concat('main.min.js'))
        .pipe(uglify())
        .pipe(gulp.dest('./build/resources/js/'));
});

//deploys js to exist-db
gulp.task('deploy-js',['js'], function() {
    gulp.src('**/*', {cwd: 'build/resources/js/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/resources/js/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/resources/js/'}));
})

//watches js for changes
gulp.task('watch-js',function() {
    gulp.watch('source/js/**/*', ['deploy-js']);
})

function isFixed(file) {
    // Has ESLint fixed the file contents?
    return file.eslint != null && file.eslint.fixed;
}

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
    gulp.src('source/xql/**/*')
        .pipe(newer('build/resources/xql/'))
        .pipe(gulp.dest('build/resources/xql/'));
    
    gulp.src('source/xqm/**/*')
        .pipe(newer('build/resources/xqm/'))
        .pipe(gulp.dest('build/resources/xqm/'));
});

//deploys xql to exist-db
gulp.task('deploy-xql',['xql'], function() {
    gulp.src(['**/*'], {cwd: 'build/resources/xql/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/resources/xql/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/resources/xql/'}));
        
    gulp.src(['**/*'], {cwd: 'build/resources/xqm/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/resources/xqm/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/resources/xqm/'}));
})

//watches xql for changes
gulp.task('watch-xql',function() {
    gulp.watch(['source/xql/**/*','source/xqm/**/*'], ['deploy-xql']);
})

//handles xslt
gulp.task('xslt', function(){
    return gulp.src('./source/xslt/**/*')
        .pipe(newer('./build/resources/xslt/'))
        .pipe(gulp.dest('./build/resources/xslt/'));
});

//deploys xslt to exist-db
gulp.task('deploy-xslt',['xslt'], function() {
    gulp.src('**/*', {cwd: './build/resources/xslt/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/resources/xslt/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/resources/xslt/'}));
})

//watches xslt for changes
gulp.task('watch-xslt',function() {
    gulp.watch('source/xslt/**/*', ['deploy-xslt']);
})

//handles pix
gulp.task('pix', function(){
    return gulp.src('source/pix/**/*')
        .pipe(newer('build/resources/pix/'))
        .pipe(gulp.dest('./build/resources/pix/'));
});

//deploys pix to exist-db
gulp.task('deploy-pix',['pix'], function() {
    gulp.src('**/*', {cwd: 'build/resources/pix/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/resources/pix/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/resources/pix/'}));
})

//watches pix for changes
gulp.task('watch-pix',function() {
    gulp.watch('source/pix/**/*', ['deploy-pix']);
})

//handles data
gulp.task('data', function(){
    return gulp.src('./data/**/*')
        .pipe(newer('./build/content/'))
        .pipe(gulp.dest('./build/content/'));
});

//deploys data to exist-db
gulp.task('deploy-data',['data'], function() {
    gulp.src('**/*', {cwd: 'build/content/'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/content/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/content/'}));
})

//watches xslt for changes
gulp.task('watch-data',function() {
    gulp.watch('data/**/*', ['deploy-data']);
})

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

gulp.task('git-info',function() {
    console.log('Git Information: ')
    console.log(git.short());
    console.log(git.remoteUrl());
    console.log(git.isDirty());
    console.log('link is https://github.com/BeethovensWerkstatt/module2/commit/' + git.short());
});

function getGitInfo() {
    return {short: git.short(),
            url: 'https://github.com/BeethovensWerkstatt/module2/commit/' + git.short(),
            dirty: git.isDirty()}
}

 
/**
 * deploys the current build folder into a (local) exist database
 */
gulp.task('deploy', function() {
    return gulp.src('**/*', {cwd: 'build'})
        .pipe(existClient.newer({target: "/db/apps/bw-module2/"}))
        .pipe(existClient.dest({target: '/db/apps/bw-module2/'}));
})

gulp.task('watch', ['watch-html', 'watch-css', 'watch-js','watch-xql','watch-xslt','watch-data','watch-pix']);


//creates a dist version
gulp.task('dist', ['xar-structure', 'html', 'css', 'js', 'xql', 'xslt', 'data','pix','load-assets'], function() {
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


gulp.task('default', function() {
    console.log('')
    console.log('INFO: There is no default task, please run one of the following tasks:');
    console.log('');
    console.log('  "gulp dist"       : creates a xar from the current sources');
    console.log('  "gulp bump-patch" : bumps the semver version of this package at patch level');
    console.log('  "gulp bump-minor" : bumps the semver version of this package at minor level');
    console.log('  "gulp bump-major" : bumps the semver version of this package at major level');
    console.log('');
});