<template>
    <button class="btn" v-bind:class="{ 'btn-primary': transposeVisible, 'btn-link': !transposeVisible }" v-on:click="toggleTransposePane()">Transposition</button>
</template>

<script>

export default {
  name: 'TransposeButton',
  methods: {
    toggleTransposePane: function() {
      if (this.$store.getters.transposeSelectionVisible) {
        this.$store.dispatch('deactivateTransposeSelection')
      } else {
        this.$store.dispatch('activateTransposeSelection')
      }
    }
  },
  computed: {
    transposeVisible: function() {
      return this.$store.getters.transposeSelectionVisible;
    }
  }

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  .btn {
    margin: 0 .5rem;
  }
</style>
