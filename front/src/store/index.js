import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    web3: {
      fee: null,
      chainId: null,
      userAccount: null,
      },
      contractInstance: null
  },
  getters: {
    getUserAccount(state) {
      return state.userAccount;
    },
    getChainId(state) {
      return state.chainId;
    }
  },
  mutations: {
    setUserAccount : (state, address) => {
      state.userAccount = address;
    },
    setChainId : (state, chainId) => {
      state.chainId = chainId;
    }
  },
  actions: {
  },
  modules: {
  }
})
