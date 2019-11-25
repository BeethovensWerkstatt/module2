<template>
    <button class="btn" v-bind:class="{ 'btn-primary': searchPaneVisible, 'btn-link': !searchPaneVisible }" v-on:click="toggleSearchPane()">Suche</button>
</template>

<script>

export default {
  name: 'SearchButton',
  methods: {
    toggleSearchPane: function() {
      if (this.$store.getters.searchPaneVisible) {
        this.$store.dispatch('hideSearchPane')
      } else {
        this.$store.dispatch('showSearchPane')
      }
    }
  },
  computed: {
    searchPaneVisible: function() {
      return this.$store.getters.searchPaneVisible;
    }
  }

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
