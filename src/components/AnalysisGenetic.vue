<template>
  <div id="analysisGenetic">
    <div id="svgContainer" class="geneticComparison"></div>
  </div>
</template>

<script>

import VerovioBaseComponent from './VerovioBaseComponent.vue'

export default {
  name: 'AnalysisGenetic',
  extends: VerovioBaseComponent,
  components: {

  },
  methods: {

  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss">

$colorVariant1: #f51d1d;
$colorVariant2: #3ce644;
$neutralColor: #000000;

#analysisGenetic svg {
  .file1 {
    .ts, .od, .sd, .os, .noMatch {
      fill: $colorVariant1;
      stroke: $colorVariant1;

      &.id {
          fill: $neutralColor;
          stroke: $neutralColor;
      }
    }
  }

  .file2 {
    .ts, .od, .sd, .os, .noMatch {
      fill: $colorVariant2;
      stroke: $colorVariant2;

      &.id {
          fill: $neutralColor;
          stroke: $neutralColor;
      }
    }
  }
}
</style>
