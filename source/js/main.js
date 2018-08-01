//const verovio = require('verovio-dev');
const vrvToolkit = new verovio.toolkit();

let page = 1;
let options;
let maxPage;
let comparisons = [];

let zoom = 35;
let pageHeight = 2970;
let pageWidth = 2100;

let colors = ['#eee3ce','#92908c','#000000','#26d6fc','#f4531b','#1b44f4','#859900','#d825da'];
let activeColor = 0;
let coloredNotes = {};

let paintMode = true;

function activateLoading() {
    document.querySelector('#loadingIndicator').style.display = 'block';
    document.querySelector('#loadingError').style.display = 'none';
    document.querySelector('#firstTimeInstruction').style.display = 'none';
    document.querySelector('#svgContainer').style.display = 'none';
    
}

function finishLoading() {
    document.querySelector('#loadingIndicator').style.display = 'none';
    document.querySelector('#svgContainer').style.display = 'block';
}

function showLoadingError() {
    document.querySelector('#loadingError').style.display = 'none';
}

function setListeners() {
    document.querySelectorAll('.modeBtn').forEach((item,index,list) => {
        item.addEventListener('click',(e) => {
            selectMode(item.id);
        })
    });
    
    //key listeners
    document.addEventListener('keydown',(e) => {
        e = e || window.event;
        
        if (e.keyCode == '38') {
            // up arrow
        }
        else if (e.keyCode == '40') {
            // down arrow
        }
        else if (e.keyCode == '37') {
            // left arrow
            if(page === 1) {
               return false;
            } else {
               page--;
               loadPage(page);
            }
        }
        else if (e.keyCode == '39') {
            // right arrow
            if(page === maxPage) {
                return false;
            } else {
                page++;
                loadPage(page);
            }
        }
        
        else if (e.keyCode == '171') {
            // plus (+)
            if(zoom < 5 || zoom > 300) {
                return false;
            } else {
                zoom = zoom / 0.9;
                setOptions();
                loadPage(page);
            }
        }
        
        else if (e.keyCode == '173') {
            // minus (-)
            if(zoom < 5 || zoom > 300) {
                return false;
            } else {
                zoom = zoom * .9;
                setOptions();
                loadPage(page);
            }
        }
    });
    
    document.querySelector('#zoomOut').addEventListener('click',(e) => {
        if(zoom < 5 || zoom > 300) {
            return false;
        } else {
            zoom = zoom * .9;
            setOptions();
            loadPage(page);
        }
        console.log('clicked zoomOut, new zoom: ' + zoom)
    });
    
    document.querySelector('#zoomIn').addEventListener('click',(e) => {
        if(zoom < 5 || zoom > 300) {
            return false;
        } else {
            zoom = zoom / 0.9;
            setOptions();
            loadPage(page);
        }
        console.log('clicked zoomIn, new zoom: ' + zoom)
    });
    
    document.querySelector('#prevPage').addEventListener('click',(e) => {
        if(page === 1) {
            return false;
        } else {
            page--;
            loadPage(page);
        }
    });
    
    document.querySelector('#nextPage').addEventListener('click',(e) => {
        if(page === maxPage) {
            return false;
        } else {
            page++;
            loadPage(page);
        }
    });
    
    let infoModal = document.querySelector('#infoModal');
    
    document.querySelector('#modalCloseTop').addEventListener('click',(e) => {
        infoModal.classList.remove('active');
    });
    
    document.querySelector('#modalCloseBottom').addEventListener('click',(e) => {
        infoModal.classList.remove('active');
    });
    
    document.querySelector('#modalOverlay').addEventListener('click',(e) => {
        infoModal.classList.remove('active');
    });
    
    document.querySelector('#openModalBtn').addEventListener('click',(e) => {
        infoModal.classList.add('active');
    });
    
    window.addEventListener('resize', (e) => { 
        try {
            // make sure we have loaded a file
            if(vrvToolkit.getPageCount() == 0) {
                return false;  
            }
            
            setOptions();
            
            let measure = 0;
            if (page != 1) {
                measure = document.querySelector('#svgContainer .measure').getAttribute('id');
            }
    
            vrvToolkit.redoLayout();
    
            page = 1;
            if (measure != 0) {
                page = vrvToolkit.getPageWithElement(measure);
            }
            loadPage(page);
            
            console.log('layout redone')
        } catch(err) {
            console.log('ERROR: Unable to redo Verovio layout: ' + err);
        }
    });
    
}

function prepareColors() {
    let swatches = document.querySelectorAll('.colorSwatch');
    swatches.forEach((swatch,index,list) => {
        
        let color = colors[index];
    
        swatch.style.backgroundColor = color;
        
        let r = parseInt(color.substr(1,2),16);
        let g = parseInt(color.substr(3,2),16);
        let b = parseInt(color.substr(5,2),16);
        let yiq = ((r*299)+(g*587)+(b*114))/1000;
        let contrastClass = (yiq >= 128) ? 'contrastBlack' : 'contrastWhite';
        
        swatch.classList.add(contrastClass);
        
        swatch.addEventListener('click',(e) => {
            activateColor(swatch,index);
        })
    })
}

function activateColor(swatch,index) {
    let oldSwatch = document.querySelector('.colorSwatch.active');
    oldSwatch.classList.remove('active');
    swatch.classList.add('active');
    activeColor = index;
}

function getComparisonListing() {
    fetch('./resources/xql/getComparisonListing.xql')
        .then((response) => {
            return response.json();
        })
        .catch(error => console.error('Error:', error))
        .then((loadedComparisons) => {
            
            comparisons = loadedComparisons;
            
            for(let i=0;i<comparisons.length;i++) {
                
                let comparison = comparisons[i];
                let li = document.createElement('li');
                li.id = comparison.id;
                li.classList.add('comparison')
                li.innerHTML = comparison.title;
                
                document.querySelector('#comparisonsList').append(li)
            }
            
            document.querySelectorAll('#comparisonsList li').forEach((item,index,list) => {
                item.addEventListener('click',(e) => {
                    activateComparison(item.id,comparisons[index]);
                })
            })
        })
}

function activateComparison(id,comparison) {
    
    //console.log('activating ' + id)
    
    //unload old
    try {
        document.querySelector('.comparison.active').classList.remove('active');
        document.querySelector('#svgContainer').innerHTML = '';
    } catch(err) {
        //console.log('ERROR: Unable to deactivate current comparison (' + err + ')');
    }
    
    //load new
    try {
        document.querySelector('#' + id).classList.add('active');
        loadComparison(id);
        
        //reset coloration
        coloredNotes = {};
        
    } catch(err) {
        console.log('ERROR: Unable to activate comparison with ID ' + id + ' (' + err + ')');
    }
    
}

function loadComparison(id,method,mdiv) {

    if(typeof method === 'undefined') {
        method = document.querySelector('.modeBtn.active').id;
    }
    
    if(typeof mdiv === 'undefined') {
        mdiv = '1';
    }
    
    let comparison = comparisons.find((obj) => {
        return obj.id === id;
    });
    
    let mdivSelector = document.getElementById('movements');
    mdivSelector.innerHTML = '';
    
    if(comparison.movements.length > 1) {
        document.getElementById('movementsBox').style.display = 'block';
        for(let i=0; i<comparison.movements.length; i++) {
            let mdiv = comparison.movements[i];
            let option = document.createElement('option');
            option.id = comparison.id + '_mdiv' + mdiv.n;
            option.classList.add('mdiv')
            option.innerHTML = mdiv.label;
            
            mdivSelector.append(option)
        }
        
        mdivSelector.addEventListener('change',(e) => {
            let index = mdivSelector.selectedIndex;
            
            let mdivN = comparison.movements[index].n;
            
            document.querySelector('#svgContainer').innerHTML = '';
            getFile(id,method,mdivN);
        });
        
        /*document.querySelectorAll('#movements option').forEach((item,index,list) => {
            item.addEventListener('click',(e) => {
                activateComparison(item.id,comparison,comparison.movements[index].n);
            })
        })*/
    } else {
        document.getElementById('movementsBox').style.display = 'none';
    }
    
    getFile(id,method,mdiv);
    
}

function getFile(comparisonId,method,mdiv) {
    activateLoading();
    fetch('./resources/xql/getAnalysis.xql?comparisonId=' + comparisonId + '&method=' + method + '&mdiv=' + mdiv)
        .then((response) => {
            return response.text();
            console.log(1)
        })
        .catch((error) => {
            console.error('Error loading comparison:', error);
            showLoadingError();
        })
        .then((mei) => {
            console.log(2)
            finishLoading();
            console.log(3)
            renderMEI(mei);
            console.log(4)
            loadPage(1);
            console.log(5)
        });
}

function loadPage(page) {

    removePageListeners();
    
    document.querySelector('#pageNum').value = page;
    
    let svg = vrvToolkit.renderToSVG(page, options);
    
    let box = document.createElement('div');
    box.classList.add('svgBox');
    box.innerHTML = svg;
    
    let svgContainer = document.querySelector('#svgContainer');
    svgContainer.innerHTML = '';
    svgContainer.appendChild(box);
    
    addPageListeners();
}

function removePageListeners() {
    
    let notes = document.querySelectorAll('#svgContainer .note');
    notes.forEach((note,index,list) => {
        note.removeEventListener('click',clickNote,false);
    })
    
}

function addPageListeners() {
    
    if(!paintMode) {
        return false;
    }
    
    let notes = document.querySelectorAll('#svgContainer .note, #svgContainer .rest');
    notes.forEach((note,index,list) => {
        note.addEventListener('click',clickNote,false);
        
    })
    
    //re-add colors
    
    for (let noteId in coloredNotes) {
        try {
            let note = document.querySelector('#svgContainer #' + noteId);
            let colorIndex = coloredNotes[noteId];
            
            note.classList.add('color' + colorIndex);
            note.style.fill = colors[colorIndex];
            note.style.stroke = colors[colorIndex];
            
        } catch(err) {
            //console.log('[ERROR] Unable to (re-)color note ' + noteId + ': ' + err);
        }
    }
    
}

function clickNote(e) {
    
    let note = e.currentTarget;
    
    note.classList.add('color' + activeColor);
    note.style.fill = colors[activeColor];
    note.style.stroke = colors[activeColor];
    
    coloredNotes[note.id] = activeColor;
    
    let showBox = document.querySelector('#noteID');
    showBox.innerHTML = 'Item clicked:<br/>' + note.id;
    
}

function setOptions() {
    let he = document.getElementById('contentBox')["clientHeight"];
    let wi = document.getElementById('contentBox')["clientWidth"];
    
    options = {
      	scale: zoom,
      	
      	//ignoreLayout: 0,
      	//noLayout: 1,
      	
      	noFooter: 1, // takes out the "rendered by Verovio" footer
      	
      	pageWidth: (wi - 20) * 100/ zoom,
      	pageHeight: (he - 20) * 100 / zoom,
      	adjustPageHeight: true,
      	
      	spacingNonLinear: 1,
      	spacingLinear: .05
      };
    
    vrvToolkit.setOptions(options);
}

/*
 * this function renders an MEI file into SVG and inserts it in a given HTML element
 */
function renderMEI(mei) {
    
    //var svg = vrvToolkit.renderData(mei + '\n', options);
    vrvToolkit.loadData(mei + '\n');
    setOptions();
    maxPage = vrvToolkit.getPageCount();
};

function selectMode(mode) {
    
    var oldActive = document.querySelector('.modeBtn.active');
    if(oldActive.id === mode) {
        console.log('INFO: Mode ' + mode + ' is already active')
        return false;
    }
    
    oldActive.classList.remove('active');
    document.querySelector('.modeBtn#' + mode).classList.add('active');
    
    try {
        let comparison = document.querySelector('.comparison.active');
        
        if(comparison !== null) {
            loadComparison(comparison.id,mode);    
        }
        
        
    } catch(err) {
        console.log('ERROR: Unable to load comparison with mode ' + mode + ': ' + err)
    }
    
    allowPainting(mode === 'plain');
};

function allowPainting(bool) {

    paintMode = bool;

    if(bool) {
        document.querySelector('.input-group.colorSwatches').classList.remove('inactive');
    } else {
        document.querySelector('.input-group.colorSwatches').classList.add('inactive');
    }
    
}

setListeners();
prepareColors();
getComparisonListing();