# module2
This is a starting point for building (prototype) tools based on **eXist-db**, 
**NodeJS**, and **Gulp**. It compiles Ecmascript2015 (ES6) to regular Javascript, 
translates SASS to css, and works well with Docker. However, this is just a 
start for a development workflow, and may need to be adjusted for specific
use cases. 

#Requirements
* NodeJS (I'm using v6.11.3 right now)
* eXist-db (I'm using v3.4.1 right now)

#Installation
* fork or download from Git
* run ```npm install```
* copy *existConfig.tmpl.json* to *existConfig.json*
* adjust your configuration in that file. No worries, it will be ignored by Git.
* adjust *package.json*. All information for building the eXist app will be derived from there

#Gulp Tasks
* **watch** This task watches for changes to the source directories and uploads changes to a local eXist-db
* **dist** This task creates a xar package of the current state.
* **bump-patch** This task bumps the version number at patch level (according to semver)
* **bump-minor** This task bumps the version number at minor level (according to semver)
* **bump-major** This task bumps the version number at major level (according to semver)

Other tasks (called by the above tasks)
* **load-assets** loads assets like Verovio from node_modules and puts them in the right places 
* **html** loads HTML files. no templating mechanism included
* **css** compiles SASS to minified css
* **js** compiles ES6 to minified / uglified JS
* **xql** copies xql and xqm files into the right folders
* **xslt** copies xslt into the right folder
* **data** copies data into the right folder
* **xar-structure** builds the basic structure for the eXist-app
* **del** empties the /build and /dist folders
* **deploy** uploads the app to a local eXist database 

#Todos
* **lint** There is a gulp lint task, but it currently fails to autofix things. 