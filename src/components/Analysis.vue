<template>
  <div id="analysis">
    <div v-if="1 == 1"><AnalysisPlain/></div>
    <div v-if="1 == 1"><AnalysisComparison/></div>
    <div v-if="1 == 1"><AnalysisGenetic/></div>
    <div v-if="1 == 1"><AnalysisMelodic/></div>
    <div v-if="1 == 1"><AnalysisDensity/></div>
  </div>
</template>

<script>

import AnalysisPlain from '@/components/AnalysisPlain.vue'
import AnalysisComparison from '@/components/AnalysisComparison.vue'
import AnalysisGenetic from '@/components/AnalysisGenetic.vue'
import AnalysisMelodic from '@/components/AnalysisMelodic.vue'
import AnalysisDensity from '@/components/AnalysisDensity.vue'

export default {
  name: 'Analysis',
  components: {
    AnalysisPlain,
    AnalysisComparison,
    AnalysisGenetic,
    AnalysisMelodic,
    AnalysisDensity
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
