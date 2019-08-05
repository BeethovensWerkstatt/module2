import Vue from 'vue'
import Vuex from 'vuex'

import modeConfiguration from './../modeConfiguration.json'

// const api = process.env.VUE_APP_DATA_BACKEND_URL
const api = 'https://dev.beethovens-werkstatt.de/'
const buildRequest = (comparison, method, mdiv, transpose) => {
  return 'resources/xql/getAnalysis.xql?comparisonId=' + comparison + '&method=' + method + '&mdiv=' + mdiv + '&transpose=' + transpose
}

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    comparisonsLoaded: false,
    comparisons: {},
    activeComparison: null,
    activeMovement: 1, // first mdiv
    cachedRequests: {},
    modes: modeConfiguration,
    activeMode: null,
    transpose: 'none',
    zoom: 1,
    currentPage: 1,
    currentMaxPage: 10,
    measure: null,
    introVisible: false,
    navigationVisible: true // this is the sidebar with work and mode selection
  },
  mutations: {
    FETCH_COMPARISONLIST (state, comparisons) {
      comparisons.forEach(comparison => {
        const created = {}
        created[comparison.id] = comparison
        state.comparisons = Object.assign({}, state.comparisons, created)
        // this.dispatch('fetchOutputs', comparison.id).then(() => {})
      })
      state.comparisonsLoaded = true
    },
    ACTIVATE_COMPARISON (state, id) {
      state.activeComparison = id
      state.activeMovement = 1
    },
    ACTIVATE_MOVEMENT (state, n) {
      state.activeMovement = n
    },
    ACTIVATE_MODE (state, id) {
      state.activeMode = id
      state.currentPage = 1 // reset to page 1 when changing mode
    },
    DISPLAY_INTRO (state, id) {
      state.introVisible = true
    },
    HIDE_INTRO (state) {
      state.introVisible = false
    },
    SET_PAGE (state, n) {
      state.currentPage = n
    },
    SET_MAX_PAGE (state, n) {
      state.currentMaxPage = n
    },
    SET_TRANSPOSE (state, transpose) {
      state.transpose = transpose
    },
    CACHE_REQUEST (state, { request, mei }) {
      // state.cachedRequests[request] = mei
      let newEntry = {}
      newEntry[request] = mei
      state.cachedRequests = Object.assign({}, state.cachedRequests, newEntry)
    }
  },
  actions: {
    fetchComparisons ({ commit }) {
      return new Promise(resolve => {
        fetch(api + 'resources/xql/getComparisonListing.xql')
          .then(response => response.json()) // add error handling for failing requests
          .then(comparisons => {
            commit('FETCH_COMPARISONLIST', comparisons)
            resolve()
          })
      })
    },
    fetchMEI ({ commit, state }) {
      let request = buildRequest(state.activeComparison, state.activeMode, state.activeMovement, state.transpose)

      console.log('fetching has started')

      return new Promise(resolve => {
        if (state.activeComparison === null) {
          // request isn't complete yet
          console.log('no comparison has been selected yet, so data cannot be loaded')
          resolve()
        } else if (typeof state.cachedRequests[request] !== 'undefined') {
          // resource has been loaded already, no action required
          console.log('resource has been loaded already, no action required')
          resolve()
        } else {
          // resource needs to be loaded
          console.log('// resource needs to be loaded')
          fetch(api + request)
            .then(response => response.text()) // add error handling for failing requests
            .then(mei => {
              commit('CACHE_REQUEST', { request, mei })
              resolve()
            })
        }
      })
    },
    activateComparison ({ commit }, id) {
      // todo: check if comparison with that id is available
      commit('ACTIVATE_COMPARISON', id)
    },
    activateMovement ({ commit }, n) {
      commit('ACTIVATE_MOVEMENT', n)
    },
    activateMode ({ commit }, id) {
      // todo: check if mode with that id is available
      commit('ACTIVATE_MODE', id)
    },
    displayIntro ({ commit }, id) {
      // todo: load HTML snippet from server
      commit('DISPLAY_INTRO')
    },
    hideIntro ({ commit }) {
      commit('HIDE_INTRO')
    },
    setPage ({ commit, state }, n) {
      let num = parseInt(n, 10)
      if (!isNaN(num) && num >= 1 && num <= state.currentMaxPage) {
        commit('SET_PAGE', num)
      }
    },
    increasePage ({ commit, state }) {
      let num = state.currentPage + 1
      if (num >= 1 && num <= state.currentMaxPage) {
        commit('SET_PAGE', num)
      }
    },
    decreasePage ({ commit, state }) {
      let num = state.currentPage - 1
      if (num >= 1 && num <= state.currentMaxPage) {
        commit('SET_PAGE', num)
      }
    },
    setMaxPage ({ commit }, n) {
      commit('SET_MAX_PAGE', n)
    },
    setTranpose ({ commit }, transpose) {
      commit('SET_TRANSPOSE', transpose)
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
    },
    activeComparisonObject: state => {
      return state.comparisons[state.activeComparison]
    },
    activeComparisonId: state => {
      return state.activeComparison
    },
    activeMovement: state => {
      return state.activeMovement
    },
    modes: state => {
      const keys = Object.keys(state.modes)
      const values = []
      for (const key of keys) {
        values.push(state.modes[key])
      }
      return values
    },
    activeModeObject: state => {
      return state.modes[state.activeMode]
    },
    activeModeId: state => {
      return state.activeMode
    },
    transpose: state => {
      return state.transpose
    },
    introVisible: state => {
      return state.introVisible
    },
    currentPage: state => {
      return state.currentPage
    },
    currentRequest: state => {
      if (state.activeComparison === null) {
        return null
      }

      if (state.activeMode === null) {
        return null
      }

      let request = buildRequest(state.activeComparison, state.activeMode, state.activeMovement, state.transpose)

      return request
    },
    currentMEI: state => {
      if (state.activeComparison === null) {
        return null
      }

      if (state.activeMode === null) {
        return null
      }

      let request = buildRequest(state.activeComparison, state.activeMode, state.activeMovement, state.transpose)

      return state.cachedRequests[request]
    }
  }
})
