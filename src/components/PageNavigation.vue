<template>
    <span id="pageNavigation">
      <button class="btn btn-primary btn-sm" v-on:click="decreasePage()">&lt;</button>
      <input class="pagenum" type="text" pattern="\d+" v-model="pageModel">
      <button class="btn btn-primary btn-sm" v-on:click="increasePage()">&gt;</button>
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
    },
    pageModel: {
      get () {
        return this.$store.getters.currentPage
      },
      set (n) {
        this.$store.dispatch('setPage', n)
      }
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
#pageNavigation {
  /*margin-right: .5rem;*/

  .pagenum {
    text-align: center;
    width: 3rem;
  }
}
</style>
