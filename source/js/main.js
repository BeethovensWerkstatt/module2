//const verovio = require('verovio-dev');
const vrvToolkit = new verovio.toolkit();

let page = 1;
let options;
let maxPage;

let pageHeight = 2970;
let pageWidth = 2100;

let colors = ['#eee3ce','#92908c','#623504','#26d6fc','#f4531b','#1b44f4','#859900','#d825da'];
let activeColor = 0;
let coloredNotes = {};

let paintMode = true;


function setListeners() {
    document.querySelectorAll('.modeBtn').forEach((item,index,list) => {
        item.addEventListener('click',(e) => {
            selectMode(item.id);
        })
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
        
        console.log('here?')
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
                measure = document.querySelector('#contentBox .measure').getAttribute('id');
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
        .then((comparisons) => {
            console.log(comparisons);
            
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
                    activateComparison(item.id);
                })
            })
        })
}

function activateComparison(id) {
    
    //console.log('activating ' + id)
    
    //unload old
    try {
        document.querySelector('.comparison.active').classList.remove('active');
        document.querySelector('#contentBox').html('');
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

function loadComparison(id,method) {

    if(typeof method === 'undefined') {
        method = document.querySelector('.modeBtn.active').id;
    }
    
    console.log('INFO: Requesting comparison ' + id + ' in mode ' + method);
    
    fetch('./resources/xql/getAnalysis.xql?comparisonId=' + id + '&method=' + method)
        .then((response) => {
            return response.text();
        })
        .catch(error => console.error('Error:', error))
        .then((mei) => {
            renderMEI(mei);
            loadPage(1);
        });
    
}

function loadPage(page) {

    removePageListeners();

    document.querySelector('#pageNum').value = page;
    
    let svg = vrvToolkit.renderToSVG(page, options);
    
    let box = document.createElement('div');
    box.classList.add('svgBox');
    box.innerHTML = svg;
    
    let contentBox = document.querySelector('#contentBox');
    
    contentBox.innerHTML = '';
    contentBox.appendChild(box);
    
    addPageListeners();
}

function removePageListeners() {
    
    let notes = document.querySelectorAll('#contentBox .note');
    notes.forEach((note,index,list) => {
        note.removeEventListener('click',clickNote,false);
    })
    
}

function addPageListeners() {
    
    if(!paintMode) {
        return false;
    }
    
    let notes = document.querySelectorAll('#contentBox .note');
    notes.forEach((note,index,list) => {
        note.addEventListener('click',clickNote,false);
        
    })
    
    //re-add colors
    
    for (let noteId in coloredNotes) {
        try {
            let note = document.querySelector('#contentBox #' + noteId);
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
    
}

function setOptions() {
    let zoom = 35;
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