import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
      fee: null,
      chainId: null,
      userAccount: null,
      contractInstance: null,
      avaxPrice: null
  },
  getters: {
    getUserAccount(state) {
      return state.userAccount;
    },
    getChainId(state) {
      return state.chainId;
    },
    getAvaxPrice(state) {
      return state.avaxPrice;
    }
  },
  mutations: {
    setUserAccount : (state, address) => {
      state.userAccount = address;
    },
    setChainId : (state, chainId) => {
      state.chainId = chainId;
    },
    setAvaxPrice : (state, price) => {
      state.avaxPrice = price;
    },
  },
  actions: {
  },
  modules: {
  }
})
