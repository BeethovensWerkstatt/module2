<template>
    <button class="btn btn-sm" v-bind:class="{ 'btn-primary': staffSelectionVisible}" v-on:click="toggleStaffSelectionPane()"><i class="fas fa-align-right"></i> Besetzung</button>
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
    margin-left: .8rem;
  }
</style>
