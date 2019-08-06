<template>
  <div id="analysis">
    <div v-if="activeModeId === 'plain'"><AnalysisPlain/></div>
    <div v-if="activeModeId === 'eventComparison'"><AnalysisComparison/></div>
    <div v-if="activeModeId === 'geneticComparison'"><AnalysisGenetic/></div>
    <div v-if="activeModeId === 'melodicComparison'"><AnalysisMelodic/></div>
    <div v-if="activeModeId === 'harmonicComparison'"><AnalysisHarmonic/></div>
    <div v-if="activeModeId === 'eventDensity'"><AnalysisDensity/></div>
  </div>
</template>

<script>

import AnalysisPlain from '@/components/AnalysisPlain.vue'
import AnalysisComparison from '@/components/AnalysisComparison.vue'
import AnalysisGenetic from '@/components/AnalysisGenetic.vue'
import AnalysisMelodic from '@/components/AnalysisMelodic.vue'
import AnalysisDensity from '@/components/AnalysisDensity.vue'
import AnalysisHarmonic from '@/components/AnalysisHarmonic.vue'

export default {
  name: 'Analysis',
  components: {
    AnalysisPlain,
    AnalysisComparison,
    AnalysisGenetic,
    AnalysisMelodic,
    AnalysisDensity,
    AnalysisHarmonic
  },
  computed: {
    activeModeId: function() {
      return this.$store.getters.activeModeId
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
#analysis {
  flex: 1 1 auto;
  overflow: auto;
}
</style>
