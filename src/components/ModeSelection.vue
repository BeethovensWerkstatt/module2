<template>
  <div id="modeSelector">
    <SectionLabel label="Modus"/>
    <ul class="navigationList">
        <li class="modeBtn active" id="plain">Fassungs-Synopse</li><!-- Plain comparison -->
        <li class="modeBtn" id="comparison">Einzelnoten-Vergleich</li><!-- Single Note Comparison -->
        <li class="modeBtn" id="geneticComparison">Genetischer Vergleich</li><!-- Genetic Comparison -->
        <li class="modeBtn" id="melodicComparison">Stimmenkontur-Vergleich</li><!-- Melodic Line Comparison -->
        <li class="modeBtn" id="eventDensity">Ereignisdichte-Vergleich</li><!-- Event Density Comparison -->
        <li class="modeBtn" id="harmonicComparison">Harmonie-Vergleich</li><!-- Harmonic Comparison -->

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

ul.navigationList {
                list-style-type: none;
                margin: 0;
                padding: 0;

                li {
                    padding: .3em 0 .3em 1em;
                    margin: 0.3em 0;
                    font-weight: 300;
                    position: relative;
                    cursor: pointer;
                    border: .5px solid #666666;
                    border-radius: 5px;
                    background-color: #f5f5f5;

                    span.originalVersion {
                        display: block;
                    }

                    span.targetVersion {
                        display: block;
                        font-size: 90%;
                        margin-left: 1em;
                    }

                    &.active {

                        font-weight: 500;
                        background-color: #a7c7f2;
                        /*&:before {
                            position: absolute;
                            left: .2em;
                            content: '‣'
                        }*/
                    }
                  }
}

</style>
