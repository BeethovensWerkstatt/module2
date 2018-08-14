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

let sunburstObject = {};

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
    
    let layoutOptionsModal = document.querySelector('#layoutOptionsModal');
    
    document.querySelector('#layoutOptionsOverlayClose2').addEventListener('click',(e) => {
        layoutOptionsModal.classList.remove('active');
    });
    
    document.querySelector('#layoutOptionsOverlayClose3').addEventListener('click',(e) => {
        layoutOptionsModal.classList.remove('active');
    });
    
    document.querySelector('#layoutOptionsOverlayClose1').addEventListener('click',(e) => {
        layoutOptionsModal.classList.remove('active');
    });
    
    document.querySelector('#layoutOptionsBtn').addEventListener('click',(e) => {
        layoutOptionsModal.classList.add('active');
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
    
    let transpositionSetting;
    
    let transpositionRadios = document.getElementsByName('transposition');
    for (let i=0; i < transpositionRadios.length; i++) {
        if(transpositionRadios[i].checked) {
            transpositionSetting = transpositionRadios[i].value;
            break;
        }
    }
    
    getFile(id,method,mdiv,transpositionSetting);
    
}

function getFile(comparisonId,method,mdiv, transpose) {
    activateLoading();
    fetch('./resources/xql/getAnalysis.xql?comparisonId=' + comparisonId + '&method=' + method + '&mdiv=' + mdiv + '&transpose=' + transpose)
        .then((response) => {
            return response.text();
        })
        .catch((error) => {
            console.error('Error loading comparison:', error);
            showLoadingError();
        })
        .then((mei) => {
            //todo: check if result is really ok…
            finishLoading();
            renderMEI(mei);
            loadPage(1);
        });
}

function loadPage(page) {
    
    removePageListeners();
    document.querySelector('#pageNum').value = page;
    let svg = vrvToolkit.renderToSVG(page, options);
    
    let svgContainer = document.querySelector('#svgContainer');
    svgContainer.innerHTML = '';
    
    let draw = SVG('svgContainer').size('100%', '100%');
    draw.clear();
    draw.svg(svg);
    
    addPageListeners();
}

function removePageListeners() {
    
    let notes = document.querySelectorAll('#svgContainer .note');
    notes.forEach((note,index,list) => {
        note.removeEventListener('click',clickNote,false);
    })
    
}

function addPageListeners() {
    
    let notes = document.querySelectorAll('#svgContainer .note, #svgContainer .rest');
    notes.forEach((note,index,list) => {
        note.addEventListener('click',clickNote,false);
        
    })
    
    if(paintMode) {
        
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
    } else {
        
        
        
    }
    
}

function clickNote(e) {
    
    let note = e.currentTarget;
    
    if(paintMode) {
        note.classList.add('color' + activeColor);
        note.style.fill = colors[activeColor];
        note.style.stroke = colors[activeColor];
        
        coloredNotes[note.id] = activeColor;       
    } else {
        console.log(note.classList)
        
        let idMatches = [... note.classList].filter(cl => cl.startsWith('id:'));
        let osMatches = [... note.classList].filter(cl => cl.startsWith('os:'));
        let sdMatches = [... note.classList].filter(cl => cl.startsWith('sd:'));
        let odMatches = [... note.classList].filter(cl => cl.startsWith('od:'));
        let tsMatches = [... note.classList].filter(cl => cl.startsWith('ts:'));
        
        idMatches.forEach(match => {
            let elem = SVG.get(match.substr(3));
            let childUse = elem.children()[0];
            
            childUse.animate(2000,'<').scale(3,3).after(situation => {
                childUse.animate(1500,'>').scale(1,1)
            })
        })
        
        osMatches.forEach(match => {
            let elem = SVG.get(match.substr(3));
            let childUse = elem.children()[0];
            
            childUse.animate(2000,'<').scale(2,2).after(situation => {
                childUse.animate(1500,'>').scale(1,1)
            })
        })
        
        sdMatches.forEach(match => {
            let elem = SVG.get(match.substr(3));
            let childUse = elem.children()[0];
            
            childUse.animate(2000,'<').scale(2,2).after(situation => {
                childUse.animate(1500,'>').scale(1,1)
            })
        })
        
        odMatches.forEach(match => {
            let elem = SVG.get(match.substr(3));
            let childUse = elem.children()[0];
            
            childUse.animate(2000,'<').scale(2,2).after(situation => {
                childUse.animate(1500,'>').scale(1,1)
            })
        })
        
        tsMatches.forEach(match => {
            let elem = SVG.get(match.substr(3));
            let childUse = elem.children()[0];
            
            childUse.animate(2000,'<').scale(2,2).after(situation => {
                childUse.animate(1500,'>').scale(1,1)
            })
        })
        
    }
    
    
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
    
    if(mode === 'comparison') {
        document.getElementById('varianceOptions').style.display = 'block';
    } else {
        document.getElementById('varianceOptions').style.display = 'none';
    }
};

function allowPainting(bool) {

    paintMode = bool;

    if(bool) {
        document.querySelector('.input-group.colorSwatches').style.display = 'block';
    } else {
        document.querySelector('.input-group.colorSwatches').style.display = 'none';
    }
    
}

function setupSunburst() {

    console.log('setupSunburst()')

    let width = 300;
    let height = 300;
    let radius = (Math.min(width, height) / 2) - 10;
    let centerRadius = 0.4 * radius;
    let backCircleRadius = 0.1 * radius;
    
    sunburstObject.width = width;
    sunburstObject.height = height;
    sunburstObject.radius = radius;
    sunburstObject.centerRadius = centerRadius;
    sunburstObject.backCircleRadius = backCircleRadius;
    
    let data = {
        "name": "A",
        "children": [
          { "name": "B", "value": 25 },
          {
            "name": "C",
            "children": [{ "name": "D", "value": 10 }, { "name": "E", "value": 15 }, { "name": "F", "value": 10 }]
          },
          { "name": "G", "value": 15 },
          {
            "name": "H",
            "children": [{ "name": "I", "value": 20 }, { "name": "J", "value": 10 }]
          },
          { "name": "K", "value": 10 }
        ]
      };
    
    sunburstObject.data = data;
    
    /*let formatNumber = d3.format(",d");
    
    let x = d3.scaleLinear()
        .range([0, 2 * Math.PI]);
    
    let y = d3.scaleSqrt()
        .range([0, radius]);
    
    let color = d3.scaleOrdinal.range(["#A07A19", "#AC30C0", "#EB9A72", "#BA86F5", "#EA22A8"]);*/
    //d3.scale.category20c();
    
    
    
    
    /*let partition = d3.partition()
        .value(function(d) { return d.size; });
    
    let arc = d3.svg.arc()
        .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
        .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
        .innerRadius(function(d) { return Math.max(0, y(d.y)); })
        .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });*/
    
    let svg = d3.select('#sunburst').append('svg')
        .attr('width', width)
        .attr('height', height);
        
    let g = svg.append('g')
        .attr('id','sunburstG')
        .attr('transform', 'translate(' + width / 2 + ',' + (height / 2) + ')');
     
    sunburstObject.g = g;   
    
    let colorScale = d3.scaleOrdinal().range([
        "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"
    ]);
    let xScale = d3.scaleLinear().range([0, 2 * Math.PI]);
    let rScale = d3.scaleLinear().range([0.4 * radius, radius]);
    
    sunburstObject.colorScale = colorScale;
    sunburstObject.xScale = xScale;
    sunburstObject.rScale = rScale;
    
    /*d3.json('flare.json', function(error, root) {
      if (error) throw error;
    
      svg.selectAll('path')
          .data(partition.nodes(root))
          .enter().append('path')
          .attr('d', arc)
          .style('fill', function(d) { return color((d.children ? d : d.parent).name); })
          .on('click', sunburstClick)
          .append('title')
          .text(function(d) { return d.name + '\n' + formatNumber(d.value); });
    });*/
    
    /*d3.select(self.frameElement).style('height', height + 'px');*/
    
    let root = d3.hierarchy(data);
    root.sum(function(d) { return d.value; })
        .sort(function(a, b) { return b.height - a.height || b.value - a.value; });
        
    let partition = d3.partition();
    partition(root);
    
    let arc = d3.arc()
        .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, xScale(d.x0))); })
        .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, xScale(d.x1))); })
        .innerRadius(function(d) { return Math.max(0, rScale(d.y0)); })
        .outerRadius(function(d) { return Math.max(0, rScale(d.y1)); });
    
    sunburstObject.arc = arc;
    
    g.selectAll("path")
        .data(root.descendants())
        .enter()
        .append("path")
        .attr("d", arc)
        .attr('stroke', '#fff')
        .attr("fill", function(d) {
          while(d.depth > 1) d = d.parent;
          if(d.depth == 0) return "lightgray";
          return colorScale(d.value);
        })
        .attr("opacity", 0.8)
        .on("click", sunburstClick)
        .append("title")
        .text(function(d) { return d.data.name + "\n" + d.value; });
     
      g.selectAll("text")
        .data(root.descendants())
        .enter()
        .append("text")
        .attr("fill", "black")
        .attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
        .attr("dy", "5px")
        .attr("font", "10px")
        .attr("text-anchor", "middle")
        .on("click", sunburstClick)
        .text(function(d) { return d.data.name; });
    
    console.log('finished setting up sunburst')
    
}

function sunburstClick(d) {
    
    console.log('starting sunburstClick')
    
    /*svg.transition()
        .duration(750)
        .tween('scale', function() {
            let xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]);
            let yd = d3.interpolate(y.domain(), [d.y, 1]);
            let yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
            
            return function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); };
        })
        .selectAll('path')
        .attrTween('d', function(d) { return function() { return arc(d); }; });*/
    var tween = sunburstObject.g.transition()
      .duration(500)
      .tween("scale", function() {
        var xdomain = d3.interpolate(sunburstObject.xScale.domain(), [d.x0, d.x1]);
        var ydomain = d3.interpolate(sunburstObject.rScale.domain(), [d.y0, 1]);
        var yrange = d3.interpolate(sunburstObject.rScale.range(), [d.y0 ? sunburstObject.backCircleRadius : sunburstObject.centerRadius, sunburstObject.radius]);
        return function(t) {
          sunburstObject.xScale.domain(xdomain(t));
          sunburstObject.rScale.domain(ydomain(t)).range(yrange(t));
        };
      });
 
    tween.selectAll("path")
      .attrTween("d", function(d) {
        return function() {
          return sunburstObject.arc(d);
        };
      });
 
    tween.selectAll("text")
      .attrTween("transform", function(d) {
        return function() {
          return "translate(" + sunburstObject.arc.centroid(d) + ")";
        };
      })
      .attrTween("opacity", function(d) {
        return function() {
          return(sunburstObject.xScale(d.x0) < 2 * Math.PI) && (sunburstObject.xScale(d.x1) > 0.0) && (sunburstObject.rScale(d.y1) > 0.0) ? 1.0 : 0;
        };
      })
      .attrTween("font", function(d) {
        return function() {
          return(sunburstObject.xScale(d.x0) < 2 * Math.PI) && (sunburstObject.xScale(d.x1) > 0.0) && (sunburstObject.rScale(d.y1) > 0.0) ? "10px" : 1e-6;
        };
      });
      
      console.log('finished sunburstClick')
}

console.log('1')
setupSunburst();
console.log('2')
setListeners();
prepareColors();
getComparisonListing();