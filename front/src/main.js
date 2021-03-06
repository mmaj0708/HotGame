import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import vuetify from './plugins/vuetify'
import VueMetamask from 'vue-metamask';
import axios from 'axios'
import VueAxios from 'vue-axios'
// import Web3 from 'web3'


Vue.config.productionTip = false

Vue.prototype.$http = axios;

Vue.use(VueMetamask);
Vue.use(VueAxios, axios);

// axios.defaults.baseURL = "http://" + location.hostname + ":" + 3000;


new Vue({
  router,
  store,
  vuetify,
  render: h => h(App)
}).$mount('#app')
