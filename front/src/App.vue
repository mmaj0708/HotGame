<template>
  <v-app>
    <v-app-bar app dark class="container-fluid">
      <div class="d-flex d-flex flex-row">
        <v-toolbar-title>
          <v-btn id="bigTitle" to="/" tile text x-large class="mr-5 pa-1" style="font-size: 30px">
            HOT.IO <v-icon>mdi-fire</v-icon>
          </v-btn>
          <v-btn id="littleTitle" to="/" tile text class="mr-2" style="font-size: 30px">
            <v-icon>mdi-fire</v-icon>
          </v-btn>
        </v-toolbar-title>
      </div>

        <v-menu open-on-hover bottom offset-y>
          <template v-slot:activator="{ on, attrs }">
            <v-btn color="green" dark v-bind="attrs" v-on="on">
              BET
            </v-btn>
          </template>

          <v-list>
			SOON!
            <!-- <v-list-item>
                <v-btn color="green" to="/browser">
                  Browse Games
                </v-btn>
            </v-list-item>
            <v-list-item>
                <v-btn color="green" to="/create">
                  Create Game
                </v-btn>
            </v-list-item>
            <v-list-item>
				<v-btn color="green" to="/history">
                  History
				</v-btn>
            </v-list-item> -->
          </v-list>
        </v-menu>

        <v-menu open-on-hover bottom offset-y>
          <template v-slot:activator="{ on, attrs }">
            <v-btn class="ml-2" to="/browser" color="primary" dark v-bind="attrs" v-on="on">
              test
            </v-btn>
          </template>

          <v-list>
            <v-list-item>
                <v-btn color="primary" to="/browser">
                  Browse Games
                </v-btn>
            </v-list-item>
            <v-list-item>
                <v-btn color="primary" to="/create">
                  Create Game
                </v-btn>
            </v-list-item>
            <v-list-item>
				<v-btn color="primary" to="/history">
                  History
				</v-btn>
            </v-list-item>
          </v-list>
        </v-menu>

      <v-spacer></v-spacer>

      <v-btn id="connectWallet" v-if="!isUserAccount" class="ml-1" :disabled="disabled" :loading="loading" @click="connectWallet" color="primary">
        connect wallet
      </v-btn>
      <v-btn elevation="0" v-if="isUserAccount" tile text color="primary">
        {{this.$store.state.userAccount.slice(0, 5) + '...' + this.$store.state.userAccount.slice(38)}}
      </v-btn>

    </v-app-bar>

    <v-main>
      <router-view/>
    </v-main>

    <v-footer padless>
      <v-col class="text-center" cols="12">
        {{ new Date().getFullYear() }} — <strong>Hot Games </strong>
        <v-btn :disabled="acc != '0x08e01f14587a80ded1f1180a6c883c42a7c20913'" @click="setFee()" height="15" width="90" style="font-size: 10px;"> chainlink fee</v-btn>
      </v-col>
      
    </v-footer>

  </v-app>
</template>

<script>
import detectEthereumProvider from '@metamask/detect-provider';
import Web3 from 'web3';
import BN from 'bn.js';

export default {
  name: 'App',
  components: {
  },
  data: () => ({
    provider: null,
    web3: null,
    hotContract: null,
    acc: null,
    loader: null,
    loading: false,
    disabled: false,
    disabledSetFee: false,
  }),
  methods: {
    connectWallet() {
        this.loading = true;
        this.disabled = true;
        window.ethereum.request({ method: 'eth_requestAccounts' });
    },

    async setFee() {
      let errCode;

      const transactionParameters = {
      nonce: '0x00',
      gasPrice:25000000000,
      gas: new BN('210000', 16),
      to: this.$store.getters.getTestNetContractAddr,
      from: window.ethereum.selectedAddress,
      value: 0x0,
      chainId: '0x3',
      };

      await this.hotContract.methods.setFee('1000000000000000').send(transactionParameters)
      .then((resp) => {
        console.log(resp);
        this.snackText = "transaction succeeded ! go refresh history to the result !"
        this.snackbar = true;
      })
      .catch((err) => errCode = err.code);

      setTimeout(()=> location.reload(), 3000);
      console.log(errCode);
    },

    handleChainChanged() {
      window.location.reload();
    },

    handleAccountsChanged(accounts) {
      console.log("account changed", accounts);
      if (accounts.length === 0) {
        console.log('Please connect to MetaMask.');
        this.disabled = false;
        this.loading = false;
        this.acc = null;

      } else {
        this.$store.commit('setUserAccount', accounts[0]);
        this.acc = accounts[0].toLowerCase();
      }
    },

    async initWeb3() {
      this.provider = await detectEthereumProvider();
      if (this.provider) {
        console.log('Ethereum successfully detected!')

        let newChainId = await this.provider.request({method: 'eth_chainId'});
        this.$store.commit('setChainId', newChainId);
      } else
        console.error('Please install MetaMask!')
      let userAccount = await window.ethereum.request({method: 'eth_accounts'});
      this.$store.commit('setUserAccount', userAccount[0]);
      this.acc = userAccount[0].toLowerCase();
    },

	isMobile() {
		console.log(navigator.userAgentData.mobile);
		return navigator.userAgentData.mobile;
	},
	isMetamask() {
		console.log(window.ethereum.isMetaMask);
		return window.ethereum.isMetaMask;
	},
  },
  computed: {
    userAccount() {
      return this.$store.getters.userAccount;
    },
    isUserAccount() {
      if (this.acc)
        return true;
      return false;
    },
  },

  async created() {
      document.title = "HOT GAMES";
      this.web3 = new Web3(window.ethereum);

      this.hotContract = new this.web3.eth.Contract(
      this.$store.getters.getTestNetContractABI, this.$store.getters.getTestNetContractAddr);

      await this.hotContract.methods.getFee().call().then((resp) => this.fee = resp);
    //   console.log(window.ethereum);

      await this.$http.get('https://api.coingecko.com/api/v3/coins/avalanche-2').then(resp => {
		this.$store.commit('setAvaxPrice', resp.data.market_data.current_price.usd);
      })

    this.initWeb3();
    window.ethereum.on('chainChanged', this.handleChainChanged);
    window.ethereum.on('accountsChanged', this.handleAccountsChanged);
  }
};
</script>

<style>

@media screen and (max-width: 600px) {
#bigTitle {
	display: none;
}
}

@media screen and (min-width: 600px) {
#littleTitle {
	display: none;
}

}

::-webkit-scrollbar-track
{
	-webkit-box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
	background-color: #F5F5F5;
}

::-webkit-scrollbar
{
	width: 10px;
	background-color: #F5F5F5;
}
</style>