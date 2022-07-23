<template>
  <v-container>
  <v-card class="mx-auto">
    <v-container fluid>
		<h1 class="text-center mb-3">
			BET BROWSER
		</h1>
		<div class="text-center mb-5" style="font-size: 13px;">
			Once you played, game result can take few seconds, just be patient !
		</div>
      <v-card v-if="cards.length == 0">
        <div class="text-center"> NO GAMES CURRENTLY, BUT YOU CAN CREATE YOURS ! </div>
        <v-btn to="/create" color="blue" class="ml-2 d-flex justify-center"> CREATE! </v-btn>
		<div class="ml-1 mt-2">
			Please ensure :
			<ul>
				<li>You have metamask connected</li>
				<li>You selected the correct AVAX network </li>
				<li>Fuji Chain network is for testing</li>
				<li>Mobile device need to browse through Metamask Browser</li>
			</ul>
		</div>
      </v-card>
      <v-row v-else>
        <v-col cols="6" v-for="(card, index) in cards" :key="index">
          <v-card id="hotCard" width="100%" color="green" class="border">
			<div class="ml-2 text-subtitle-2"> {{card.gameSubmitTime}} </div>
            <v-img class="" src="../assets/bitcoin-token.jpg" height="200" gradient="to bottom, rgba(0,0,0,.3), rgba(0,0,0,.5)">
              <div>
                <div class="ml-4 mt-5 text-button">
                <v-icon>mdi-account </v-icon>
                <span style="font-size: 12px;"> {{card.gameSubmitter.slice(0, 5) + '...' + card.gameSubmitter.slice(38)}} </span>
              </div>
              <div class="text-subtitle-2 ml-5">
                for {{card.gamePrice}}
                <div style="display:inline-block"><v-img src="https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png" width="15px"></v-img> </div>
                (={{ (card.gamePrice * $store.getters.getAvaxPrice).toFixed(2) }}$)
              </div>
              <div class="text-subtitle-2 ml-5">
                ID: {{card.gameId.slice(0, 7) + '...' + card.gameId.slice(card.gameId.length - 5)}}
              </div>
              <v-card-subtitle class="mt-2">
                <v-btn v-if="acc" @click="playGame(card)" :disabled="disabled"
                  color="green"
                  class="mb-sm-5 mt-n5 ml-5">
                  PLAY
                </v-btn>
                <v-alert v-else> connect wallet </v-alert>
                  <v-dialog v-model="dialog" persistent width="300">
                    <v-card color="primary" dark>
                      <v-card-text>
                        Connecting to metamask, <br> fee are currently {{ fee * Math.pow(10, -18) }} AVAX
                        <v-progress-linear
                          indeterminate
                          color="white"
                          class="mb-0"
                        ></v-progress-linear>
                      </v-card-text>
                    </v-card>
                  </v-dialog>

                  <v-dialog v-model="claimDialog" persistent width="300">
                    <v-card color="primary" dark>
                      <v-card-text>
                        Connecting to metamask, <br> you will get your AVAX in no time !
                        <v-progress-linear
                          indeterminate
                          color="white"
                          class="mb-0"
                        ></v-progress-linear>
                      </v-card-text>
                    </v-card>
                  </v-dialog>

                <v-btn @click="claimBack(card)" color="red" :disabled="!(card.gameSubmitter == acc)" width="120" class="mt-sm-n3 ml-sm-5 mb-6"> Claim Back </v-btn>
              </v-card-subtitle>
              </div>
            </v-img>
          </v-card>
        </v-col>
      </v-row>
    </v-container>
  </v-card>
  <v-snackbar color="green" outlined v-model="snackbar" timeout="10000">
    {{ snackText }}
    <template v-slot:action="{ attrs }">
      <v-btn color="blue" text v-bind="attrs" @click="snackbar = false">
        Close
      </v-btn>
    </template>
  </v-snackbar>
  </v-container>
</template>


<script lang='ts'>
import Vue from 'vue';
import detectEthereumProvider from '@metamask/detect-provider';
import Web3 from 'web3';
import BN from 'bn.js';

export default Vue.extend({
    name: 'BrowserPage',
    props: {

    },
    data() {
        return {
            cards: [],
            acc: null,
            fee: null,
            dialog: false,
            claimDialog: false,
            snackbar: false,
            snackText: "",
            disableNotSubmitter: false,
			disabled: false
        }
    },
    methods: {
    async playGame(card) {
      let errCode;
      this.dialog = true;
      this.disabled = true;
      
      await this.hotContract.methods.getFee().call().then((resp) => this.fee = resp);

      let weiPrice = new BN(Web3.utils.toWei(card.gamePrice.toString(10)));
      let weiValue = weiPrice.add(new BN(this.fee, 10));

      console.log(weiValue.toString(10));
      console.log("address to play", window.ethereum.selectedAddress);

	let estimatedGas = await this.hotContract.methods.playHotGame(card.gameId).estimateGas(
		{
			from : window.ethereum.selectedAddress,
			value : weiValue.toString(10),
		}, function(error, estimatedGas) {
			console.log(error, estimatedGas);
		}
	)
	console.log("estimated gas", estimatedGas);
	
	let estimatedGasPrice;
	await this.web3.eth.getGasPrice(function(error, result){
		estimatedGasPrice = result;
	});
	console.log("estimated gas price", estimatedGasPrice);

	let nonce;
	await this.web3.eth.getTransactionCount(window.ethereum.selectedAddress).then(resp => nonce = resp)
	console.log("nonce", nonce);

      const transactionParameters = {
      nonce: nonce,
      gasPrice: estimatedGasPrice,
      gas: estimatedGas,
      to: this.$store.getters.getTestNetContractAddr,
      from: window.ethereum.selectedAddress,
      value: weiValue.toString(10),
      chainId: this.$store.getters.getChainId,
      };

      await this.hotContract.methods.playHotGame(card.gameId).send(transactionParameters)
      .then((resp) => {
		console.log(resp);
		this.snackText = "transaction succeeded ! go refresh history to the result !"
		this.snackbar = true;
		})
      .catch((err) => errCode = err.code);

      this.dialog = false;
      setTimeout(()=> location.reload(), 3000);
      console.log(errCode);

    },

	async claimBack(card) {
		let errCode;
		this.claimDialog = true;
		this.disabled = true;

		let estimatedGas = await this.hotContract.methods.claimBack(card.gameId).estimateGas(
			{
				from : window.ethereum.selectedAddress,
			}, function(error, estimatedGas) {
				console.log(error, estimatedGas);
			}
		)
		console.log("estimated gas", estimatedGas);

		let estimatedGasPrice;
		await this.web3.eth.getGasPrice(function(error, result){
			estimatedGasPrice = result;
		});
		console.log("estimated gas price", estimatedGasPrice);

		let nonce;
		await this.web3.eth.getTransactionCount(window.ethereum.selectedAddress).then(resp => nonce = resp)
		console.log("nonce", nonce);

		const transactionParameters = {
		nonce: nonce,
		gasPrice: estimatedGasPrice,
		gas: estimatedGas,
		to: this.$store.getters.getTestNetContractAddr,
		from: window.ethereum.selectedAddress,
		value: 0x0,
		chainId: this.$store.getters.getChainId,
		};

		await this.hotContract.methods.claimBack(card.gameId).send(transactionParameters)
		.then((resp) => {
		console.log(resp);
		this.snackText = "transaction succeeded ! you will see your AVAX in your wallet in few seconds !"
		this.snackbar = true;
		})
		.catch((err) => errCode = err.code);

		this.claimDialog = false;
		setTimeout(()=> location.reload(), 3000);
		console.log(errCode);
	},
    
    async getAllCards() {
      await this.hotContract.methods.getGames('CREATED').call().then((response) => {
        
        let i;
		let date;

        for (i = 1; i < response.length; i++) {
			date = new Date(response[i].submitTime * 1000)
          this.cards.push({
              gameId: response[i].gameId,
              gameName: "NAME_IN_BACK",
              gamePrice: Web3.utils.fromWei(response[i].bet),
              gameStatus: "GAME_STATUS_IN_BACK",
              gameSubmitter: response[i].submitter.toLowerCase(),
              gameSubmitTime: date.getDate() + '/' + date.getMonth() + '/' + date.getFullYear() + ' ' + date.getHours() + 'h' + date.getMinutes() + 'm' + date.getSeconds() + 's'
            });
        }
      });

    },

		async initWeb3() {
      this.provider = await detectEthereumProvider();
      if (this.provider) {
          let newChainId = await this.provider.request({method: 'eth_chainId'});
          this.$store.commit('setChainId', newChainId);
      } else
          console.error('Please install MetaMask!')
      let userAccount = await window.ethereum.request({method: 'eth_accounts'});
      this.acc = userAccount[0].toLowerCase();
		},
    handleAccountsChanged(accounts) {
        if (accounts.length === 0) {
            this.acc = null;

        } else { 
            this.acc = accounts[0].toLowerCase();
        }
    },
    isSubmitted(card) {
      if (this.acc == String && card.submitter == String)
      if (this.acc.toLowerCase() == card.submitter.toLowerCase())
        return true;
      return false;
    }
    },

    async created() {
      this.web3 = new Web3(window.ethereum);

      this.hotContract = new this.web3.eth.Contract(this.$store.getters.getTestNetContractABI, this.$store.getters.getTestNetContractAddr);
      await this.hotContract.methods.getFee().call().then((resp) => this.fee = resp);
    //   console.log(this.fee);
      this.getAllCards();

    //   console.log(this.cards)
      this.initWeb3();
      window.ethereum.on('accountsChanged', this.handleAccountsChanged);
    }
})
</script>

<style scoped>

#hotCard { transition: all .2s ease-in-out; }

#hotCard:hover {
	transform: scale(1.1);
}

</style>