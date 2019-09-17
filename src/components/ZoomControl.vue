<template>
    <span id="zoomControl">
      Zoom
      <button class="btn btn-primary btn-sm" v-on:click="decreaseZoom()">&lt;</button>
      <input class="zoomnum" type="text" pattern="\d+" v-model="zoomModel">
      <button class="btn btn-primary btn-sm" v-on:click="increaseZoom()">&gt;</button>
    </span>
</template>

<script>

export default {
  name: 'ZoomControl',
  components: {

  },
  computed: {
    currentZoom: function () {
      return this.$store.getters.currentZoom
    },
    zoomModel: {
      get () {
        return this.$store.getters.currentZoom
      },
      set (n) {
        this.$store.dispatch('setZoom', n)
      }
    }
  },
  methods: {
    decreaseZoom () {
      this.$store.dispatch('decreaseZoom')
    },
    increaseZoom () {
      this.$store.dispatch('increaseZoom')
    },
    setZoom (n) {
      this.$store.dispatch('setZoom', n)
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
#zoomControl {
  /*margin-right: .5rem;*/

  .zoomnum {
    text-align: center;
    width: 3rem;
  }
}
</style>
