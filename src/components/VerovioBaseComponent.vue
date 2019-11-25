<template>
  <div id='svgContainer'></div>
</template>

<script>

let unwatch
let width
let height
let zoom = 35
let selectionStarted = false

export default {
  name: 'VerovioBaseComponent',
  components: {

  },
  created () {
    this.$store.dispatch('fetchMEI')
    // this.setOptions()
  },
  mounted () {

    // initial Verovio rendering (when data available)
    if (this.$store.getters.currentMEI !== null) {
      this.loadMEI()
      this.renderPage(this.$store.getters.currentPage)
    }

    width = document.getElementById('analysis').clientWidth
    height = document.getElementById('analysis').clientHeight
    this.setOptions()

    unwatch = this.$store.watch(
      (state, getters) => ({ request: getters.currentRequest, page: getters.currentPage, dataAvailable: (getters.currentMEI !== null)}),
      (newState, oldState) => {
        // console.log(`Updating from ${oldState.request} to ${newState.request}`);
        if (newState.request !== oldState.request) {
          // make sure the required data is available
          this.$store.dispatch('fetchMEI')

          // render data when already available
          if (this.$store.getters.currentMEI !== null) {
            this.loadMEI()
            this.renderPage(this.$store.getters.currentPage)
          }
        }

        // render MEI as soon as it arrives from the API. This responds only for the first time a request has been made
        if (newState.dataAvailable && !oldState.dataAvailable) {
          this.loadMEI()
          this.renderPage(newState.page)
        }

        if (newState.page !== oldState.page) {
          // make verovio render the requested page
          this.renderPage(newState.page)
        }

      }
    )
  },
  updated () {
    // this.$store.dispatch('fetchMEI')
  },
  beforeDestroy () {
    try {
      unwatch()
    } catch (err) {
      console.log('[ERROR] Unable to remove watcher: ' + err)
    }
  },
  methods: {
    setOptions: function () {
      let options = {
        scale: zoom,
        noFooter: 1, // takes out the 'rendered by Verovio' footer

        pageWidth: (width - 20) * 100 / zoom,
        pageHeight: (height - 20) * 100 / zoom,
        adjustPageHeight: true,
        spacingNonLinear: 1,
        spacingLinear: 0.05
        // svgViewBox: 1
      }
      try {
        this.$verovio.setOptions(options)
      } catch (err) {
        console.log('ERR: ' + err)
      }
    },
    loadMEI: function () {
      this.$verovio.loadData(this.currentMEI + '\n')
      let maxPage = this.$verovio.getPageCount()
      if(maxPage > 0) {
        this.$store.dispatch('setMaxPage',maxPage)
      }
    },
    renderPage: function (n) {
      // set listeners

      let svg = this.$verovio.renderToSVG(this.$store.getters.currentPage, {})
      let svgContainer = document.querySelector('#svgContainer')
      svgContainer.innerHTML = svg

      let outerSVG = document.querySelector('#svgContainer > svg')
      // outerSVG.addEventListener('mousedown',this.startSelectionRect)
      outerSVG.addEventListener('mousemove',this.updateSelectionRect)
      // outerSVG.addEventListener('mouseup',this.finishSelectionRect)
      outerSVG.addEventListener('click',this.handleSelectionRect)
    },
    /*startSelectionRect: function (e) {

      if (!this.$store.getters.searchSelectionActive) {
        return false
      }

      let outerSVG = document.querySelector('#svgContainer > svg')
      let innerSVG = document.querySelector('#svgContainer svg svg')
      let clientRect = outerSVG.getClientRects()[0]
      let htmlWidth = clientRect.width
      let svgWidth = innerSVG.getAttribute('viewBox').split(' ')[2]
      let factor = svgWidth / htmlWidth
      let widthOffset = outerSVG.getBoundingClientRect().left
      let heightOffset = outerSVG.getBoundingClientRect().top

      let cx = (e.clientX - widthOffset) * factor
      let cy = (e.clientY - heightOffset) * factor

      let existingCircle = document.getElementById('selectionStart')
      let existingRect = document.getElementById('selectionRect')

      if (existingCircle === null) {
        let circle = document.createElementNS('http://www.w3.org/2000/svg','circle')

        circle.setAttributeNS(null,'id','selectionStart')
        circle.setAttributeNS(null,'cx',cx)
        circle.setAttributeNS(null,'cy',cy)
        circle.setAttributeNS(null,'r',100)
        circle.setAttributeNS(null,'fill','transparent')
        circle.setAttributeNS(null,'stroke','red')
        circle.setAttributeNS(null,'stroke-width',60)

        innerSVG.appendChild(circle)
      } else {
        existingCircle.setAttributeNS(null,'cx',cx)
        existingCircle.setAttributeNS(null,'cy',cy)
      }

      if (existingRect === null) {
        let rect = document.createElementNS('http://www.w3.org/2000/svg','rect')

        rect.setAttributeNS(null,'id','selectionRect')
        rect.setAttributeNS(null,'x',cx)
        rect.setAttributeNS(null,'y',cy)
        rect.setAttributeNS(null,'width',0)
        rect.setAttributeNS(null,'height',0)
        rect.setAttributeNS(null,'fill','#ff000033')
        rect.setAttributeNS(null,'stroke','red')
        rect.setAttributeNS(null,'stroke-width',20)

        innerSVG.appendChild(rect)
      } else {
        existingRect.setAttributeNS(null,'x',cx)
        existingRect.setAttributeNS(null,'y',cy)
        existingRect.setAttributeNS(null,'width',0)
        existingRect.setAttributeNS(null,'height',0)
      }
      console.log('startSelectionRect: selectionStarted=' + selectionStarted + '->' + !selectionStarted)
      selectionStarted = !selectionStarted

    },*/
    updateSelectionRect: function (e) {
      if (!this.$store.getters.searchSelectionActive) {
        return false
      }

      if (!selectionStarted) {
        return false
      }

      //console.log(e)

      let outerSVG = document.querySelector('#svgContainer > svg')
      let innerSVG = document.querySelector('#svgContainer svg svg')
      let clientRect = outerSVG.getClientRects()[0]
      let htmlWidth = clientRect.width
      let svgWidth = innerSVG.getAttribute('viewBox').split(' ')[2]
      let factor = svgWidth / htmlWidth
      let widthOffset = outerSVG.getBoundingClientRect().left
      let heightOffset = outerSVG.getBoundingClientRect().top

      let x = (e.clientX - widthOffset) * factor
      let y = (e.clientY - heightOffset) * factor

      let existingCircle = document.getElementById('selectionStart')
      let existingRect = document.getElementById('selectionRect')

      let startx = existingCircle.getAttribute('cx')
      let starty = existingCircle.getAttribute('cy')

      let width = x - startx
      let height = y - starty

      if (width < 0) {
        existingRect.setAttributeNS(null,'x',x)
        width = startx - x
      } else {
        existingRect.setAttributeNS(null,'x',startx)
      }

      if (height < 0) {
        existingRect.setAttributeNS(null,'y',y)
        height = starty - y
      } else {
        existingRect.setAttributeNS(null,'y',starty)
      }

      existingRect.setAttributeNS(null,'width',width)
      existingRect.setAttributeNS(null,'height',height)

      this.getElementsByRect(outerSVG, existingRect)
    },
    /*finishSelectionRect: function (e) {
      if (!this.$store.getters.searchSelectionActive) {
        return false
      }

      if (selectionStarted) {
        // on first occurence, nothing should happen
        return false
      }
      console.log('finishSelectionRect: selectionStarted=' + selectionStarted)
      // selectionStarted = false

      let outerSVG = document.querySelector('#svgContainer > svg')
      let innerSVG = document.querySelector('#svgContainer svg svg')
      let clientRect = outerSVG.getClientRects()[0]
      let htmlWidth = clientRect.width
      let svgWidth = innerSVG.getAttribute('viewBox').split(' ')[2]
      let factor = svgWidth / htmlWidth
      let widthOffset = outerSVG.getBoundingClientRect().left
      let heightOffset = outerSVG.getBoundingClientRect().top

      let x = (e.clientX - widthOffset) * factor
      let y = (e.clientY - heightOffset) * factor

      let existingCircle = document.getElementById('selectionStart')
      let existingRect = document.getElementById('selectionRect')

      let startx = existingCircle.getAttribute('cx')
      let starty = existingCircle.getAttribute('cy')

      let width = x - startx
      let height = y - starty

      if (width < 0) {
        existingRect.setAttributeNS(null,'x',x)
        width = startx - x
      } else {
        existingRect.setAttributeNS(null,'x',startx)
      }

      if (height < 0) {
        existingRect.setAttributeNS(null,'y',y)
        height = starty - y
      } else {
        existingRect.setAttributeNS(null,'y',starty)
      }

      existingRect.setAttributeNS(null,'width',width)
      existingRect.setAttributeNS(null,'height',height)

      existingCircle.remove()
    },*/
    handleSelectionRect: function (e) {

      if (!this.$store.getters.searchSelectionActive) {
        return false
      }

      let outerSVG = document.querySelector('#svgContainer > svg')
      let innerSVG = document.querySelector('#svgContainer svg svg')
      let clientRect = outerSVG.getClientRects()[0]
      let htmlWidth = clientRect.width
      let svgWidth = innerSVG.getAttribute('viewBox').split(' ')[2]
      let factor = svgWidth / htmlWidth
      let widthOffset = outerSVG.getBoundingClientRect().left
      let heightOffset = outerSVG.getBoundingClientRect().top

      let cx = (e.clientX - widthOffset) * factor
      let cy = (e.clientY - heightOffset) * factor

      let existingCircle = document.getElementById('selectionStart')
      let existingRect = document.getElementById('selectionRect')

      // starting selection
      if (!selectionStarted) {
        if (existingCircle === null) {
          let circle = document.createElementNS('http://www.w3.org/2000/svg','circle')

          circle.setAttributeNS(null,'id','selectionStart')
          circle.setAttributeNS(null,'cx',cx)
          circle.setAttributeNS(null,'cy',cy)
          circle.setAttributeNS(null,'r',100)
          circle.setAttributeNS(null,'fill','transparent')
          circle.setAttributeNS(null,'stroke','red')
          circle.setAttributeNS(null,'stroke-width',60)

          innerSVG.appendChild(circle)
        } else {
          existingCircle.setAttributeNS(null,'cx',cx)
          existingCircle.setAttributeNS(null,'cy',cy)
        }

        if (existingRect === null) {
          let rect = document.createElementNS('http://www.w3.org/2000/svg','rect')

          rect.setAttributeNS(null,'id','selectionRect')
          rect.setAttributeNS(null,'x',cx)
          rect.setAttributeNS(null,'y',cy)
          rect.setAttributeNS(null,'width',0)
          rect.setAttributeNS(null,'height',0)
          rect.setAttributeNS(null,'fill','#ff000033')
          rect.setAttributeNS(null,'stroke','red')
          rect.setAttributeNS(null,'stroke-width',20)

          innerSVG.appendChild(rect)
        } else {
          existingRect.setAttributeNS(null,'x',cx)
          existingRect.setAttributeNS(null,'y',cy)
          existingRect.setAttributeNS(null,'width',0)
          existingRect.setAttributeNS(null,'height',0)
        }
      // ending selection
      } else {

        let startx = existingCircle.getAttribute('cx')
        let starty = existingCircle.getAttribute('cy')

        let width = cx - startx
        let height = cy - starty

        if (width < 0) {
          existingRect.setAttributeNS(null,'x',cx)
          width = startx - cx
        } else {
          existingRect.setAttributeNS(null,'x',startx)
        }

        if (height < 0) {
          existingRect.setAttributeNS(null,'y',cy)
          height = starty - cy
        } else {
          existingRect.setAttributeNS(null,'y',starty)
        }

        existingRect.setAttributeNS(null,'width',width)
        existingRect.setAttributeNS(null,'height',height)

        existingCircle.remove()

        this.getElementsByRect(outerSVG, existingRect)
      }

      selectionStarted = !selectionStarted
    },
    getElementsByRect: function (svg, rect) {

      let x1 = parseInt(rect.getAttribute('x'))
      let x2 = x1 + parseInt(rect.getAttribute('width'))
      let y1 = parseInt(rect.getAttribute('y'))
      let y2 = y1 + parseInt(rect.getAttribute('height'))

      // console.log(rect)
      // console.log('looking for events ' + x1 + '<=x<=' + x2 + ' and ' + y1 + '<=y<=' + y2)

      let events = Array.from(svg.querySelectorAll('g.note, g.chord, g.rest'))
      let affected = events.filter(event => {
        // if(event.classList.contains('note') || event.classList.contains('chord'))
        let use = event.querySelector('use')
        let usex = use.getAttribute('x')
        let usey = use.getAttribute('y')
        let fitsx = usex >= x1 && usex <= x2
        let fitsy = usey >= y1 && usey <= y2
        return fitsx && fitsy
      })

      let previousSelection = Array.from(svg.querySelectorAll('g.selected'))
      let unselected = previousSelection.filter(event => {
        let use = event.querySelector('use')
        let usex = use.getAttribute('x')
        let usey = use.getAttribute('y')
        let fitsx = usex >= x1 && usex <= x2
        let fitsy = usey >= y1 && usey <= y2
        return !(fitsx && fitsy)
      })

      let affectedIDs = []

      unselected.forEach((event,index) => {
        event.classList.remove('selected')
      })
      affected.forEach((event,index) => {
        affectedIDs.push(event.id)
        event.classList.add('selected')
      })

      return affectedIDs
    }
  },
  computed: {
    activeModeId: function () {
      return this.$store.getters.activeModeId
    },
    activeModeObject: function () {
      return this.$store.getters.activeModeObject
    },
    currentPage: function () {
      return this.$store.getters.currentPage
    },
    currentMEI: function () {
      return this.$store.getters.currentMEI
    },
    searchSelectionActive: function() {
      return this.$store.getters.searchSelectionActive
    }
  }
}
</script>

<style lang="scss">
  svg g.selected, svg g.selected * {
    fill: red;
    stroke: red;
  }
</style>
