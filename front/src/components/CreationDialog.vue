<template>
    <div class="text-center">
        <v-dialog persistent v-model="dialog" width="500">
        <template v-slot:activator="{ on, attrs }">
            <v-col class="mb-4" cols="12">
                <v-btn :disabled="isDisabled" v-bind="attrs" v-on="on" color="green" x-large height="100" class="text-h3"> CREATE </v-btn>
            </v-col>
        </template>

        <v-card width="1000">
            <v-card-title class="text-h5">
                Finalize Transaction 
            </v-card-title>

            <v-card-subtitle class="mt-1">
                You are going to create a game with {{price}} AVAX. <br> <br>
                Game ID : {{ generateGameId() }} <br>
                (keep this ID if you want to cancel your bet later)
            </v-card-subtitle>

            <v-card-text class="">
               Gas fee : 0.05 AVAX (= 0.1$) <br>
               Transaction fee : {{(this.fee * Math.pow(10, -18)).toFixed(18)}} AVAX
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="primary" :loading="loading" @click="createHotGame()">
                CREATE
            </v-btn>
            <v-btn color="red" text :disabled="disabled" @click="dialog = false">
                CANCEL
            </v-btn>
            </v-card-actions>
        </v-card>
        </v-dialog>

		<v-snackbar :color="snackColor" outlined v-model="snackbar" timeout="10000">
			{{ snackText }}
			<template v-slot:action="{ attrs }">
			<v-btn color="blue" text v-bind="attrs" @click="snackbar = false">
				Close
			</v-btn>
			</template>
		</v-snackbar>

    </div>
</template>


<script>
import BN from 'bn.js';
import Vue from 'vue';
import Web3 from 'web3';

export default Vue.extend({
    name: 'CreationDialog',
    props: {
        price: null,
        gameName: null,
        gameStatus: null,
    },
    data() {
        return {
            dialog: false,
			disabled: false,
			loading: false,
            gameId: null,
            fee: null,
            web3: null,
            hotContract: null,
            hotInstance: null,
			snackText: '',
			snackbar: false,
			snackColor: "green",
        }
    },
    methods: {
        generateGameId() {
            this.gameId = this.gameName + this.price + Date.now();
            return this.gameId;
        },

        async createHotGame() {
			let errcode;
			this.disabled = true;
			this.loading = true;

            await this.hotContract.methods.getFee().call().then((resp) => this.fee = resp);
			let weiPrice = new BN(Web3.utils.toWei(this.price));
			let weiValue = weiPrice.add(new BN(this.fee, 10));
			console.log(weiValue.toString(10));
			
            const transactionParameters = {
            nonce: '0x00', // ignored by MetaMask
            gasPrice:25000000000, // customizable by user during MetaMask confirmation.
            gas: new BN('210000', 16), // gas Limit customizable by user during MetaMask confirmation.
            to: '0xCCCA8931A81f267980b22bD7360909e2EA8D72Bc', // Required except during contract publications.
            from: window.ethereum.selectedAddress, // must match user's active address.
            value: weiValue.toString(10),
            chainId: '0x3', // Used to prevent transaction reuse across blockchains. Auto-filled by MetaMask.
            };

            await this.hotContract.methods.createHotGame(this.gameId, weiPrice.toString(10)).send(transactionParameters).then((resp) => {
				console.log(resp);
				this.snackText = "Bet creation on his way ! You will see your bet in the BET Browser !";
				this.snackColor = "green";
				this.snackbar = true;
				this.disabled = false;
				this.loading = false;
				this.dialog = false;
				}).catch((err) => {
					errcode = err;
					this.snackColor = "red";
					this.snackText = "Oups, something went wrong, try again !";
					this.snackbar = true;
					this.disabled = false;
					this.loading = false;
					this.dialog = false;
					console.log(errcode);
				});
            await this.hotContract.methods.games(this.gameId).call().then((resp) => console.log(resp));

            // let gameParams = {
            //         gameId: this.gameId,
            //         gamePrice: this.price,
            //         gameName: this.gameName,
            //         gameStatus: this.gameStatus
            //     };
            // await this.$http.post('card', gameParams).then((response) => {
            //     console.log("game created", response.status);
            //     if (response.status == 201)
            //         this.$router.push('browser');
            // });
        }
	},
    computed: {
        isDisabled: function () {
            if (this.price != null && /^[0-9.]+$/.test(this.price) 
            && (this.gameName != '' && this.gameName != null))
                return false;
            else return true;
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
		], '0x643e87c156A02D6c5796C58cD7539E9F357448D2'
      );

        await this.hotContract.methods.getFee().call().then((resp) => this.fee = resp);
		
}
})
</script>

<style scoped>

</style>
