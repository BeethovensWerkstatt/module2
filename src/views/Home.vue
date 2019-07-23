<template>

  <div class="home">

    <div v-if="introVisible">
      <h1>show Intro</h1>
    </div>
    <div v-if="!introVisible">
      <div class="container">
        <div class="columns">
          <div id="navigationBox" class="column col-3 col-lg-12">
            <ComparisonSelection/>
            <ModeSelection/>
            <!-- WorkSelection -->
            <!-- WorkSelection -->
          </div>
          <div id="contentBox" class="column col-9 col-lg-12">
          <!-- Content -->
            <NavigationTop/>
            <Analysis/>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
// @ is an alias to /src
import ComparisonSelection from '@/components/ComparisonSelection.vue'
import ModeSelection from '@/components/ModeSelection.vue'
import Analysis from '@/components/Analysis.vue'
import NavigationTop from '@/components/NavigationTop.vue'

export default {
  name: 'home',
  components: {
    ComparisonSelection,
    ModeSelection,
    Analysis,
    NavigationTop
  },
  computed: {
    introVisible: function() {
      return this.$store.getters.introVisible;
    }
  }
}
</script>
