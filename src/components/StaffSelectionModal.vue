<template>
  <div id="staffSelectionModal" class="modal modal-sm" v-bind:class="{ 'active': staffSelectionVisible }">
    <a href="#close" class="modal-overlay" aria-label="Close" v-on:click="toggleStaffSelectionPane($event)"></a>
    <div class="modal-container">
      <div class="modal-header">
        <a href="#close" class="btn btn-clear float-right" aria-label="Close" v-on:click="toggleStaffSelectionPane($event)"></a>
        <div class="modal-title h5">Besetzung</div>
      </div>
      <div class="modal-body">
        <div class="content">
          <div class="staff" v-for="staff in oldStaves">
            <StaffSelectionItem v-bind:work="1" v-bind:staff="staff"/>
          </div>
          <hr/>
          <div class="staff" v-for="staff in newStaves">
            <StaffSelectionItem v-bind:work="2" v-bind:staff="staff"/>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button v-on:click="toggleStaffSelectionPane($event)" class="btn btn-sm cancelBtn">cancel</button>
        <button v-on:click="acceptStaffSelection($event)" class="btn btn-sm btn-primary">adjust score</button>
      </div>
    </div>

  </div>
</template>

<script>

import StaffSelectionItem from '@/components/StaffSelectionItem.vue'

export default {
  name: 'StaffSelectionModal',
  components: {
    StaffSelectionItem
  },
  methods: {
    toggleStaffSelectionPane: function(e) {
      this.$store.dispatch('rejectProposedStaffSetup')
      this.$store.dispatch('deactivateStaffSelection')
      e.preventDefault()
    },
    acceptStaffSelection: function(e) {
      this.$store.dispatch('acceptProposedStaffSetup')
      this.$store.dispatch('deactivateStaffSelection')
      e.preventDefault()
    }
  },
  computed: {
    staffSelectionVisible: function() {
      return this.$store.getters.staffSelectionVisible
    },
    oldStaves: function() {
      return this.$store.getters.oldStaves
    },
    newStaves: function() {
      return this.$store.getters.newStaves
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  #searchPane {
    flex: 0 0 auto;
    background-color: #f5f5f5;
    border-bottom: .5px solid #999999;
    padding: 10px 20px;
    text-align: left;
  }

  .staff {
    text-align: left;
  }

  .cancelBtn {
    margin-right: .2rem;
  }
</style>
