<template>
  <v-container>
    <v-row class="text-center">
      <v-col class="mb-4">
        <h1 class="display-2 font-weight-bold mb-3">
          Create BET
        </h1>

        <div class="d-flex justify-center" >
            <v-card class="" >
                <v-card-text class="text-h5 ">
                    <v-text-field class="px-10 centered-input" hint="Example: 0.05" v-model="price" required></v-text-field>

                    <div class="d-flex justify-center flex-row">
                        Enter your price : {{ price }} <span class="ml-2"><v-img src="https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png" width="30px"></v-img> </span>
                    </div>
                    <div style="font-size: 12px;"> (required) </div>
                </v-card-text>
            </v-card>
        </div>
        <!-- <div class=" mt-5">
        <h3 class="text-start"> And just for fun </h3>
            <v-card >
                <v-card-text class="text-h6">
                    <div class="d-flex justify-start flex-row"> Left a comment on your game</div>
                    <v-text-field v-model="gameStatus" required></v-text-field>
                </v-card-text>
            </v-card>
        </div> -->
        <!-- <v-file-input accept="image/*" label="A nice picture"></v-file-input> -->

        <div class="d-flex justify-center mt-1" >
            <v-card class="">
                <v-card-text class="text-h5 ">
                    <div class="d-flex justify-center flex-row">
                        Your game name
                    </div>
                    <div class="mb-n3" style="font-size: 12px;"> (required) </div>
                    <v-text-field class="px-10 centered-input" v-model="gameName" required></v-text-field>
                </v-card-text>
            </v-card>
        </div>
      </v-col>
    </v-row>
    <CreationDialog v-if="this.acc" :price="price" :gameName="gameName" :gameStatus="gameStatus"></CreationDialog>
    <v-alert v-else  border="top" outlined color="red lighten-2"> Connect Your Wallet for creation </v-alert>
  </v-container>
</template>


<script>
import Vue from 'vue';
import CreationDialog from '@/components/CreationDialog.vue';
import detectEthereumProvider from '@metamask/detect-provider';


// Vue.component('', );
export default Vue.extend({
    name: 'CreatePage',
    components: {
        CreationDialog,
    },
    props: {

    },
    data() {
        return {
            price: null,
            gameName: null,
            gameStatus: null,
            dialog: false,
            acc: null,
        }
    },
    methods: {
		async initWeb3() {
            this.provider = await detectEthereumProvider();
            if (this.provider) {
                let newChainId = await this.provider.request({method: 'eth_chainId'});
                this.$store.commit('setChainId', newChainId);
                // console.log(this.$store.getters.getChainId);
            } else
                console.error('Please install MetaMask!')
            let userAccount = await window.ethereum.request({method: 'eth_accounts'});
            this.acc = userAccount[0];
            // console.log("in create", userAccount);
		},

        // handleChainChanged() {
        // window.location.reload();
        // },

        handleAccountsChanged(accounts) {
            console.log("account changed", accounts);
            if (accounts.length === 0) {
                this.acc = null;

            } else {
                this.acc = accounts[0];
            }
        },
    },
    computed: {

    },

    created() {
        this.gameStatus = ''
		this.initWeb3();
        // window.ethereum.on('chainChanged', this.handleChainChanged);
        window.ethereum.on('accountsChanged', this.handleAccountsChanged);
    }
})
</script>

<style scoped>
    .centered-input >>> input {
      text-align: center
    }
</style>