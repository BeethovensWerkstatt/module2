import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

import './../node_modules/spectre.css/dist/spectre.min.css'
import './../node_modules/spectre.css/dist/spectre-exp.min.css'
import './../node_modules/spectre.css/dist/spectre-icons.min.css'

// this allows verovio as global variable, c.f. https://forum.vuejs.org/t/single-file-component-how-to-access-imported-library-in-template/8850/2
// this seems to be extremely slow while development, as it tries to compile Verovio every time…
/* import vrvToolkit from './verovio.js'
Vue.prototype.$verovio = vrvToolkit */

// const vrvToolkit = new verovio.toolkit()

// const verovio = require('../node_modules/verovio-dev/index.js').init(256)
// const verovio = require('./verovio.js').init(256)
const vrvToolkit = new verovio.toolkit()
Vue.prototype.$verovio = vrvToolkit

Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')

store.dispatch('fetchComparisons')
