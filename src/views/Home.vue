<template>

  <div class="home">

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
  }
}
</script>
