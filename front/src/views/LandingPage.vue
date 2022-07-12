<template>
  <v-container>
    <v-row class="text-center">
      <v-col cols="12">
        <v-img
          :src="require('../assets/bitcoin-token.jpg')"
          class="my-3"

          height="200"
        />
      </v-col>

      <v-col class="mb-4">
        <h1 class="display-2 font-weight-bold mb-3">
          Head or Tails
        </h1>

        <h2 class="subheading font-weight-regular">
          The next decentralized gambling game for players
        </h2>
        <h3 class="font-weight-regular mt-1 mb-n5">
          <a href="">Smart Contract code</a> <br>
          <a href="">See on Avalanche</a>
        </h3>
      </v-col>

      <v-col class="mb-4" cols="12">
        <v-btn to="/Browser" color="green" x-large height="200" width="400" class="text-h1"> PLAY </v-btn>
      </v-col>

    </v-row>
    <v-col class="mb-4">

      <h2 class="text-center font-weight-regular">
        <h4>No subscription needed</h4>
        <h4>Connect your Metamask Wallet </h4>
        <h4 class="d-flex justify-center">Win some AVAX 
          <v-img max-width="40" class="ml-2" src="https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png" width="30px"></v-img>
        </h4>
      </h2>
    </v-col>
  </v-container>
</template>

<script>

  export default {
    name: 'LandingPage',

    data: () => ({
      gasFees: 0.001,
      transactionFee: 0.001,
    }),
  }
</script>

<style>
.border {
  border: 1px solid;
}

</style>