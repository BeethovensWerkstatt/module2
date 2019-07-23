<template>
  <div id="comparisonSelector">
    <SectionLabel label="Fassungsvergleiche"/>

    <div class="comparisonContainer" v-for="comparison in comparisons" v-bind="comparison">

      <div class="comparisonDetails" v-bind:class="{active: (comparison.id === activeComparisonId)}" v-on:click="activateComparison(comparison.id)">
        <div class="additionalInfo s-circle float-right" v-on:click="displayIntro(comparison.id)">i</div>
        <div class="title">{{comparison.title}}</div>
        <div class="subtitle">{{comparison.target}}</div>
      </div>
      <div v-if="comparison.id === activeComparisonId && comparison.movements.length != 1" class="mdivSelection">
        <div class="mdiv" v-for="mdiv in comparison.movements" v-bind:class="{active: (mdiv.n === activeMovement)}" v-on:click="activateMovement(mdiv.n)">{{mdiv.label}}</div>
      </div>
    </div>

  </div>
</template>

<script>

import SectionLabel from '@/components/SectionLabel'

export default {
  name: 'ComparisonSelection',
  components: {
    SectionLabel
  },
  computed: {
    comparisons: function() {
      return this.$store.getters.comparisons;
    },
    activeComparisonId: function() {
      return this.$store.getters.activeComparisonId;
    },
    activeMovement: function() {
      return this.$store.getters.activeMovement;
    }
  },
  methods: {
    activateComparison (id) {
      this.$store.dispatch('activateComparison',id)
    },
    activateMovement (n) {
      this.$store.dispatch('activateMovement',n)
    },
    displayIntro (id) {
      this.$store.dispatch('displayIntro',id)
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

  $borderColor: #999999;

  .comparisonContainer {
    margin: 0 .2rem .5rem;
    text-align: left;

    .comparisonDetails {
      border: .5px solid $borderColor;
      border-radius: 8px;
      background-color: #f5f5f5;
      padding: .3rem;


      .additionalInfo {
        background-color: #0864c3;
        color: #ffffff;
        width: 1rem;
        height: 1rem;
        text-align: center;
        font-style: italic;
        font-weight:700;
      }

      .title {
        font-weight: 500;
      }

      .subtitle {
        font-weight: 300;
        margin-left: .3rem;
      }

      &.active {
        background-color: #a7c7f2;
        font-weight: 700;
      }


    }

    .mdivSelection {
      margin: 0 .3rem 0 1rem;
      border-right: .5px solid $borderColor;
      border-bottom: .5px solid $borderColor;
      border-left: .5px solid $borderColor;
      border-radius: 8px;

      .mdiv {
          padding: 0 .5rem;
          font-size: .7rem;
          cursor: pointer;
          background-color: #f5f5f5;

          &:hover {
            background-color: #a7c7f2;
          }

          &.active {
            background-color: #a7c7f2;
            font-weight: 700;
          }

          & + .mdiv {
            border-top: .5px solid $borderColor;
          }
      }

    }

  }


</style>
