<template>
    <button class="btn" v-bind:class="{ 'btn-primary': staffSelectionVisible, 'btn-link': !staffSelectionVisible }" v-on:click="toggleStaffSelectionPane()">Besetzung</button>
</template>

<script>

export default {
  name: 'StaffSelectionButton',
  methods: {
    toggleStaffSelectionPane: function() {
      if (this.$store.getters.staffSelectionVisible) {
        this.$store.dispatch('deactivateStaffSelection')
      } else {
        this.$store.dispatch('activateStaffSelection')
      }
    }
  },
  computed: {
    staffSelectionVisible: function() {
      return this.$store.getters.staffSelectionVisible;
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
