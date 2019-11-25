<template>
    <div id="navigationTop" v-if="1 == 1" class="navbar">
      <section class="navbar-section">
          <PageNavigation/>
          <ZoomControl/>
          <span>Besetzung, Transposition, Satzkern</span>
      </section>

      <section class="navbar-section">
          <SearchButton/>
      </section>
    </div>
</template>

<script>

import PageNavigation from '@/components/PageNavigation.vue'
import ZoomControl from '@/components/ZoomControl.vue'
import SearchButton from '@/components/SearchButton.vue'

export default {
  name: 'NavigationTop',
  components: {
    PageNavigation,
    ZoomControl,
    SearchButton
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
