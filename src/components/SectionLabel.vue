<!-- describes the style of the labels in the navigationBox -->

<template>
  <div class="sectionLabel">
    <h1>{{ label }}</h1>
  </div>
</template>

<script>
export default {
  name: 'SectionLabel',
  props: {
    label: String
  }
}
</script>


<style lang="scss">
.sectionLabel h1 {
  font-size: 1.2rem;
  text-align: left;
}
</style>
