<template>
  <div id="loadingBack" v-if="isloading">
    <div id="loadingText">{{loadingText}}</div>
  </div>
</template>

<script>

export default {
  name: 'Loading',
  components: {
  },
  computed: {
    isloading: function() {
      return this.$store.getters.currentlyLoading !== null
    },
    loadingText: function() {
      return this.$store.getters.currentlyLoading
    }
  }
}
</script>

<style scoped lang="scss">

#loadingBack {
  display: fixed;
  z-index: 10;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: #ffffff66;

  #loadingText {
      margin: 10rem;
  }
}

</style>
