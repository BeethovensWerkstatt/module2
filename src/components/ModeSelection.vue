<template>
  <div id="modeSelector">
    <SectionLabel label="Modus"/>
    <ul class="navigationList">

      <li class="modeBtn" v-for="mode in modes" v-bind:id="mode.id" v-bind:class="{active: (mode.id === activeModeId)}" v-on:click="activateMode(mode.id)">
        {{mode.label.de}}
      </li>
    </ul>
  </div>
</template>

<script>

import SectionLabel from '@/components/SectionLabel.vue'

export default {
  name: 'ModeSelection',
  components: {
    SectionLabel
  },
  computed: {
    modes: function() {
      return this.$store.getters.modes
    },
    activeModeId: function() {
      return this.$store.getters.activeModeId
    },
    activeModeObject: function() {
      return this.$store.getter.activeModeObject
    }
  },
  methods: {
    activateMode (id) {
      this.$store.dispatch('activateMode',id)
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

ul.navigationList {
                list-style-type: none;
                margin: 0;
                padding: 0;

                li {
                    padding: .3em;
                    font-weight: 300;
                    position: relative;
                    cursor: pointer;
                    border: .5px solid #666666;
                    border-radius: 8px;
                    background-color: #e5e5e5;

                    span.originalVersion {
                        display: block;
                    }

                    span.targetVersion {
                        display: block;
                        font-size: 90%;
                        margin-left: 1em;
                    }

                    &.active {

                        font-weight: 500;
                        background-color: #a7c7f2;
                        /*&:before {
                            position: absolute;
                            left: .2em;
                            content: '‣'
                        }*/
                    }
                  }
}

</style>
