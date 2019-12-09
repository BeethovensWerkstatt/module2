<template>
  <div id="analysisGenetic">
    <div id="viewSettings">
      <div class="viewSettingItem">
        Legende:
      </div>
      <div class="viewSettingItem">
        <i class="fas fa-tint id"></i> Identität
      </div>
      <div class="viewSettingItem">
        <i class="fas fa-tint deleted"></i> Getilgte Noten
      </div>
      <div class="viewSettingItem">
        <i class="fas fa-tint added"></i> Ergänzte Noten
      </div>
    </div>
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

#analysisGenetic #viewSettings {
  .fa-tint {
    &.id {
      color: $neutralColor;
    }
    &.deleted {
      color: $colorVariant1;
    }
    &.added {
      color: $colorVariant2;
    }
  }
}

#analysisGenetic svg {
  .file1 {
    .ts, .od, .sd, .os, .noMatch {
      fill: $colorVariant1;
      stroke: $colorVariant1;

      .accid {
        fill: $colorVariant1;
        stroke: $colorVariant1;
      }

      &.id {
        fill: $neutralColor;
        stroke: $neutralColor;

        .accid {
          fill: $neutralColor;
          stroke: $neutralColor;
        }
      }
    }
  }

  .file2 {
    .ts, .od, .sd, .os, .noMatch {
      fill: $colorVariant2;
      stroke: $colorVariant2;

      .accid {
        fill: $colorVariant2;
        stroke: $colorVariant2;
      }

      &.id {
          fill: $neutralColor;
          stroke: $neutralColor;

          .accid {
            fill: $neutralColor;
            stroke: $neutralColor;
          }
      }
    }
  }
}
</style>
