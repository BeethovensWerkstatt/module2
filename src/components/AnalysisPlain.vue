<template>
  <div id="analysisPlain">
    <h1>AnalysisPlain</h1>
    <div id="svgContainer"></div>
  </div>
</template>

<script>

export default {
  name: 'AnalysisPlain',
  components: {

  },
  mounted(){
    console.log('me mounted')
    this.getData()
  },
  methods: {
    getData: function() {

      let activeComparisonId = this.$store.getters.activeComparisonId
      let activeMovement = this.$store.getters.activeMovement
      let transpose = this.$store.getters.transpose

      let api = process.env.VUE_APP_DATA_BACKEND_URL
      let request = 'resources/xql/getAnalysis.xql?comparisonId=' + activeComparisonId + '&method=plain&mdiv=' + activeMovement + '&transpose=' + transpose

      /*return 'api: ' + api + request*/

      if(activeComparisonId === null) {
        return false;
      }

      let options = {
          scale: 50,
          noFooter: 1, // takes out the "rendered by Verovio" footer
          pageWidth: 500,
          pageHeight: 500,
          adjustPageHeight: true,
          spacingNonLinear: 1,
          spacingLinear: .05
        };
      try {
          this.$verovio.setOptions(options);
      } catch(err) {
        console.log('ERR: ' + err)
      }
      console.log('successfully set options…')

      // console.log('\nhello polly ' + typeof verovio)

      new Promise(resolve => {
        fetch(api + request)
          .then(response => response.text()) // add error handling for failing requests
          .then(mei => {
            this.$verovio.loadData(mei + '\n')
            this.loadPage(1)
          })
      })
    },
    loadPage: function(n) {
      console.log('loading page ' + n)
      let svg = this.$verovio.renderToSVG(n, {});
      let svgContainer = document.querySelector('#svgContainer');
      svgContainer.innerHTML = svg;


    }
  },
  computed: {
    activeModeId: function() {
      return this.$store.getters.activeModeId
    },
    activeModeObject: function() {
      return this.$store.getters.activeModeObject
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
