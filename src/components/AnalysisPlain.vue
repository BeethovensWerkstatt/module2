<template>
  <div id="analysisPlain">
    <div id="viewSettings" v-if="highlightingVisible">
      <div class="viewSettingItem">
        Farbwahl:
      </div>
      <div class="viewSettingItem btn-group btn-group-block colorButtons">
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 1}" v-on:click="setCurrentColor(1)"><i class="fas fa-tint color1"></i></button>
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 2}" v-on:click="setCurrentColor(2)"><i class="fas fa-tint color2"></i></button>
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 3}" v-on:click="setCurrentColor(3)"><i class="fas fa-tint color3"></i></button>
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 4}" v-on:click="setCurrentColor(4)"><i class="fas fa-tint color4"></i></button>
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 5}" v-on:click="setCurrentColor(5)"><i class="fas fa-tint color5"></i></button>
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 6}" v-on:click="setCurrentColor(6)"><i class="fas fa-tint color6"></i></button>
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 7}" v-on:click="setCurrentColor(7)"><i class="fas fa-tint color7"></i></button>
        <button class="btn btn-action" v-bind:class="{'btn-primary': currentColor === 8}" v-on:click="setCurrentColor(8)"><i class="fas fa-tint color8"></i></button>
      </div>

      <!--<div class="viewSettingItem float-right">
        <div class="viewSettingDetail">Speichern / Laden</div>
        <div class="viewSettingDetail btn-group btn-group-block">
          <button class="btn btn-action"><i class="fas fa-download"></i></button>
          <button class="btn btn-action"><i class="fas fa-upload"></i></button>
        </div>
      </div>-->

    </div>
    <div id="svgContainer" v-bind:class="{'showColors': highlightingVisible}"></div>
  </div>
</template>

<script>

import VerovioBaseComponent from './VerovioBaseComponent.vue'
import SearchPane from './SearchPane.vue'

let paintableEvents = '#svgContainer .note, #svgContainer .rest, #svgContainer .slur'

export default {
  name: 'AnalysisPlain',
  extends: VerovioBaseComponent,
  components: {
    SearchPane
  },
  computed: {
    currentColor: function() {
      return this.$store.getters.currentHighlightColor
    },
    highlightingVisible: function() {
      return this.$store.getters.highlightingVisible
    }
  },
  methods: {
    renderPage: function(n) {

      this.removePageListeners()

      // this calls the parent method and allows to have view-specific actions following the page being loaded
      VerovioBaseComponent.methods.renderPage.call(this)

      // custom actions start here
      this.addPageListeners()
    },

    clickNote: function(e) {

      let note = e.currentTarget

      // copy ID to clipboard
      let ta = document.createElement('textarea')
    	ta.value = note.id
    	document.body.appendChild(ta)
    	ta.select()
    	document.execCommand('copy')
    	document.body.removeChild(ta)

      if (this.$store.getters.highlightingVisible) {
        let num = this.$store.getters.currentHighlightColor
        note.classList.remove('color1','color2','color3','color4','color5','color6','color7','color8')
        let className = 'color' + num
        note.classList.add(className)

        this.$store.dispatch('setCustomNoteColor',note.id)
      }
    },

    addPageListeners: function() {
      let notes = document.querySelectorAll(paintableEvents)
      notes.forEach((note,index,list) => {
        note.addEventListener('click',this.clickNote,false)
      })

      let coloredNotes = this.$store.getters.highlightedNotes

      //re-add colors
      for (let noteId in coloredNotes) {
        try {
          let note = document.querySelector('#svgContainer #' + noteId)
          let colorIndex = coloredNotes[noteId]
          note.classList.remove('color1','color2','color3','color4','color5','color6','color7','color8')

          note.classList.add('color' + colorIndex)

        } catch(err) {
          //console.log('[ERROR] Unable to (re-)color note ' + noteId + ': ' + err);
        }
      }

    },

    removePageListeners: function() {
        let notes = document.querySelectorAll(paintableEvents)
        notes.forEach((note,index,list) => {
            note.removeEventListener('click',this.clickNote,false)
        })
        console.log('removed ' + notes.length + ' event listeners')
    },
    setCurrentColor: function(num) {
      this.$store.dispatch('setCurrentHighlightColor',num);
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss">
  $color1: #000000;
  $color2: #92908c;
  $color3: #eee3ce;
  $color4: #26d6fc;
  $color5: #f4531b;
  $color6: #1b44f4;
  $color7: #859900;
  $color8: #d825da;

  #analysisPlain {
    position: relative;

    .colorButtons .btn-primary .fas {
      text-shadow: 0 0 .3rem #ffffff;

      &.color2, &.color3, &.color7 {
        text-shadow: 0 0 .3rem #000000;
      }
    }

    #svgContainer.showColors {
      .color1 {
        fill: $color1;
        stroke: $color1;
      }
      .color2 {
        fill: $color2;
        stroke: $color2;
      }
      .color3 {
        fill: $color3;
        stroke: $color3;
      }
      .color4 {
        fill: $color4;
        stroke: $color4;
      }
      .color5 {
        fill: $color5;
        stroke: $color5;
      }
      .color6 {
        fill: $color6;
        stroke: $color6;
      }
      .color7 {
        fill: $color7;
        stroke: $color7;
      }
      .color8 {
        fill: $color8;
        stroke: $color8;
      }
    }
  }

  #viewSettings {
    flex: 0 0 auto;
    background-color: #f5f5f5;
    border-bottom: .5px solid #999999;
    padding: 10px 20px;
    text-align: left;

    .color1 {
      color: $color1;
    }
    .color2 {
      color: $color2;
    }
    .color3 {
      color: $color3;
    }
    .color4 {
      color: $color4;
    }
    .color5 {
      color: $color5;
    }
    .color6 {
      color: $color6;
    }
    .color7 {
      color: $color7;
    }
    .color8 {
      color: $color8;
    }

    .viewSettingItem {
      display: inline-block;
      padding: 0 .5rem;
      margin-right: .5rem;
    }
  }
</style>
