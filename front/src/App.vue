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
            <v-btn to="/browser" color="green" dark v-bind="attrs" v-on="on">
              BET
            </v-btn>
          </template>

          <v-list>
            <v-list-item>
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
            </v-list-item>
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

      <v-btn v-if="!isUserAccount" :disabled="disabled" :loading="loading" @click="connectWallet" color="primary">
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
      to: '0xCCCA8931A81f267980b22bD7360909e2EA8D72Bc',
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
    }
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
        ], '0x643e87c156A02D6c5796C58cD7539E9F357448D2'
      );

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