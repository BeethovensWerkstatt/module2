//const verovio = require('verovio-dev');
const vrvToolkit = new verovio.toolkit();

let page = 1;
let options;
let maxPage;

let pageHeight = 2970;
let pageWidth = 2100;

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
    document.querySelector('#pageNum').value = page;
    
    let svg = vrvToolkit.renderToSVG(page, options);
    
    let box = document.createElement('div');
    box.classList.add('svgBox');
    box.innerHTML = svg;
    
    let contentBox = document.querySelector('#contentBox');
    
    contentBox.innerHTML = '';
    contentBox.appendChild(box);
}

function setOptions() {
    let zoom = 35;
    let he = document.getElementById('contentBox')["clientHeight"];
    let wi = document.getElementById('contentBox')["clientWidth"];
    
    options = {
      	scale: zoom,
      	
      	//ignoreLayout: 0,
      	//noLayout: 1,
      	
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
    maxPage = vrvToolkit.getPageCount();
};

setListeners();
getComparisonListing();