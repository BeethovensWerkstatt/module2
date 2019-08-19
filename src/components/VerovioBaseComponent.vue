<template>
  <div id="svgContainer"></div>
</template>

<script>

let unwatch
let width
let height
let zoom = 35

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
      (state, getters) => ({ request: getters.currentRequest, page: getters.currentPage, dataAvailable: (getters.currentMEI !== null) }),
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
          console.log('coming back for the first time')
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
        noFooter: 1, // takes out the "rendered by Verovio" footer

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
    /* renderMEI: function () {
      let options = {
          scale: 30,
          noFooter: 1, // takes out the "rendered by Verovio" footer
          // adjustPageHeight: true,
          spacingNonLinear: 1,
          spacingLinear: .05,
          svgViewBox: 1
        };
      try {
          this.$verovio.setOptions(options);
      } catch(err) {
        console.log('ERR: ' + err)
      }
      console.log('successfully set options…')

      if(typeof this.currentMEI !== 'undefined') {

        this.$verovio.loadData(this.currentMEI + '\n')
        this.currentPage)
        this.loadPage(this.currentPage)
      }
    }, */
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
    }/*,
    render: function () {
      return this.render()
    }*//*,
    svg: function () {
      if (this.$store.getters.currentMEI === null) {
        return 'kann noch nicht laden'
      } else {
        this.$verovio.loadData(this.$store.getters.currentMEI + '\n')
        return this.renderPage(this.$store.getters.currentPage)
      }
    }*/
  }
}
</script>
