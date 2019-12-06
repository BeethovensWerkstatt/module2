<template>
  <div id="analysisComparison">
    <div id="viewSettings">
      <div class="form-group float-right">
        <label class="form-checkbox form-inline" style="margin: 0;">
          <input type="checkbox" v-on:change.prevent="toggleColoration($event)" v-bind:checked="detailedColoration"><i class="form-icon"></i> Advanced
        </label>
      </div>
      <div class="viewSettingItem">
        Legende:
      </div>
      <div class="viewSettingItem">
        <i class="fas fa-tint id"></i> Identität
      </div>
      <div v-if="detailedColoration" class="viewSettingItem">
        <div class="viewSettingDetail">
          <i class="fas fa-tint os"></i> Oktavvarianz
        </div>
        <div class="viewSettingDetail">
          <i class="fas fa-tint sd"></i> Tondauervarianz
        </div>
        <div class="viewSettingDetail">
          <i class="fas fa-tint od"></i> Oktav- und Tondauervarianz
        </div>
        <div class="viewSettingDetail">
          <i class="fas fa-tint ts"></i> Tonbuchstabenvarianz
        </div>
      </div>
      <div v-else class="viewSettingItem">
        <i class="fas fa-tint var"></i> Varianz
      </div>
      <div class="viewSettingItem">
        <i class="fas fa-tint noMatch"></i> Differenz
      </div>
    </div>
    <div id="svgContainer" class="comparison" v-bind:class="{'detailedColors': detailedColoration}"></div>
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
    toggleColoration: function() {
      this.$store.dispatch('toggleComparisonDetailedColoration')
    }
  },
  computed: {
    detailedColoration: function() {
      return this.$store.getters.comparisonDetailedColoration
    }
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

    .ts, .ts .accid, .od, .od .accid, .sd, .sd .accid, .os, .os .accid {
      fill: $highlightColor_octDiff_durDiff;
      stroke: $highlightColor_octDiff_durDiff;
    }

    &.detailedColors {
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
    }

    .id, .id .accid {
      fill: $highlightColor_identical !important;
      stroke: $highlightColor_identical !important;
    }
  }

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

    .fa-tint {
      &.id {
        color: $highlightColor_identical;
      }
      &.os {
        color: $highlightColor_octDiff_durSame;
      }
      &.sd {
        color: $highlightColor_octSame_durDiff;
      }
      &.od {
        color: $highlightColor_octDiff_durDiff;
      }
      &.ts {
        color: $highlightColor_transp_durSame;
      }
      &.var {
        color: $highlightColor_octDiff_durDiff;
      }
      &.noMatch {
        color: $highlightColor_different;
      }
    }

  }
</style>
