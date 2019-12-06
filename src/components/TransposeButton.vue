<template>
    <button class="btn btn-sm" v-bind:class="{ 'btn-primary': transposeVisible}" v-on:click="toggleTransposePane()"><i class="fas fa-arrows-alt-v"></i> Transposition</button>
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
    margin-left: .8rem;
  }
</style>
