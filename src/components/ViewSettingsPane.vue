<template>
  <div id="viewSettingsModal" class="modal modal-sm" v-bind:class="{ 'active': viewSettingsVisible }">
    <a href="#close" class="modal-overlay" aria-label="Close" v-on:click="toggleViewSettingsPane($event)"></a>
    <div class="modal-container">
      <div class="modal-header">
        <a href="#close" class="btn btn-clear float-right" aria-label="Close" v-on:click="toggleViewSettingsPane($event)"></a>
        <div class="modal-title h5">View Settings</div>
      </div>
      <div class="modal-body">
        <div class="content">
          Hallo?
        </div>
      </div>
      <div class="modal-footer">
        <button v-on:click="toggleViewSettingsPane($event)" class="btn btn-sm cancelBtn">cancel</button>
        <button v-on:click="acceptViewSettings($event)" class="btn btn-sm btn-primary">adjust view</button>
      </div>
    </div>

  </div>
</template>

<script>

export default {
  name: 'ViewSettingsPane',
  methods: {
    toggleViewSettingsPane: function(e) {
      // this.$store.dispatch('rejectProposedTranspose')
      this.$store.dispatch('hideViewSettingsPane')
      e.preventDefault()
    }// ,
    /*proposeTranspose: function(e) {
      this.$store.dispatch('setProposedTranspose',e.target.value)
      e.preventDefault()
    },
    acceptTranspose: function(e) {
      console.log()
      this.$store.dispatch('acceptProposedTranspose')
      this.$store.dispatch('hideViewSettingsPane')
      e.preventDefault()
    }*/
  },
  computed: {
    viewSettingsVisible: function() {
      return this.$store.getters.viewSettingsVisible
    } //,
    /*currentTranspose: function() {
      return this.$store.getters.proposedTranspose
    }*/
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

  .cancelBtn {
    margin-right: .2rem;
  }

  .form-radio {
    text-align: left;
  }

</style>
