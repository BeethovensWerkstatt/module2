<template>
  <div id="analysisPlain">
    <div id="svgContainer"></div>
  </div>
</template>

<script>

import VerovioBaseComponent from './VerovioBaseComponent.vue'

let paintableEvents = '#svgContainer .note, #svgContainer .rest, #svgContainer .slur'

export default {
  name: 'AnalysisPlain',
  extends: VerovioBaseComponent,
  components: {

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
      console.log('clicked note')

      let note = e.currentTarget
      note.classList.add('color1')
      /* note.style.fill = colors[activeColor];
      note.style.stroke = colors[activeColor];

      coloredNotes[note.id] = activeColor;  */
    },

    addPageListeners: function() {
      let notes = document.querySelectorAll(paintableEvents)
      notes.forEach((note,index,list) => {
        note.addEventListener('click',this.clickNote,false)
      })
/*
      //re-add colors
      for (let noteId in coloredNotes) {
        try {
          let note = document.querySelector('#svgContainer #' + noteId);
          let colorIndex = coloredNotes[noteId];

          note.classList.add('color' + colorIndex);
          note.style.fill = colors[colorIndex];
          note.style.stroke = colors[colorIndex];

        } catch(err) {
          //console.log('[ERROR] Unable to (re-)color note ' + noteId + ': ' + err);
        }
      }    */

    },

    removePageListeners: function() {
        let notes = document.querySelectorAll(paintableEvents)
        notes.forEach((note,index,list) => {
            note.removeEventListener('click',this.clickNote,false)
        })
        console.log('removed ' + notes.length + ' event listeners')
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss">
  #svgContainer .color1 {
    fill: #ff0000;
    stroke: #ff0000;
  }
</style>
