<template>
  <div id="analysisComparison">
    <div id="svgContainer" class="comparison"></div>
  </div>
</template>

<script>

import VerovioBaseComponent from './VerovioBaseComponent.vue'

export default {
  name: 'AnalysisComparison',
  extends: VerovioBaseComponent,
  components: {

  },
  methods: {

  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss">

  $highlightColor_identical: #000000;
  $highlightColor_different: #d825da;
  $highlightColor_octDiff_durSame: #f4531b;
  $highlightColor_octSame_durDiff: #26d6fc;
  $highlightColor_octDiff_durDiff: #1b44f4;
  $highlightColor_transp_durSame: #859900;

  #svgContainer.comparison .noMatch {
      fill: $highlightColor_different;
      stroke: $highlightColor_different;
  }

  #svgContainer.comparison .ts {
      fill: $highlightColor_transp_durSame;
      stroke: $highlightColor_transp_durSame;
  }

  #svgContainer.comparison .od {
      fill: $highlightColor_octDiff_durDiff;
      stroke: $highlightColor_octDiff_durDiff;
  }

  #svgContainer.comparison .sd {
      fill: $highlightColor_octSame_durDiff;
      stroke: $highlightColor_octSame_durDiff;
  }

  #svgContainer.comparison .os, #svgContainer.comparison .os.od {
      fill: $highlightColor_octDiff_durSame;
      stroke: $highlightColor_octDiff_durSame;
  }

  #svgContainer.comparison .id {
      fill: $highlightColor_identical !important;
      stroke: $highlightColor_identical !important;
  }
</style>
