import Vue from 'vue'
import Vuex from 'vuex'

import modeConfiguration from './../modeConfiguration.json'

const environment = 'local' // 'local' or 'live'

// const api = process.env.VUE_APP_DATA_BACKEND_URL
// const api = 'https://dev.beethovens-werkstatt.de/'
// const api = 'http://localhost:8080/exist/apps/bw-module2/'

const api = (environment === 'local') ? 'http://localhost:8080/exist/apps/bw-module2/' : 'https://dev.beethovens-werkstatt.de/'

const buildRequest = (comparison, methodLink, mdiv, transpose) => {
  let disabledStavesWork1 = []
  let disabledStavesWork2 = []
  mdiv.staves.filter(staff => staff.disabled === true).forEach(staff => disabledStavesWork1.push(staff.n))
  mdiv.newStaves.filter(staff => staff.disabled === true).forEach(staff => disabledStavesWork2.push(staff.n))

  let staffParam = (disabledStavesWork1.length > 0 || disabledStavesWork2.length > 0) ? ('?hideStaves=' + disabledStavesWork1.join() + '-' + disabledStavesWork2.join()) : ''
  // return 'resources/xql/getAnalysis.xql?comparisonId=' + comparison + '&method=' + method + '&mdiv=' + mdiv + '&transpose=' + transpose
  return 'data/' + comparison + '/mdiv/' + mdiv.n + '/transpose/' + transpose + '/' + methodLink + '.xml' + staffParam
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
    loading: [],
    networkErrorMsg: null,
    navigationVisible: true, // this is the sidebar with work and mode selection
    staffSelectionVisible: false,
    proposedDisabledStaves: [[], []],
    transposeSelectionVisible: false,
    proposedTranspose: 'none',
    comparisonDetailedColoration: false,
    search: {
      active: false,
      selectionStarted: false,
      selectedIDs: [],
      pitchMode: 'strict'
    },
    customHighlighting: {
      currentColor: 1,
      showHighlighting: false
    },
    melodicOptions: {
      showDots: true,
      showDurations: true,
      showLines: false
    }
    // searchPaneVisible: false,
    // searchSelectionActive: false
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
    SHOW_NAVIGATION (state) {
      state.navigationVisible = true
    },
    HIDE_NAVIGATION (state) {
      state.navigationVisible = false
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
    ACTIVATE_TRANSPOSE_SELECTION (state) {
      state.transposeSelectionVisible = true
    },
    DEACTIVATE_TRANSPOSE_SELECTION (state) {
      state.transposeSelectionVisible = false
    },
    SET_PROPOSED_TRANSPOSE (state, transpose) {
      state.proposedTranspose = transpose
    },
    ACCEPT_PROPOSED_TRANSPOSE (state) {
      state.transpose = state.proposedTranspose
    },
    REJECT_PROPOSED_TRANSPOSE (state) {
      state.proposedTranspose = state.transpose
    },
    CACHE_REQUEST (state, { request, mei }) {
      // state.cachedRequests[request] = mei
      let newEntry = {}
      newEntry[request] = mei
      state.cachedRequests = Object.assign({}, state.cachedRequests, newEntry)
    },
    START_LOADING (state, request) {
      // see if request is on the list already, then remove from old position
      let index = state.loading.indexOf(request)
      if (index !== -1) {
        state.loading.splice(index, 1)
      }
      // add new request to end of list
      state.loading.push(request)
    },
    STOP_LOADING (state, request) {
      // identify current request and remove it from array
      let index = state.loading.indexOf(request)
      if (index !== -1) {
        state.loading.splice(index, 1)
      }
    },
    SHOW_NETWORK_ERROR (state, msg) {
      state.networkErrorMsg = msg
      // this is a dead end for now, with no way to get out of this state
    },
    SHOW_SEARCH_PANE (state) {
      state.search = { ...state.search, active: true }
    },
    HIDE_SEARCH_PANE (state) {
      state.search = { ...state.search, active: false }
    },
    ACTIVATE_SEARCH_SELECTION (state) {
      state.search = { ...state.search, selectionStarted: true }
    },
    DEACTIVATE_SEARCH_SELECTION (state) {
      state.search = { ...state.search, selectionStarted: false }
    },
    TOGGLE_COMPARISON_DETAILED_COLORATION (state) {
      state.comparisonDetailedColoration = !state.comparisonDetailedColoration
    },
    ACTIVATE_STAFF_SELECTION (state) {
      state.staffSelectionVisible = true
    },
    DEACTIVATE_STAFF_SELECTION (state) {
      state.staffSelectionVisible = false
    },
    PROPOSE_DISABLE_STAFF (state, payload) {
      let disabledWork1 = [...state.proposedDisabledStaves[0]]
      let disabledWork2 = [...state.proposedDisabledStaves[1]]

      let staff = payload.staff
      let activeMovement = state.comparisons[state.activeComparison].movements[state.activeMovement - 1]

      let staffCount = (payload.work === 1) ? activeMovement.staves.length : activeMovement.newStaves.length
      let alreadyDisabledStaves = (payload.work === 1) ? disabledWork1 : disabledWork2

      let canBeOmitted = (alreadyDisabledStaves.length < (staffCount - 1)) && (alreadyDisabledStaves.indexOf(staff) === -1)

      if (canBeOmitted) {
        alreadyDisabledStaves.push(staff)
        let newState = (payload.work === 1) ? [alreadyDisabledStaves, disabledWork2] : [disabledWork1, alreadyDisabledStaves]
        // console.log(newState)
        state.proposedDisabledStaves = newState
      }
    },
    PROPOSE_ENABLE_STAFF (state, payload) {
      let disabledWork1 = [...state.proposedDisabledStaves[0]]
      let disabledWork2 = [...state.proposedDisabledStaves[1]]

      let staff = payload.staff
      let disabledStaves = (payload.work === 1) ? disabledWork1 : disabledWork2

      let pos = disabledStaves.indexOf(staff)
      // console.log('enabling ' + staff + ' at pos ' + pos)
      if (pos !== -1) {
        disabledStaves.splice(pos, 1)
        let newState = (payload.work === 1) ? [disabledStaves, disabledWork2] : [disabledWork1, disabledStaves]
        // console.log(newState)
        state.proposedDisabledStaves = newState
      }
    },
    ACCEPT_PROPOSED_STAFF_SETUP (state) {
      // let newMovement = Object.assing({}, )

      let comparisons = { ...state.comparisons }

      // not sure if the following is really necessary
      comparisons = JSON.parse(JSON.stringify(comparisons))

      let mdiv = comparisons[state.activeComparison].movements[state.activeMovement - 1]
      mdiv.staves.forEach(staff => {
        staff.disabled = state.proposedDisabledStaves[0].indexOf(staff.n) !== -1
      })
      mdiv.newStaves.forEach(staff => {
        staff.disabled = state.proposedDisabledStaves[1].indexOf(staff.n) !== -1
      })

      state.comparisons = comparisons
    },
    REJECT_PROPOSED_STAFF_SETUP (state) {
      try {
        let oldStaves = state.comparisons[state.activeComparison].movements[state.activeMovement - 1].staves
        let newStaves = state.comparisons[state.activeComparison].movements[state.activeMovement - 1].newStaves
        let oldArr = []
        let newArr = []

        oldStaves.forEach(staff => {
          if (staff.disabled) {
            oldArr.push(staff.n)
          }
        })
        newStaves.forEach(staff => {
          if (staff.disabled) {
            newArr.push(staff.n)
          }
        })
        state.proposedDisabledStaves = [oldArr, newArr]
      } catch (err) {}
    },
    SET_CURRENT_HIGHTLIGHT_COLOR (state, num) {
      state.customHighlighting = { ...state.customHighlighting, currentColor: num }
    },
    TOGGLE_HIGHLIGHTING (state) {
      state.customHighlighting = { ...state.customHighlighting, showHighlighting: !state.customHighlighting.showHighlighting }
    },
    SET_CUSTOM_NOTE_COLOR (state, id) {
      let comparisonId = state.activeComparison
      let obj
      if (typeof state.customHighlighting[comparisonId] === 'undefined') {
        obj = state.customHighlighting[comparisonId] = {}
      } else {
        obj = state.customHighlighting[comparisonId]
      }
      obj = { ...obj }
      obj[id] = state.customHighlighting.currentColor
      let customHighlighting = { ...state.customHighlighting }
      customHighlighting[comparisonId] = obj
      state.customHighlighting = customHighlighting
    },
    TOGGLE_MELODIC_DOTS (state) {
      let value = state.melodicOptions.showDots
      if (!value || state.melodicOptions.showDurations || state.melodicOptions.showLines) {
        let newOpts = { ...state.melodicOptions, showDots: !value }
        state.melodicOptions = newOpts
      }
    },
    TOGGLE_MELODIC_DURATIONS (state) {
      let value = state.melodicOptions.showDurations
      if (!value || state.melodicOptions.showDots || state.melodicOptions.showLines) {
        let newOpts = { ...state.melodicOptions, showDurations: !value }
        state.melodicOptions = newOpts
      }
    },
    TOGGLE_MELODIC_LINES (state) {
      let value = state.melodicOptions.showLines
      if (!value || state.melodicOptions.showDurations || state.melodicOptions.showDots) {
        let newOpts = { ...state.melodicOptions, showLines: !value }
        state.melodicOptions = newOpts
      }
    }
  },
  actions: {
    fetchComparisons ({ commit }) {
      return new Promise(resolve => {
        let request = 'resources/xql/getComparisonListing.xql'
        commit('START_LOADING', request)
        fetch(api + request)
          .then(response => {
            if (response.status !== 200) {
              console.log('why here?')
              throw Error(response.statusText)
            }
            return response.json()
          })
          .then(comparisons => {
            commit('FETCH_COMPARISONLIST', comparisons)
            commit('STOP_LOADING', request)
            resolve()
          })
          .catch(error => {
            commit('SHOW_NETWORK_ERROR', error)
            resolve()
          })
      })
    },
    fetchMEI ({ commit, state }) {
      let movement

      try {
        movement = state.comparisons[state.activeComparison].movements[state.activeMovement - 1]
      } catch (err) {
        return null
      }

      let request = buildRequest(state.activeComparison, state.modes[state.activeMode].apiLink, movement, state.transpose)

      // console.log('fetching has started')
      return new Promise(resolve => {
        if (state.activeComparison === null) {
          // request isn't complete yet
          // console.log('no comparison has been selected yet, so data cannot be loaded')
          resolve()
        } else if (typeof state.cachedRequests[request] !== 'undefined') {
          // resource has been loaded already, no action required
          // console.log('resource has been loaded already, no action required')
          resolve()
        } else {
          // resource needs to be loaded
          // console.log('// resource needs to be loaded')
          commit('START_LOADING', request)
          fetch(api + request)
            .then(response => {
              if (!response.ok) {
                throw Error(response.statusText)
              }
              return response.text()
            })
            .then(mei => {
              /* if (state.loading[state.loading.length - 1] === request) {
                // accept only the last requested file -> problem: other loaded data is not preserved. It should work anyway?
                commit('CACHE_REQUEST', { request, mei })
              } */
              commit('CACHE_REQUEST', { request, mei })
              commit('STOP_LOADING', request)
              resolve()
            })
            .catch(error => {
              commit('SHOW_NETWORK_ERROR', error)
              resolve()
            })
        }
      })
    },
    activateComparison ({ commit }, id) {
      // todo: check if comparison with that id is available
      commit('ACTIVATE_COMPARISON', id)
      commit('SET_PAGE', 1)
      commit('REJECT_PROPOSED_STAFF_SETUP')
    },
    activateMovement ({ commit }, n) {
      commit('ACTIVATE_MOVEMENT', n)
      commit('SET_PAGE', 1)
      commit('REJECT_PROPOSED_STAFF_SETUP')
    },
    activateMode ({ commit }, id) {
      // todo: check if mode with that id is available
      commit('ACTIVATE_MODE', id)
      commit('SET_PAGE', 1)
    },
    displayIntro ({ commit }, id) {
      // todo: load HTML snippet from server
      commit('DISPLAY_INTRO')
    },
    hideIntro ({ commit }) {
      commit('HIDE_INTRO')
    },
    showNavigation ({ commit }) {
      commit('SHOW_NAVIGATION')
    },
    hideNavigation ({ commit }) {
      commit('HIDE_NAVIGATION')
    },
    setPage ({ commit, state }, n) {
      let num = parseInt(n, 10)
      if (!isNaN(num) && num >= 1 && num <= state.currentMaxPage) {
        commit('SET_PAGE', num)
      } else if (!isNaN(num) && num > state.currentMaxPage) {
        // if the requested page numer is too high, load last page instead
        commit('SET_PAGE', state.currentMaxPage)
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
    setTranspose ({ commit }, transpose) {
      commit('SET_TRANSPOSE', transpose)
    },
    setProposedTranspose ({ commit }, transpose) {
      commit('SET_PROPOSED_TRANSPOSE', transpose)
    },
    activateTransposeSelection ({ commit }) {
      commit('ACTIVATE_TRANSPOSE_SELECTION')
    },
    deactivateTransposeSelection ({ commit }) {
      commit('DEACTIVATE_TRANSPOSE_SELECTION')
    },
    acceptProposedTranspose ({ commit }) {
      commit('ACCEPT_PROPOSED_TRANSPOSE')
    },
    rejectProposedTranspose ({ commit }) {
      commit('REJECT_PROPOSED_TRANSPOSE')
    },
    showSearchPane ({ commit }) {
      commit('SHOW_SEARCH_PANE')
    },
    hideSearchPane ({ commit }) {
      commit('HIDE_SEARCH_PANE')
    },
    activateSearchSelection ({ commit }) {
      commit('ACTIVATE_SEARCH_SELECTION')
    },
    deactivateSearchSelection ({ commit }) {
      commit('DEACTIVATE_SEARCH_SELECTION')
    },
    toggleComparisonDetailedColoration ({ commit }) {
      commit('TOGGLE_COMPARISON_DETAILED_COLORATION')
    },
    activateStaffSelection ({ commit }) {
      commit('ACTIVATE_STAFF_SELECTION')
    },
    deactivateStaffSelection ({ commit }) {
      commit('DEACTIVATE_STAFF_SELECTION')
    },
    acceptProposedStaffSetup ({ commit }) {
      commit('ACCEPT_PROPOSED_STAFF_SETUP')
    },
    rejectProposedStaffSetup ({ commit }) {
      commit('REJECT_PROPOSED_STAFF_SETUP')
    },
    proposeEnabledStaff ({ commit }, payload) {
      commit('PROPOSE_ENABLE_STAFF', payload)
    },
    proposeDisabledStaff ({ commit }, payload) {
      commit('PROPOSE_DISABLE_STAFF', payload)
    },
    setCurrentHighlightColor ({ commit }, num) {
      commit('SET_CURRENT_HIGHTLIGHT_COLOR', num)
    },
    toggleHighlighting ({ commit }) {
      commit('TOGGLE_HIGHLIGHTING')
    },
    setCustomNoteColor ({ commit }, id) {
      commit('SET_CUSTOM_NOTE_COLOR', id)
    },
    toggleMelodicDots ({ commit }) {
      commit('TOGGLE_MELODIC_DOTS')
    },
    toggleMelodicDurations ({ commit }) {
      commit('TOGGLE_MELODIC_DURATIONS')
    },
    toggleMelodicLines ({ commit }) {
      commit('TOGGLE_MELODIC_LINES')
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
    activeMovementObject: state => {
      if (state.activeComparison === null) {
        return null
      }
      return state.comparisons[state.activeComparison].movements[state.activeMovement - 1]
    },
    oldStaves: state => {
      if (state.activeComparison === null) {
        return []
      }
      try {
        return state.comparisons[state.activeComparison].movements[state.activeMovement - 1].staves
      } catch (err) {
        console.log('oldStaves is err: ' + err + ' | state.activeMovement: ' + state.activeMovement + ' | state.activeComparison: ' + state.activeComparison)
        return []
      }
    },
    newStaves: state => {
      if (state.activeComparison === null) {
        return []
      }
      try {
        return state.comparisons[state.activeComparison].movements[state.activeMovement - 1].newStaves
      } catch (err) {
        console.log('newStaves is err: ' + err + ' | state.activeMovement: ' + state.activeMovement + ' | state.activeComparison: ' + state.activeComparison)
        return []
      }
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
    proposedTranspose: state => {
      return state.proposedTranspose
    },
    introVisible: state => {
      return state.introVisible
    },
    navigationVisible: state => {
      return state.navigationVisible
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

      let movement

      try {
        movement = state.comparisons[state.activeComparison].movements[state.activeMovement - 1]
      } catch (err) {
        return null
      }

      let request = buildRequest(state.activeComparison, state.modes[state.activeMode].apiLink, movement, state.transpose)

      return request
    },
    currentMEI: state => {
      if (state.activeComparison === null) {
        return null
      }

      if (state.activeMode === null) {
        return null
      }

      let movement

      try {
        movement = state.comparisons[state.activeComparison].movements[state.activeMovement - 1]
      } catch (err) {
        return null
      }

      let request = buildRequest(state.activeComparison, state.modes[state.activeMode].apiLink, movement, state.transpose)

      if (typeof state.cachedRequests[request] === 'undefined') {
        return null
      }

      return state.cachedRequests[request]
    },
    currentlyLoading: state => {
      if (state.loading.length === 0) {
        return null
      } else if ((state.activeComparison === null || state.activeMode === null) && state.loading[0] === 'resources/xql/getComparisonListing.xql') {
        return 'loading data'
      } else if (state.activeComparison !== null && typeof state.comparisons[state.activeComparison] !== 'undefined') {
        // let comp = state.comparisons[state.activeComparison]
        // return comp.title + ' ' + comp.target
        return 'loading data'
      } else {
        // this case should not happen
        return 'loading data'
      }
      // todo: find mechanism to automatically notify admin (and tell that to the user)
    },
    loadingError: state => {
      return state.networkErrorMsg
    },
    searchPaneVisible: state => {
      return state.search.active
    },
    searchSelectionActive: state => {
      return state.search.selectionStarted
    },
    staffSelectionVisible: state => {
      return state.staffSelectionVisible
    },
    transposeSelectionVisible: state => {
      return state.transposeSelectionVisible
    },
    proposedDisabledStaves: state => {
      return state.proposedDisabledStaves
    },
    comparisonDetailedColoration: state => {
      return state.comparisonDetailedColoration
    },
    currentHighlightColor: state => {
      return state.customHighlighting.currentColor
    },
    highlightingVisible: state => {
      return state.customHighlighting.showHighlighting
    },
    highlightedNotes: state => {
      return state.customHighlighting[state.activeComparison]
    },
    showMelodicDots: state => {
      return state.melodicOptions.showDots
    },
    showMelodicDurations: state => {
      return state.melodicOptions.showDurations
    },
    showMelodicLines: state => {
      return state.melodicOptions.showLines
    }
  }
})
