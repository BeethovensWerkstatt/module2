<template>
    <span id="pageNavigation" class="input-group">
      <button class="btn btn-primary btn-sm btn-action input-group-btn" v-on:click="decreasePage()"><i class="fas fa-caret-left"></i></button>
      <input class="pagenum form-input input-sm" type="text" pattern="\d+" v-model="pageModel">
      <button class="btn btn-primary btn-sm btn-action input-group-btn" v-on:click="increasePage()"><i class="fas fa-caret-right"></i></button>
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
