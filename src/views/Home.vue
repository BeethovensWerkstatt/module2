<template>
  <div class="home">
    <img alt="Vue logo" src="../assets/logo.png">
    <HelloWorld msg="Welcome to Your Vue.js App"/>
    <ModeSelection/>
  </div>
</template>

<script>
// @ is an alias to /src
import HelloWorld from '@/components/HelloWorld.vue'
import ModeSelection from '@/components/ModeSelection.vue'

export default {
  name: 'home',
  components: {
    HelloWorld,
    ModeSelection
  }
}
</script>
