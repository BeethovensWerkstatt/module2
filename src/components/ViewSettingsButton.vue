<template>
    <button class="btn" v-bind:class="{ 'btn-primary': viewSettingsVisible, 'btn-link': !viewSettingsVisible }" v-on:click="toggleViewSettingsPane()">Transposition</button>
</template>

<script>

export default {
  name: 'ViewSettingsButton',
  methods: {
    toggleViewSettingsPane: function() {
      if (this.$store.gettersViewSettingsVisible) {
        this.$store.dispatch('deactivateViewSettingsVisible')
      } else {
        this.$store.dispatch('activateViewSettingsVisible')
      }
    }
  },
  computed: {
    viewSettingsVisible: function() {
      return this.$store.getters.viewSettingsVisible;
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
