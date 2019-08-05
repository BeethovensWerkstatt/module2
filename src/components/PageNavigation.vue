<template>
    <span id="pageNavigation">
      <button class="btn btn-primary" v-on:click="decreasePage()">&lt;</button>
      <span id="pageNum">{{currentPage}}</span>
      <button class="btn btn-primary" v-on:click="increasePage()">&gt;</button>
    </span>
</template>

<script>

export default {
  name: 'PageNavigation',
  components: {

  },
  computed: {
    currentPage: function () {
      return this.$store.getters.currentPage
    }
  },
  methods: {
    decreasePage () {
      this.$store.dispatch('decreasePage')
    },
    increasePage () {
      this.$store.dispatch('increasePage')
    },
    setPage (n) {
      this.$store.dispatch('setPage', n)
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
