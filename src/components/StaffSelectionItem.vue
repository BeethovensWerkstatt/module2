<template>
  <div class="form-group">
    <label class="form-switch">
      <input v-bind:checked="checked" v-on:change.prevent="change($event)" type="checkbox">
      <i class="form-icon"></i> {{staff.n}}: {{staff.label}}
    </label>
  </div>
</template>

<script>

export default {
  name: 'StaffSelectionItem',
  props: {
    staff: Object,
    work: Number
  },
  methods: {
    change: function(e) {

      try {
        if (e.target.checked) {
          // console.log('need to enable now')
          this.$store.dispatch('proposeEnabledStaff', {work: this.$props.work, staff:  this.$props.staff.n})
        } else {
          // console.log('need to disable now')
          this.$store.dispatch('proposeDisabledStaff', {work: this.$props.work, staff:  this.$props.staff.n})
        }
      } catch(err) {
        // console.log('unable to change staff: ' + err + ' (' + this.$props.work + ',' + this.$props.staff.n + ')')
      }

      if (!e.target.checked) {
        let work = this.$props.work
        let staff = this.$props.staff.n
        let disabled = this.$store.getters.proposedDisabledStaves
        let disabledWork1 = disabled[0]
        let disabledWork2 = disabled[1]
        let relevantDisabled = (work === 1) ? disabledWork1 : disabledWork2
        if (relevantDisabled.indexOf(staff) === -1) {
          // if this staff could not be disabled, re-check the checkbox
          e.target.checked = true
        }
      }
    }
  },
  computed: {
    checked: function() {
      let work = this.$props.work
      let staff = this.$props.staff.n
      let disabled = this.$store.getters.proposedDisabledStaves
      let disabledWork1 = disabled[0]
      let disabledWork2 = disabled[1]
      let relevantDisabled = (work === 1) ? disabledWork1 : disabledWork2
      // console.log('correct setting for work ' + work + ', staff ' + staff + ' is ' + (relevantDisabled.indexOf(staff) === -1))
      return (relevantDisabled.indexOf(staff) === -1)
    }
  }

}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
