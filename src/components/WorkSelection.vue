<template>
  <div id="workSelector">
    <SectionLabel label="Fassungsvergleiche"/>

    <div class="workContainer">

      <div class="workDetails">
        <div class="additionalInfo s-circle float-right">i</div>
        <div class="title">Klaviersonate E-Dur Op.14/1</div>
        <div class="subtitle">und Bearbeitung als Streichquartett F-Dur</div>
      </div>
      <div v-if="1 == 1" class="mdivSelection">
        <div class="mdiv">Allegro</div>
        <div class="mdiv active">Allegretto</div>
        <div class="mdiv">Rondo Allegro Comodo</div>
      </div>
    </div>

  </div>
</template>

<script>

import SectionLabel from '@/components/SectionLabel'

export default {
  name: 'WorkSelection',
  components: {
    SectionLabel
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

  $borderColor: #999999;

  .workContainer {
    margin: 0 .2rem .5rem;
    text-align: left;

    .workDetails {
      border: .5px solid $borderColor;
      border-radius: 8px;
      background-color: #f5f5f5;
      padding: .3rem;

      .additionalInfo {
        background-color: rgb(11, 148, 199);
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

    }

    .mdivSelection {
      margin: 0 .3rem 0 1rem;
      border-right: .5px solid $borderColor;
      border-bottom: .5px solid $borderColor;
      border-left: .5px solid $borderColor;

      .mdiv {
          padding: 0 .5rem;
          font-size: .7rem;
          cursor: pointer;

          &:hover {
            background-color: #e5e5e5;
          }

          &.active {
            background-color: rgb(11,148,199);
            font-weight: 700;
          }

          & + .mdiv {
            border-top: .5px solid $borderColor;
          }
      }

    }

  }


</style>
