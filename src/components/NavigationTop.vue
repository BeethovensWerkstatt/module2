<template>
    <div id="navigationTop" class="navbar">
      <section class="navbar-section">
          <PageNavigation v-if="modeObj.options.paging"/>
          <ZoomControl v-if="modeObj.options.zoom"/>
          <StaffSelectionButton v-if="modeObj.options.scoreDef"/>
          <TransposeButton v-if="modeObj.options.transposition"/>
          <ColorationButton v-if="modeObj.options.coloring"/>
      </section>

      <section class="navbar-section">
          <SearchButton v-if="modeObj.options.search"/>
      </section>
    </div>
</template>

<script>

import PageNavigation from '@/components/PageNavigation.vue'
import ZoomControl from '@/components/ZoomControl.vue'
import SearchButton from '@/components/SearchButton.vue'
import StaffSelectionButton from '@/components/StaffSelectionButton.vue'
import TransposeButton from '@/components/TransposeButton.vue'
import ColorationButton from '@/components/ColorationButton.vue'

export default {
  name: 'NavigationTop',
  components: {
    PageNavigation,
    ZoomControl,
    SearchButton,
    StaffSelectionButton,
    TransposeButton,
    ColorationButton
  },
  computed: {
    mode: function() {
      return this.$store.getters.activeModeId
    },
    modeObj: function() {
      return this.$store.getters.activeModeObject
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

  div#navigationTop {
    flex: 0 0 auto;
    background-color: #f5f5f5;
    border-bottom: .5px solid #999999;
    padding: 10px 20px;

    #openAboutBtn {
      margin-right: 1em;
      opacity: .6;
      font-size: 1em;
      font-weight: 100;
      text-align: right;
    }

}

</style>
