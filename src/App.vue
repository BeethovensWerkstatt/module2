<template>
  <div id="app">
    <AppHeader/>
    <Loading/>
    <router-view/>
  </div>
</template>

<script>
// @ is an alias to /src
import AppHeader from '@/components/AppHeader.vue'
import Loading from '@/components/Loading.vue'

export default {
  name: 'home',
  components: {
    AppHeader,
    Loading
  }
}
</script>

<style lang="scss">

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;

}

</style>
