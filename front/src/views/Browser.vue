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
        NO GAMES CURRENTLY, BUT YOU CAN CREATE YOURS !
        <v-btn to="/create" color="blue" class="ml-2"> CREATE! </v-btn>
      </v-card> 
      <v-row v-else>
		
        <v-col cols="6" v-for="(card, index) in cards" :key="index">
          <v-card id="hotCard" width="100%" color="primary">
            <v-img class="" src="../assets/bitcoin-token.jpg" height="200" gradient="to bottom, rgba(0,0,0,.3), rgba(0,0,0,.5)">
              <v-card-title class="ml-5">
                <v-icon>mdi-account</v-icon>
                <span style="font-size: 12px;"> {{card.gameSubmitter.slice(0, 5) + '...' + card.gameSubmitter.slice(38)}} </span>
              </v-card-title>
              <v-card-subtitle class="ml-5 mb-n5 font-weight-bold d-flex flex-row">
                for {{card.gamePrice}}
                <span class="mx-2"><v-img src="https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png" width="20px"></v-img> </span>
                (= {{ (card.gamePrice * $store.getters.getAvaxPrice).toFixed(2) }} $)
              </v-card-subtitle>
              <v-card-subtitle class="ml-5">
                ID : {{card.gameId.slice(0, 7) + '...' + card.gameId.slice(card.gameId.length - 5)}}
              </v-card-subtitle>
              <v-card-subtitle>
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

      const transactionParameters = {
      nonce: '0x00',
      gasPrice:25000000000,
      gas: new BN('210000', 16),
      to: '0xCCCA8931A81f267980b22bD7360909e2EA8D72Bc',
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


		const transactionParameters = {
		nonce: '0x00',
		gasPrice:25000000000,
		gas: new BN('210000', 16),
		to: '0xCCCA8931A81f267980b22bD7360909e2EA8D72Bc',
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

        for (i = 1; i < response.length; i++) {
          this.cards.push({
              gameId: response[i].gameId,
              gameName: "NAME_IN_BACK",
              gamePrice: Web3.utils.fromWei(response[i].bet),
              gameStatus: "GAME_STATUS_IN_BACK",
              gameSubmitter: response[i].submitter.toLowerCase()
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

      this.hotContract = new this.web3.eth.Contract(
      [
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "gameIdClaimed",
				"type": "string"
			}
		],
		"name": "claimBack",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "gameId",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "bet",
				"type": "uint256"
			}
		],
		"name": "createHotGame",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "fee",
				"type": "uint256"
			},
			{
				"internalType": "uint64",
				"name": "subscriptionId",
				"type": "uint64"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "have",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "want",
				"type": "address"
			}
		],
		"name": "OnlyCoordinatorCanFulfill",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "gameId",
						"type": "string"
					},
					{
						"internalType": "address",
						"name": "submitter",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "player",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "bet",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "submitTime",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomRequestId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomNumber",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "winner",
						"type": "address"
					},
					{
						"internalType": "enum HotGame.gameStatus",
						"name": "status",
						"type": "uint8"
					}
				],
				"indexed": false,
				"internalType": "struct HotGame.GameData",
				"name": "",
				"type": "tuple"
			}
		],
		"name": "HotGameClaimBack",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "gameId",
						"type": "string"
					},
					{
						"internalType": "address",
						"name": "submitter",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "player",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "bet",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "submitTime",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomRequestId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomNumber",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "winner",
						"type": "address"
					},
					{
						"internalType": "enum HotGame.gameStatus",
						"name": "status",
						"type": "uint8"
					}
				],
				"indexed": false,
				"internalType": "struct HotGame.GameData",
				"name": "",
				"type": "tuple"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "HotGameFinished",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "gameId",
						"type": "string"
					},
					{
						"internalType": "address",
						"name": "submitter",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "player",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "bet",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "submitTime",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomRequestId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomNumber",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "winner",
						"type": "address"
					},
					{
						"internalType": "enum HotGame.gameStatus",
						"name": "status",
						"type": "uint8"
					}
				],
				"indexed": false,
				"internalType": "struct HotGame.GameData",
				"name": "",
				"type": "tuple"
			}
		],
		"name": "NewHotGame",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "gameIdToPlay",
				"type": "string"
			}
		],
		"name": "playHotGame",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "requestId",
				"type": "uint256"
			},
			{
				"internalType": "uint256[]",
				"name": "randomWords",
				"type": "uint256[]"
			}
		],
		"name": "rawFulfillRandomWords",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "newFee",
				"type": "uint256"
			}
		],
		"name": "setFee",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"name": "games",
		"outputs": [
			{
				"internalType": "string",
				"name": "gameId",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "submitter",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "player",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "bet",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "submitTime",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "randomRequestId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "randomNumber",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "winner",
				"type": "address"
			},
			{
				"internalType": "enum HotGame.gameStatus",
				"name": "status",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getContractStock",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getFee",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getGameIds",
		"outputs": [
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "status",
				"type": "string"
			}
		],
		"name": "getGames",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "gameId",
						"type": "string"
					},
					{
						"internalType": "address",
						"name": "submitter",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "player",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "bet",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "submitTime",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomRequestId",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "randomNumber",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "winner",
						"type": "address"
					},
					{
						"internalType": "enum HotGame.gameStatus",
						"name": "status",
						"type": "uint8"
					}
				],
				"internalType": "struct HotGame.GameData[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "randReq",
		"outputs": [
			{
				"internalType": "string",
				"name": "gameId",
				"type": "string"
			},
			{
				"internalType": "address",
				"name": "submitter",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "player",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "bet",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "submitTime",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "randomRequestId",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "randomNumber",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "winner",
				"type": "address"
			},
			{
				"internalType": "enum HotGame.gameStatus",
				"name": "status",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
      , '0x643e87c156A02D6c5796C58cD7539E9F357448D2'
      );

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