<template>
  <header class="navbar">
      <section class="navbar-section">
          <a id="bwLogo" href="https://beethovens-werkstatt.de" class="navbar-brand mr-2">Beethovens Werkstatt</a>
      </section>
      <section class="navbar-center">
          <div>
              <div class="appTitle">Modul 2</div>
              <router-link to="/info" id="openModalBtn">info</router-link>
          </div>
      </section>
      <section class="navbar-section">
          <div id="noteID"></div>
          <a id="githubLogo" href="https://github.com/BeethovensWerkstatt/module2" target="_blank" class="btn btn-link">GitHub</a>
      </section>
  </header>
</template>

<script>
// @ is an alias to /src

export default {
  name: 'AppHeader',
  components: {

  }
}
</script>

<style scoped lang="scss">
  header {
      background-color: #e5e5e5;
      border-bottom: .5px solid #999999;
      padding: 10px 20px;

      #bwLogo {
          color: transparent;
          background-image: url('../assets/beethovensw_finale01.png');
          background-size: cover;
          height: 42px;
      }

      #openModalBtn {
          font-size: .8em;
          font-weight: 100;
          cursor: pointer;
          text-align: center;
      }

      #noteID {
          margin-right: 1em;
          opacity: .6;
          font-size: .7em;
          font-weight: 100;
          text-align: left;
      }

      #githubLogo {
          color: transparent;
          background-image: url('../assets/GitHub-Mark-120px-plus.png');
          background-size: 32px 32px;
          background-repeat: no-repeat;
      }
}
</style>
