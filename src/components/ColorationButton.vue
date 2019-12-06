<template>
    <button class="btn btn-sm" v-bind:class="{ 'btn-primary': highlightingVisible}" v-on:click="toggleHighlighting()"><i class="fas fa-palette"></i> Einfärbung</button>
</template>

<script>

export default {
  name: 'ColorationButton',
  methods: {
    toggleHighlighting: function() {
      this.$store.dispatch('toggleHighlighting')
    }
  },
  computed: {
    highlightingVisible: function() {
      return this.$store.getters.highlightingVisible
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
