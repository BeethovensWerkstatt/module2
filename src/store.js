import Vue from 'vue'
import Vuex from 'vuex'

// const api = process.env.VUE_APP_DATA_BACKEND_URL
const api = 'https://dev.beethovens-werkstatt.de/'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    comparisonsLoaded: false,
    comparisons: {},
    activeComparison: -1,
    activeMovement: 0, // first mdiv
    mode: null, // default comparison?
    zoom: 1,
    measure: null,
    navigationVisible: true // this is the sidebar with work and mode selection
  },
  mutations: {
    FETCH_COMPARISONLIST (state, comparisons) {
      console.log('got something: ' + typeof comparisons)
      console.log(comparisons)
      comparisons.forEach(comparison => {
        const created = {}
        created[comparison.id] = comparison
        state.comparisons = Object.assign({}, state.comparisons, created)
        // this.dispatch('fetchOutputs', comparison.id).then(() => {})
      })
      state.dataLoaded = true
    }
  },
  actions: {
    fetchComparisons ({ commit }) {
      console.log('hello polly')
      return new Promise(resolve => {
        console.log('Fetching available comparisons…')
        fetch(api + 'resources/xql/getComparisonListing.xql')
          .then(response => response.json()) // add error handling for failing requests
          .then(comparisons => {
            commit('FETCH_COMPARISONLIST', comparisons)
            resolve()
          })
      })
    }

  },
  getters: {
    comparisons: state => {
      const keys = Object.keys(state.comparisons)
      const values = []
      for (const key of keys) {
        values.push(state.comparisons[key])
      }
      return values
    },
    comparison: state => id => {
      return state.comparisons[id]
    }
  }
})
