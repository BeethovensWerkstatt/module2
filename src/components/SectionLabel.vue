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

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss">
.sectionLabel h1 {
  font-size: 1.2rem;
  text-align: left;
}
</style>
