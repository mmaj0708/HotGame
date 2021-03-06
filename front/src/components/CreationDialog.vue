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
               Randomness fee : {{(this.fee * Math.pow(10, -18)).toFixed(18)}} AVAX
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
// const { ethers } = require("ethers");

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

			let estimatedGas = await this.hotContract.methods.createHotGame(this.gameId, weiPrice.toString(10)).estimateGas(
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
            gas: estimatedGas, // gas Limit customizable by user during MetaMask confirmation.
            to: this.$store.getters.getTestNetContractAddr, // Required except during contract publications.
            from: window.ethereum.selectedAddress, // must match user's active address.
            value: weiValue.toString(10),
            chainId: this.$store.getters.getChainId, // Used to prevent transaction reuse across blockchains. Auto-filled by MetaMask.
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

      this.hotContract = new this.web3.eth.Contract(this.$store.getters.getTestNetContractABI, this.$store.getters.getTestNetContractAddr);

        await this.hotContract.methods.getFee().call().then((resp) => this.fee = resp);
		
}
})
</script>

<style scoped>

</style>
