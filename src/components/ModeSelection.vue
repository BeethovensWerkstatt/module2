<template>
  <div id="modeSelector">
    <SectionLabel label="Modus"/>
    <ul class="navigationList">
        <li class="modeBtn active" id="plain">Fassungs-Synopse</li><!-- Plain comparison -->
        <li class="modeBtn" id="comparison">Einzelnoten-Vergleich</li><!-- Single Note Comparison -->
        <li class="modeBtn" id="geneticComparison">Genetischer Vergleich</li><!-- Genetic Comparison -->
        <li class="modeBtn" id="melodicComparison">Stimmenkontur-Vergleich</li><!-- Melodic Line Comparison -->
        <li class="modeBtn" id="eventDensity">Ereignisdichte-Vergleich</li><!-- Event Density Comparison -->

        <!--
            <li class="modeBtn" id="relativeChroma">Relative Chroma</li>
            <li class="modeBtn" id="krumhansl-1" title="Generates Krumhansl-Schmuckler values for each single measure">Krumhansl-Schmuckler (1)</li>
            <li class="modeBtn" id="krumhansl-4" title="Generates Krumhansl-Schmuckler values for a sliding window of 4 measures">Krumhansl-Schmuckler (4)</li>
        -->
    </ul>
  </div>
</template>

<script>

import SectionLabel from '@/components/SectionLabel.vue'

export default {
  name: 'ModeSelection',
  components: {
    SectionLabel
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
