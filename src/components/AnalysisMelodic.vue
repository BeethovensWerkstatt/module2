<template>
  <div id="analysisMelodic">
    <div id="viewSettings">
      <div class="viewSettingItem">
        Optionen:
      </div>
      <div class="viewSettingItem">
        <button class="btn btn-sm" v-bind:class="{ 'btn-primary': showMelodicDurations}" v-on:click="toggleDurations()"><i class="fas fa-align-center fa-flip-vertical"></i> Tondauern</button>
      </div>
      <div class="viewSettingItem">
        <button class="btn btn-sm" v-bind:class="{ 'btn-primary': showMelodicDots}" v-on:click="toggleDots()"><i class="fas fa-align-center fa-music"></i> Noten</button>
      </div>
      <div class="viewSettingItem">
        <button class="btn btn-sm" v-bind:class="{ 'btn-primary': showMelodicLines}" v-on:click="toggleLines()"><i class="fas fa-wave-square"></i> Stimmführung</button>
      </div>
    </div>
    <div id="stagingArea" v-bind:class="{'showDots': showMelodicDots, 'showIndividualLines': showMelodicDurations, 'showSemiConnectedLines': showMelodicLines}">
      stage
    </div>
  </div>
</template>

<script>

import * as d3 from 'd3'

let unwatch
let width
let height

export default {
  name: 'AnalysisMelodic',
  components: {
  },
  created () {
    this.$store.dispatch('fetchMEI')
  },
  computed: {
    showMelodicDots: function() {
      return this.$store.getters.showMelodicDots
    },
    showMelodicDurations: function() {
      return this.$store.getters.showMelodicDurations
    },
    showMelodicLines: function() {
      return this.$store.getters.showMelodicLines
    }
  },
  mounted () {

    // initial rendition when data is already available
    if (this.$store.getters.currentMEI !== null) {
      this.displayMelodicComparison()
    }

    width = document.getElementById('analysis').clientWidth
    height = document.getElementById('analysis').clientHeight

    document.getElementById('analysis').style.width = width + 'px'
    document.getElementById('analysis').style.height = height + 'px'

    unwatch = this.$store.watch(
      (state, getters) => ({ request: getters.currentRequest, dataAvailable: (getters.currentMEI !== null)}),
      (newState, oldState) => {
        // console.log(`Updating from ${oldState.request} to ${newState.request}`);
        if (newState.request !== oldState.request) {
          // make sure the required data is available
          this.$store.dispatch('fetchMEI')

          // render data when already available
          if (this.$store.getters.currentMEI !== null) {
            this.displayMelodicComparison()
          }
        }

        // render MEI as soon as it arrives from the API. This responds only for the first time a request has been made
        if (newState.dataAvailable && !oldState.dataAvailable) {
          //do something with the data

          this.displayMelodicComparison()

        }

      }
    )
  },
  beforeDestroy () {
    try {
      unwatch()
    } catch (err) {
      console.log('[ERROR] Unable to remove watcher: ' + err)
    }
  },
  methods: {
    toggleDots: function() {
      this.$store.dispatch('toggleMelodicDots')
    },
    toggleDurations: function() {
      this.$store.dispatch('toggleMelodicDurations')
    },
    toggleLines: function() {
      this.$store.dispatch('toggleMelodicLines')
    },
    displayMelodicComparison: function () {

      let rawData = this.$store.getters.currentMEI
      //console.log('displayMelodicComparison 1')

      let xmlParser = new DOMParser()
      let xmlDOM = xmlParser.parseFromString(rawData, 'application/xml')

      let xmlData = xmlDOM.documentElement

      let duration = 0
      let minPitch = 120
      let maxPitch = 0

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

      /*console.log(data)
      console.log('duration: ' + duration)
      console.log('minPitch: ' + minPitch)
      console.log('maxPitch: ' + maxPitch)

      console.log('displayMelodicComparison 2')*/

      let margin = {top: 40, right: 40, bottom: 40, left: 40};
      let width = duration * 100;
      let height = 550 - margin.top - margin.bottom;

      let x = d3.scaleLinear()
        .domain([0,duration])
        .range([0, width]);

      let y = d3.scaleLinear()
        .domain([minPitch - 12,maxPitch + 12])
        .range([height, 0]);

      //console.log('displayMelodicComparison 3')

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

      //console.log('displayMelodicComparison 4')

      let svgContainer = document.querySelector('#stagingArea');
      svgContainer.innerHTML = '';

      let svg = d3.select("#stagingArea").append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
        .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      svg.append("g")
          //.attr('transform', 'translate(0,' + height + ')')
          .call(xAxis);

      svg.append("g")
          .call(yAxis);

      //console.log('displayMelodicComparison 5')

      let line = d3.line()
          //.defined(function(d) { return d; })
          .x(function(d) { return x(d.x); })
          .y(function(d) { return y(d.y); })
          //.curve(d3.curveStepAfter)

      //console.log('displayMelodicComparison 6')

      this.drawBarlines(svg,line,data.variants[0].measures,minPitch,maxPitch);
      this.drawStaffLines(svg,line,duration);

      //console.log('displayMelodicComparison 7')

      this.drawIndividualLines(svg,line,duration,data)
      //this.drawConnectedLines(svg,line,duration,data,x,y)
      this.drawSemiConnectedLines(svg,line,duration,data,x,y)

      this.drawDots(svg,data,x,y);

    },
    drawBarlines: function (svg, line, measures, minPitch, maxPitch) {
      for(let i=0;i<measures.length;i++) {
        let measure = [{x:measures[i].start,y:minPitch - 12},{x:measures[i].start,y:maxPitch + 12}];

        svg.append("path")
           .datum(measure)
           .attr("d", line)
           .attr("class","melodicContourBarline")
      }
    },
    drawStaffLines: function (svg, line, duration) {
      //these are the "pitches" or regular staff lines, i.e. E4,G4,B4,D5,F5 - A3,F3,D3,B2,G2
      //let staffLines = [64,67,71,74,77,57,53,50,47,43];
      let staffLines = [24,26,28,29,31,33,35,36,38,40,41,43,45,47,48,50,52,53,55,57,59,60,62,64,65,67,69,71,72,74,76,77,79,81,83,84,86,88,89,91,93,95,96]

      for(let i=0;i<staffLines.length;i++) {
        let staffLine = [{x:0,y:staffLines[i]},{x:duration,y:staffLines[i]}]

        svg.append("path")
           .datum(staffLine)
           .attr("d", line)
           .attr("class",(staffLines[i] % 12 === 0) ? "melodicContourStaffLine cline":"melodicContourStaffLine")
      }
    },
    drawDots: function (svg, data, x, y) {

        //console.log('\ndrawDots start')

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
        //console.log('drawDots end')
    },
    drawIndividualLines: function (svg,line,duration,data) {

        //console.log('\ndrawIndividualLines')

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
                        .attr("class","melodicContourNote individualLine variant1")
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
                        .attr("class","melodicContourNote individualLine variant2")
                        .attr("d", line)
                }

            }

        }

        //console.log('\drawIndividualLines done')

    },

    // buggy:
    drawConnectedLines: function (svg,line,duration,data,x,y) {

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
                .attr("class","melodicContourNote connectedLine variant1")
                .attr("d", line)
        }

        for(let i=0;i<variant2.staves.length;i++) {
            let currentStaff = variant1.staves[i];

            svg.append("path")
                .datum(currentStaff.events)
                .attr("class","melodicContourNote connectedLine variant2")
                .attr("d", line)
        }

        console.log('\drawConnectedLines done')

    },
    drawSemiConnectedLines: function (svg,line,duration,data,x,y) {

        //console.log('\ndrawSemiConnectedLines')

        line = d3.line()
            .defined(function(d) { return d.pnum !==''; })
            .x(function(d) { return x(d.start); })
            .y(function(d) { return y(d.pnum/*((d.pnum % 12) + 60)*/); })
            //.curve(d3.curveStepAfter)
            //.curve(d3.curveCatmullRom)
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
            // console.log('me no dragging anymore?')
            f.forEach((line) => {
                //console.log(line);

                d3.select(line).attr('style','transform: translateY(0);');

            })
        }

        for(let i=0;i<variant1.staves.length;i++) {
            let currentStaff = variant1.staves[i];

            // console.log('\nVariant 1, staff ' + i);
            // console.log(currentStaff)

            svg.append("path")
                .datum(currentStaff.events)
                .attr("class","melodicContourNote semiConnectedLine variant1")
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

            // console.log('\nVariant 2, staff ' + i);
            // console.log(currentStaff)

            svg.append("path")
                .datum(currentStaff.events)
                .attr("class","melodicContourNote semiConnectedLine variant2")
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

        //console.log('\drawSemiConnectedLines done')

    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss">
#viewSettings {
  flex: 0 0 auto;
  background-color: #f5f5f5;
  border-bottom: .5px solid #999999;
  padding: 10px 20px;
  text-align: left;

  .viewSettingItem {
    display: inline-block;
    padding: 0 .5rem;
    margin-right: .5rem;
    & + .viewSettingItem + .viewSettingItem {
      border-left: .5px solid #666666;
      padding-left: 1rem;
    }
  }

  .viewSettingDetail {
    display: inline-block;
    padding: 0 .5rem;
  }

}

#stagingArea {
  overflow: scroll;
  position: relative;

  $color1: #f51d1d;
  $color2: #0ebd16; /*#3ce644;*/

  .semiConnectedLine {
    visibility: hidden;
  }

  &.showSemiConnectedLines .semiConnectedLine {
    visibility: visible;
  }

  .individualLine {
    visibility: hidden;
  }

  &.showIndividualLines .individualLine {
    visibility: visible;
  }

  .dot {
    visibility: hidden;
  }

  &.showDots .dot {
    visibility: visible;
  }

  .melodicContourNote {
      /*opacity: .5;*/

      stroke-width: 2;
      stroke: #999999;
      fill: none;

      mix-blend-mode: color-burn;

      &.variant1 {
          stroke: $color1;
      }

      &.variant2 {
          stroke: $color2;
      }
  }

  .hovering {
      opacity: 1;
      stroke-width: 3;
  }

  .melodicContourStaffLine {
      opacity: .5;

      stroke-width: .5;
      stroke: #999999;
      fill: none;

      &.cline {
          opacity: .8;
          stroke: #333333;
      }
  }

  .melodicContourBarline {
      opacity: .5;

      stroke-width: .8;
      stroke: #333333;
      fill: none;

  }

  .dot.variant1 {
      fill: $colorVariant1;
      opacity:1;
  }
  .dot.variant2 {
      fill: $colorVariant2;
      opacity:1;
  }

  .dot-halo {
      opacity: 1;
  }
}
</style>
