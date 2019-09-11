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

  #svgContainer.comparison {
    .noMatch, .noMatch .accid {
      fill: $highlightColor_different;
      stroke: $highlightColor_different;
    }

    .ts, .ts .accid {
      fill: $highlightColor_transp_durSame;
      stroke: $highlightColor_transp_durSame;
    }

    .od, .od .accid {
      fill: $highlightColor_octDiff_durDiff;
      stroke: $highlightColor_octDiff_durDiff;
    }

    .sd, .sd .accid {
      fill: $highlightColor_octSame_durDiff;
      stroke: $highlightColor_octSame_durDiff;
    }

    .os, .os .accid {
        fill: $highlightColor_octDiff_durSame;
        stroke: $highlightColor_octDiff_durSame;
    }

    .id, .id .accid {
      fill: $highlightColor_identical !important;
      stroke: $highlightColor_identical !important;
    }
  }
</style>
