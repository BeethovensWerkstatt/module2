const verovio = require('../../node_modules/verovio-dev/index.js').init(256);
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

//set MEI namespace
d3.namespaces.mei = 'http://www.music-encoding.org/ns/mei';

function activateLoading() {
    document.querySelector('#loadingIndicator').style.display = 'block';
    document.querySelector('#loadingError').style.display = 'none';
    document.querySelector('#firstTimeInstruction').style.display = 'none';
    document.querySelector('#svgContainer').style.display = 'none';
    
    sunburstRemoveData();
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
    });
    
    document.querySelector('#zoomIn').addEventListener('click',(e) => {
        if(zoom < 5 || zoom > 300) {
            return false;
        } else {
            zoom = zoom / 0.9;
            setOptions();
            loadPage(page);
        }
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
                
                let titleSpan = document.createElement('span');
                titleSpan.classList.add('originalVersion');
                titleSpan.innerHTML = comparison.title;
                
                let targetSpan = document.createElement('span');
                targetSpan.classList.add('targetVersion');
                targetSpan.innerHTML = comparison.target;
                
                li.append(titleSpan);
                li.append(targetSpan);
                
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
        .then((data) => {
            //todo: check if result is really ok…
            
            finishLoading();
            
            if(method !== 'melodicComparison') {
                renderMEI(data);
                loadPage(1);
                sunburstLoadData(data,method);
            } else {
                displayMelodicComparison(data);
            }
            
            
            
        });
}

function displayMelodicComparison(rawData) {
    
    console.log('displayMelodicComparison 1')
    
    let xmlParser = new DOMParser();
    let xmlDOM = xmlParser.parseFromString(rawData, 'application/xml');
    
    let xmlData = xmlDOM.documentElement;
    
    let duration = 0;
    let minPitch = 120;
    let maxPitch = 0;
    
    let data = {
            variants: [].map.call(xmlData.querySelectorAll('file'), function(file) {
                return {
                    id: file.getAttribute('xml:id'),
                    label: file.getAttribute('label'),
                    n: file.getAttribute('n'),
                    staves: [].map.call(file.querySelectorAll('staff'), function(staff) {
                        return {
                            n: staff.getAttribute('n'),
                            label: staff.getAttribute('label'),
                            events: [].map.call(staff.querySelectorAll('event'), function(event) {
                            
                                let start = event.getAttribute('start');
                                let end = event.getAttribute('end');
                                let pnum = event.getAttribute('pnum');
                                
                                if(!isNaN(end)) {
                                    duration = Math.max(duration,end);
                                }
                                
                                if(!isNaN(pnum) && pnum !== '' && pnum > 22) {
                                    minPitch = Math.min(minPitch,pnum);
                                    maxPitch = Math.max(maxPitch,pnum); 
                                }
                                
                                return {
                                    start,
                                    end,
                                    pnum,
                                    id: event.getAttribute('id') 
                                };
                            })
                        };
                    }),
                    measures: [].map.call(file.querySelectorAll('measure'), function(measure) {
                        return {
                            id: measure.getAttribute('id'),
                            start: measure.getAttribute('start'),
                            n: measure.getAttribute('n')
                        }
                    })
                }
            })
            
        };
    
    console.log(data)
    console.log('duration: ' + duration)
    console.log('minPitch: ' + minPitch)
    console.log('maxPitch: ' + maxPitch)
    
    console.log('displayMelodicComparison 2')
    
    let margin = {top: 40, right: 40, bottom: 40, left: 40};
    let width = duration * 100;
    let height = 550 - margin.top - margin.bottom;
    
    let x = d3.scaleLinear()
        .domain([0,duration])
        .range([0, width]);
    
    let y = d3.scaleLinear()
        .domain([minPitch - 12,maxPitch + 12])
        .range([height, 0]);
    
    console.log('displayMelodicComparison 3')
    
    let xTicks =  [];
    data.variants[0].measures.forEach((measure,i) => {xTicks.push(parseFloat(measure.start))});
    
    let xAxis = d3.axisTop(x)
                   .tickValues(xTicks)
                   .tickFormat((d, i) => {
                       return data.variants[0].measures[i].n;
                   });
    let yAxis = d3.axisLeft(y)
                   .tickValues([24, 36, 48, 60, 72, 84, 96])
                   .tickFormat(function(d, i) {
                       return 'C' + (d / 12 - 1);
                   });
    
    console.log('displayMelodicComparison 4')
    
    
    let svgContainer = document.querySelector('#svgContainer');
    svgContainer.innerHTML = '';
    
    let svg = d3.select("#svgContainer").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
    
    svg.append("g")
        //.attr('transform', 'translate(0,' + height + ')')
        .call(xAxis);

    svg.append("g")
        .call(yAxis);
       
    console.log('displayMelodicComparison 5')
    
    let line = d3.line()
        //.defined(function(d) { return d; })
        .x(function(d) { return x(d.x); })
        .y(function(d) { return y(d.y); })
        //.curve(d3.curveStepAfter)
        
    console.log('displayMelodicComparison 6')
    
    drawBarlines(svg,line,data.variants[0].measures,minPitch,maxPitch);
    drawStaffLines(svg,line,duration);
    
    console.log('displayMelodicComparison 7')
    
    //tondauern:
    //drawIndividualLines(svg,line,duration,data)
    
    //durchgängige Linien:
    //drawConnectedLines(svg,line,duration,data,x,y)
    
    //Konturlinien:
    drawSemiConnectedLines(svg,line,duration,data,x,y)
    
    //Punkte:
    drawDots(svg,data,x,y);
    
    console.log('displayMelodicComparison 8')
       /*let lineGraph = svg.append("path")
            .datum(activeSet.events)
            .attr("d", line)
            .attr("stroke", "blue")
            .attr("stroke-width", 2)
            .attr("fill", "none");*/
        
    
    
    //draw lines
    
    
    /*for(let i=0;i<activeSet.events.length;i++) {
        let event = activeSet.events[i];
        let path = svg.append("path").datum(chartObj.data).attr("class", "line").attr("d", yObjs[y].line).style("stroke", color(y)).attr("data-series", y).on("mouseover", function () {
    }*/
    
    /*for (let event in activeSet.events) {
        activeSet.events[event].path = svg.append("path").datum(chartObj.data).attr("class", "line").attr("d", yObjs[y].line).style("stroke", color(y)).attr("data-series", y).on("mouseover", function () {
            focus.style("display", null);
        }).on("mouseout", function () {
            focus.transition().delay(700).style("display", "none");
        }).on("mousemove", mousemove);
    }*/
    
    
    /*let svg = d3.select('#sunburst').append('svg')
        .attr('width', width)
        .attr('height', height);
        
    let g = svg.append('g')
        .attr('id','sunburstG')
        .attr('transform', 'translate(' + width / 2 + ',' + (height / 2) + ')');
    
    sunburstObject.svg = svg;
    sunburstObject.g = g;   
    
    let colorScale = d3.scaleOrdinal().range([
        '#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf'
    ]);
    let xScale = d3.scaleLinear().range([0, 2 * Math.PI]);
    let rScale = d3.scaleLinear().range([0.4 * radius, radius]);
    
    sunburstObject.colorScale = colorScale;
    sunburstObject.xScale = xScale;
    sunburstObject.rScale = rScale;
    
    let arc = d3.arc()
        .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, xScale(d.x0))); })
        .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, xScale(d.x1))); })
        .innerRadius(function(d) { return Math.max(0, rScale(d.y0)); })
        .outerRadius(function(d) { return Math.max(0, rScale(d.y1)); });
    
    sunburstObject.arc = arc;*/
    
    
}

function drawBarlines(svg,line,measures,minPitch,maxPitch) {
    for(let i=0;i<measures.length;i++) {
        let measure = [{x:measures[i].start,y:minPitch - 12},{x:measures[i].start,y:maxPitch + 12}];
        
        svg.append("path")
            .datum(measure)
            .attr("d", line)
            .attr("class","melodicContourBarline")
    }
}

function drawStaffLines(svg,line,duration) {
    
    //these are the "pitches" or regular staff lines, i.e. E4,G4,B4,D5,F5 - A3,F3,D3,B2,G2
    //let staffLines = [64,67,71,74,77,57,53,50,47,43];
    let staffLines = [24,26,28,29,31,33,35,36,38,40,41,43,45,47,48,50,52,53,55,57,59,60,62,64,65,67,69,71,72,74,76,77,79,81,83,84,86,88,89,91,93,95,96];
    
    for(let i=0;i<staffLines.length;i++) {
        let staffLine = [{x:0,y:staffLines[i]},{x:duration,y:staffLines[i]}];
        
        svg.append("path")
            .datum(staffLine)
            .attr("d", line)
            .attr("class",(staffLines[i] % 12 === 0) ? "melodicContourStaffLine cline":"melodicContourStaffLine")
    }
}

function drawDots(svg,data,x,y) {
    
    console.log('\ndrawDots start')
    
    let variant1 = data.variants[0];
    let variant2 = data.variants[1];
    
    for(let i=0;i<variant1.staves.length;i++) {
        let currentStaff = variant1.staves[i];
        
        for(let j=0;j<currentStaff.events.length;j++) {
            let note = currentStaff.events[j];
            if(note.pnum !== '') {
                svg.append("circle")
                    .attr("class", "melodicContourNote variant1 dot") // Assign a class for styling
                    .attr("cx", function(d) { return x(note.start) })
                    .attr("cy", function(d) { return y(note.pnum/*((note.pnum % 12) + 60)*/) })
                    .attr("r", 2)
                    .attr("data-id",note.id)
                    .on("click",(d,n) => {
                        let showBox = document.querySelector('#noteID');
                        showBox.innerHTML = 'Item clicked:<br/>' + note.id;
                    })
                    .on("mouseover",(d,n) => {
                    
                        try {
                            d3.select('#noteHalo').remove();
                        } catch(err) {
                            
                        }    
                    
                        svg.append("circle")
                            .attr("id",'noteHalo')
                            .attr("class", "melodicContourNote variant1 dot-halo") // Assign a class for styling
                            .attr("cx", function(d) { return x(note.start) })
                            .attr("cy", function(d) { return y(note.pnum/*((note.pnum % 12) + 60)*/) })
                            .attr("r", 5)
                            /*.on("mouseout",() => {
                                try {
                                    d3.select('#noteHalo').remove();
                                } catch(err) {
                                    
                                }    
                            })*/
                    })
                    .append('svg:title')
                    .text((d, j) => {return 'Variant 1\nPnum ' + (note.pnum) + '\nID ' + note.id})
                    
            }
        }
    }
    
    for(let i=0;i<variant2.staves.length;i++) {
        let currentStaff = variant2.staves[i];
        
        for(let j=0;j<currentStaff.events.length;j++) {
            let note = currentStaff.events[j];
            
            if(note.pnum !== '') {
                svg.append("circle")
                    .attr("class", "melodicContourNote variant2 dot") // Assign a class for styling
                    .attr("cx", function(d) { return x(note.start) })
                    .attr("cy", function(d) { return y(note.pnum/*((note.pnum % 12) + 60)*/) })
                    .attr("r", 1)
                    .attr("data-id",note.id)
                    .on("click",(d,n) => {
                        let showBox = document.querySelector('#noteID');
                        showBox.innerHTML = 'Item clicked:<br/>' + note.id;
                    })
                    .on("mouseover",(d,n) => {
                    
                        try {
                            d3.select('#noteHalo').remove();
                        } catch(err) {
                            
                        }    
                    
                        svg.append("circle")
                            .attr("id",'noteHalo')
                            .attr("class", "melodicContourNote variant2 dot-halo") // Assign a class for styling
                            .attr("cx", function(d) { return x(note.start) })
                            .attr("cy", function(d) { return y(note.pnum/*((note.pnum % 12) + 60)*/) })
                            .attr("r", 5)
                            /*.on("mouseout",() => {
                                try {
                                    d3.select('#noteHalo').remove();
                                } catch(err) {
                                    
                                }    
                            })*/
                    })
                    .append('svg:title')
                    .text((d, j) => {return 'Variant 2\nPnum ' + (note.pnum) + '\nID ' + note.id})
            }
            
        }
    }
    console.log('drawDots end')
}

function drawIndividualLines(svg,line,duration,data) {
    
    console.log('\ndrawIndividualLines')
    
    let variant1 = data.variants[0];
    let variant2 = data.variants[1];
    
    for(let i=0;i<variant1.staves.length;i++) {
        let currentStaff = variant1.staves[i];
        
        for(let j=0;j<currentStaff.events.length;j++) {
            let note = currentStaff.events[j];
            
            if(note.pnum !== '') {
                let noteData = [{x:note.start,y:note.pnum,id:note.id},{x:note.end,y:note.pnum,id:note.id}];
                svg.append("path")
                    .datum(noteData)
                    .attr("class","melodicContourNote variant1")
                    .attr("d", line)
            }
            
        }
        
    }
    
    for(let i=0;i<variant2.staves.length;i++) {
        let currentStaff = variant2.staves[i];
        
        for(let j=0;j<currentStaff.events.length;j++) {
            let note = currentStaff.events[j];
            
            if(note.pnum !== '') {
                let noteData = [{x:note.start,y:note.pnum,id:note.id},{x:note.end,y:note.pnum,id:note.id}];
                svg.append("path")
                    .datum(noteData)
                    .attr("class","melodicContourNote variant2")
                    .attr("d", line)
            }
            
        }
        
    }
    
    console.log('\drawIndividualLines done')
    
}

function drawConnectedLines(svg,line,duration,data,x,y) {
    
    console.log('\ndrawConnectedLines')
    
    line = d3.line()
        .defined(function(d) { return d.pnum !==''; })
        .x(function(d) { return x(d.start); })
        .y(function(d) { return y(d.pnum); })
        .curve(d3.curveStepAfter)
    
    let variant1 = data.variants[0];
    let variant2 = data.variants[1];
    
    for(let i=0;i<variant1.staves.length;i++) {
        let currentStaff = variant1.staves[i];
        
        svg.append("path")
            .datum(currentStaff.events)
            .attr("class","melodicContourNote variant1")
            .attr("d", line)
    }
    
    for(let i=0;i<variant2.staves.length;i++) {
        let currentStaff = variant1.staves[i];
        
        svg.append("path")
            .datum(currentStaff.events)
            .attr("class","melodicContourNote variant2")
            .attr("d", line)
    }
    
    console.log('\drawConnectedLines done')
    
}

function drawSemiConnectedLines(svg,line,duration,data,x,y) {
    
    console.log('\ndrawSemiConnectedLines')
    
    line = d3.line()
        .defined(function(d) { return d.pnum !==''; })
        .x(function(d) { return x(d.start); })
        .y(function(d) { return y(d.pnum/*((d.pnum % 12) + 60)*/); })
        //.curve(d3.curveStepAfter)
        
        //geschwungene Linie:
        //.curve(d3.curveCatmullRom)
        
        //gerade Linien:
        .curve(d3.curveLinear)
    
    let variant1 = data.variants[0];
    let variant2 = data.variants[1];
    
    let dragstarted = (d) => {
        //console.log('me here starting to drag?')
        d3.select(this).raise().classed("active", true);
    }

    let dragged = (d,e,f) => {
        /*console.log('me dragging?')
        console.log(d);
        console.log(d3.event)
        console.log('e und f:')
        console.log(e)
        console.log(f)*/
        
        let firstLine = f[0];
        let firstLineD3 = d3.select(firstLine);
        
        /*console.log(firstLine)
        console.log(firstLineD3.attr)
        console.log('type: ' + typeof firstLineD3.attr('style'))
        console.log(firstLineD3.attr('transform'))*/
        
        let oldTrans = (firstLineD3.attr('style') === null) ? 0 : parseInt(firstLineD3.attr('style').match(/\d+/));
        let newTrans = oldTrans +  + parseInt(d3.event.dy);
        
        //console.log('moving from ' + oldTrans + ' to ' + newTrans)
        
        f.forEach((line) => {
            //console.log(line);
            
            d3.select(line).attr('style','transform: translateY(' + newTrans + 'px);');
            
        })
        
        //d3.select(this).attr('transform','translateY(10px)');
        //d3.select(this).attr("cx", d.x = d3.event.x).attr("cy", d.y = d3.event.y);
    }

    let dragended = (d,e,f) => {
        console.log('me no dragging anymore?')
        f.forEach((line) => {
            //console.log(line);
            
            d3.select(line).attr('style','transform: translateY(0);');
            
        })
    }
    
    for(let i=0;i<variant1.staves.length;i++) {
        let currentStaff = variant1.staves[i];
        
        console.log('\nVariant 1, staff ' + i);
        console.log(currentStaff)
        
        svg.append("path")
            .datum(currentStaff.events)
            .attr("class","melodicContourNote variant1")
            .attr("d", line)
            .on('mouseover',function(d,unknown,pathArray) {
                pathArray[0].classList.add('hovering');
                d3.select(pathArray[1]).raise();
            })
            .on('mouseout',function(d,unknown,pathArray) {
                pathArray[0].classList.remove('hovering');
            })
            .append('svg:title')
            .text((d, j) => {return 'Variant 1\nStaff ' + (i + 1) + ((currentStaff.label !== '')? '\n' + currentStaff.label : '')})
    }
    
    for(let i=0;i<variant2.staves.length;i++) {
        let currentStaff = variant2.staves[i];
        
        console.log('\nVariant 2, staff ' + i);
        console.log(currentStaff)
        
        svg.append("path")
            .datum(currentStaff.events)
            .attr("class","melodicContourNote variant2")
            .attr("d", line)
            .on('mouseover',function(d,unknown,pathArray) {
                pathArray[0].classList.add('hovering');
                d3.select(pathArray[1]).raise();
            })
            .on('mouseout',function(d,unknown,pathArray) {
                pathArray[0].classList.remove('hovering');
            })
            .append('svg:title')
            .text((d, j) => {return 'Variant 2\nStaff ' + (i + 1) + ((currentStaff.label !== '')? '\n' + currentStaff.label : '')})
    }
    
    /*d3.selectAll("path.melodicContourNote")
        .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));*/
    
    console.log('\drawSemiConnectedLines done')
    
}

function loadPage(newPage) {
    
    removePageListeners();
    page = newPage;
    document.querySelector('#pageNum').value = newPage;
    let svg = vrvToolkit.renderToSVG(page, options);
    
    let svgContainer = document.querySelector('#svgContainer');
    svgContainer.innerHTML = '';
    
    let draw = SVG('svgContainer').size('100%', '100%');
    draw.clear();
    draw.svg(svg);
    
    //todo: is there a more elegant way, either utilising Verovio or Draw?
    let height = svgContainer.querySelector('svg > svg').getAttribute('height');
    svgContainer.style.height = height + 30;
    
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

function openPageByElementID(id) {
    let page = vrvToolkit.getPageWithElement(id);
    loadPage(page);
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
    
    document.querySelector('#contentBox').setAttribute('data-mode',mode);
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

    let width = 300;
    let height = 300;
    let radius = (Math.min(width, height) / 2) - 10;
    let centerRadius = 0.3 * radius;
    let backCircleRadius = 0.15 * radius;
    
    sunburstObject.width = width;
    sunburstObject.height = height;
    sunburstObject.radius = radius;
    sunburstObject.centerRadius = centerRadius;
    sunburstObject.backCircleRadius = backCircleRadius;
    
    let svg = d3.select('#sunburst').append('svg')
        .attr('width', width)
        .attr('height', height);
        
    let g = svg.append('g')
        .attr('id','sunburstG')
        .attr('transform', 'translate(' + width / 2 + ',' + (height / 2) + ')');
    
    sunburstObject.svg = svg;
    sunburstObject.g = g;   
    
    let colorScale = d3.scaleOrdinal().range([
        '#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf'
    ]);
    let xScale = d3.scaleLinear().range([0, 2 * Math.PI]);
    let rScale = d3.scaleLinear().range([0.4 * radius, radius]);
    
    sunburstObject.colorScale = colorScale;
    sunburstObject.xScale = xScale;
    sunburstObject.rScale = rScale;
    
    let arc = d3.arc()
        .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, xScale(d.x0))); })
        .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, xScale(d.x1))); })
        .innerRadius(function(d) { return Math.max(0, rScale(d.y0)); })
        .outerRadius(function(d) { return Math.max(0, rScale(d.y1)); });
    
    sunburstObject.arc = arc;
    
    
    
}

//empty sunburst diagram
function sunburstRemoveData() {
    try {
        if(typeof sunburstObject.g !== 'undefined') {
            sunburstObject.g.selectAll('.sunburstPath').remove();    
        }
    } catch(err) {
        console.error('ERROR: Unable to empty sunburst diagram: ' + err);
    }    
}

//load data into sunburst
function sunburstLoadData(mei,method) {
    
    let data = buildSunburstDataFromMEI(mei);
    sunburstObject.data = data;
    
    let root = d3.hierarchy(data);
    root.sum(function(d) { return d.value; })
        .sort(function(a, b) { return 1.5 });
    
    let partition = d3.partition();
    partition(root);
    
    try {
        sunburstObject.g.selectAll('path')
        .data(root.descendants())
        .enter()
        .append('path').classed('sunburstPath',true)
        .attr('d', sunburstObject.arc)
        .attr('stroke', function(d) {
        
            if(method === 'geneticComparison') {
                let h = Math.round(0 + (120 * Number(d.data.addedLevel) / (Number(d.data.removedLevel) + Number(d.data.simLevel) + Number(0.0001))));
                let s = '80%';
                let l = Math.round((.5 + Number(d.data.idLevel) / 2) * 100) + '%';
                let hsl = 'hsl(' + h + ',' + s + ',' + l + ')'; 
                
                return hsl;
            }
            else if(d.data.idLevel !== 'undefined' && d.data.level === 'measure' && d.data.idLevel < 1) {
                //return 'rgb(' + (240 - d.data.diffLevel * 240) +',0,' + (240 - d.data.simLevel * 240) + ')';
                
                let h = Math.round(240 + (120 * Number(d.data.diffLevel) / (Number(d.data.diffLevel) + Number(d.data.simLevel) + Number(0.0001))));
                let s = '80%';
                let l = Math.round((.5 + Number(d.data.idLevel) / 2) * 100) + '%';
                let hsl = 'hsl(' + h + ',' + s + ',' + l + ')'; 
                
                return hsl;
            } else {
                return '#bbbbbb';
            } 
        
            while(d.depth > 1) d = d.parent;
            if(d.depth == 0) return 'lightgray';
            return d3.color(sunburstObject.colorScale(d.value)).darker(.5);
        })
        .attr('fill', function(d) {
            
            if(method === 'geneticComparison') {
                let h = Math.round(0 + (120 * Number(d.data.addedLevel) / (Number(d.data.removedLevel) + Number(d.data.simLevel) + Number(0.0001))));
                let s = '80%';
                let l = Math.round((.5 + Number(d.data.idLevel) / 2) * 100) + '%';
                let hsl = 'hsl(' + h + ',' + s + ',' + l + ')'; 
                
                return hsl;
            }
            else if(d.data.idLevel !== 'undefined' && d.data.level === 'measure' && d.data.idLevel < 1) {
                //return 'rgb(' + (240 - d.data.diffLevel * 240) +',0,' + (240 - d.data.simLevel * 240) + ')';
                let h = Math.round(240 + (120 * Number(d.data.diffLevel) / (Number(d.data.diffLevel) + Number(d.data.simLevel) + Number(0.0001))));
                let s = '80%';
                let l = Math.round((.5 + Number(d.data.idLevel) / 2) * 100) + '%';
                let hsl = 'hsl(' + h + ',' + s + ',' + l + ')'; 
                
                return  hsl;
            
            } else if(d.data.level === 'measure' && d.parent.data.n % 2 === 0) {
                return '#cccccc';
            } else if(d.data.level === 'measure' && d.parent.data.n % 2 === 1) {
                return '#e5e5e5';
            } else if(d.data.level === 'section' && d.data.n % 2 === 0) {
                return '#cccccc';
            } else if(d.data.level === 'section' && d.data.n % 2 === 1) {
                return '#e5e5e5';
            } 
            
            while(d.depth > 1) d = d.parent;
            if(d.depth == 0) {
                return 'lightgray';
            } 
            return sunburstObject.colorScale(d.value);
        })
        .attr('opacity', 0.8)
        .on('click', sunburstClick)
        .append('title')
        .text(function(d) { 
            if(d.data.level === 'measure' && typeof d.data.idLevel !== 'undefined') {
                return 'Measure ' + d.data.n + '\nid:' + d.data.idLevel + '\nsim:' + d.data.simLevel + '\ndiff:' + d.data.diffLevel; 
            } else if(d.data.level === 'measure') {
                return 'Measure ' + d.data.n;
            } else if(d.data.level === 'section') {
                return 'Section ' + d.data.n;
            }
            return d.data.name;
        });
            
    } catch(err) {
        console.error('error1: ' + err)
    }
    
    /*try {
        sunburstObject.g.selectAll('text')
        .data(root.descendants())
        .enter()
        .append('text')
        .attr('fill', 'black')
        .attr('transform', function(d) { return 'translate(' + sunburstObject.arc.centroid(d) + ')'; })
        .attr('dy', '5px')
        .attr('font', '10px')
        .attr('text-anchor', 'middle')
        .on('click', sunburstClick)
        .text(function(d) { return d.data.name; });
    } catch(err) {
        console.error('error2: ' + err)
    }*/
    
}

function buildSunburstDataFromMEI(mei) {
    
    let oParser = new DOMParser();
    let oDOM = oParser.parseFromString(mei, "application/xml");
    // print the name of the root element or error message
    //console.log(oDOM.documentElement.nodeName == "parsererror" ? "error while parsing" : oDOM.documentElement.nodeName);
    
    try {
        
        let meiDoc = oDOM.documentElement;
        
        let score = meiDoc.querySelector('score');
        let obj = {
            name: score.parentNode.getAttribute('label'),
            level: 'mdiv',
            children: []
        }
        
        let sections = score.querySelectorAll('section');
        for (let i=0;i<sections.length;i++) {
            
            let n = i + 1;
            let section = sections[i];
            let sectionObj = {
                n: n,
                level: 'section',
                children: []
            }
            
            let measures = section.querySelectorAll('measure');
            for(let j=0;j<measures.length;j++) {
                
                let measure = measures[j];
                let measureObj = {
                    n: measure.getAttribute('n'),
                    level: 'measure',
                    id: measure.getAttribute('xml:id'),
                    value: 1
                }
                
                if(measure.hasAttribute('differenceLevel')) {
                    measureObj.diffLevel = measure.getAttribute('differenceLevel');
                    measureObj.simLevel = measure.getAttribute('similarityLevel');
                    measureObj.idLevel = measure.getAttribute('identityLevel');
                }
                
                if(measure.hasAttribute('removedLevel')) {
                    measureObj.removedLevel = measure.getAttribute('removedLevel');
                    measureObj.addedLevel = measure.getAttribute('addedLevel');
                }
                
                sectionObj.children.push(measureObj);
            }
            
            obj.children.push(sectionObj);
            
        }
        
        return obj;
    } catch(err) {
        console.log('error:buildSunburstDataFromMEI ' + err)
    }
}

function sunburstClick(d) {
    
    if(d.data.level === 'measure') {
        try {
            openPageByElementID(d.data.id);
        } catch(err) {
            console.log('error when opening measure: ' + err)
        }
        
        sunburstClick(d.parent);
        return true;
    }
    
    let tween = sunburstObject.g.transition()
      .duration(500)
      .tween('scale', function() {
        let xdomain = d3.interpolate(sunburstObject.xScale.domain(), [d.x0, d.x1]);
        let ydomain = d3.interpolate(sunburstObject.rScale.domain(), [d.y0, 1]);
        let yrange = d3.interpolate(sunburstObject.rScale.range(), [d.y0 ? sunburstObject.backCircleRadius : sunburstObject.centerRadius, sunburstObject.radius]);
        return function(t) {
          sunburstObject.xScale.domain(xdomain(t));
          sunburstObject.rScale.domain(ydomain(t)).range(yrange(t));
        };
      });
 
    tween.selectAll('path')
      .attrTween('d', function(d) {
        return function() {
          return sunburstObject.arc(d);
        };
      });
 
    tween.selectAll('text')
      .attrTween('transform', function(d) {
        return function() {
          return 'translate(' + sunburstObject.arc.centroid(d) + ')';
        };
      })
      .attrTween('opacity', function(d) {
        return function() {
          return(sunburstObject.xScale(d.x0) < 2 * Math.PI) && (sunburstObject.xScale(d.x1) > 0.0) && (sunburstObject.rScale(d.y1) > 0.0) ? 1.0 : 0;
        };
      })
      .attrTween('font', function(d) {
        return function() {
          return(sunburstObject.xScale(d.x0) < 2 * Math.PI) && (sunburstObject.xScale(d.x1) > 0.0) && (sunburstObject.rScale(d.y1) > 0.0) ? '10px' : 1e-6;
        };
      });
    
}

console.log('starting')

setupSunburst();
setListeners();
prepareColors();
getComparisonListing();