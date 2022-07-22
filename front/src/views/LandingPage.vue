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

    <div class="d-flex flex-row justify-center mt-5">
      <h2 class="mr-1">Requirements: </h2>
        <ul>
          <li class=""> Connect your Metamask Wallet <div style="display:inline-block" > <v-img class="pb-3" width="25" contain src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/MetaMask_Fox.svg/1200px-MetaMask_Fox.svg.png"></v-img> </div> </li>
          <li class="mt-1"> Add <a href="https://medium.com/seedify/how-to-add-an-avalanche-c-chain-rpc-to-metamask-e8f08979a8a8"> C-Chain network</a> (real mode) or <a href="https://hurricaneswap.medium.com/tutorial-for-hurricaneswap-testnet-ce57c14ee652">Fuji testnet</a> (test mode) </li>
          <li> Win some AVAX <div style="display:inline-block" > <v-img class="pb-3" width="25" contain src="https://s2.coinmarketcap.com/static/img/coins/64x64/5805.png"></v-img> </div> </li>
        </ul>
    </div>

    <h3 class="text-center mt-5">
      ⚠️ The game is currently not working on mobile device !
    </h3>

    <div class="ml-5 mt-5">
      <h2> Description </h2>
      <p class="mt-2">
        This is a fully decentralized Head or Tails game build on the Avalanche blockchain,
        working with Metamask Wallets. <br> <br>
        
        You can currently win AVAX with a 50% chance of winning, betting with others players. <br>
        All created games are stored in the blockchain, waiting for someone to gamble with. <br> <br>

        The BET BROWSER section allows you to see the currently available bets on the smart contract and play. <br>
        The CREATE GAME section allows you to create a game by telling how much you want to bet. <br>
        Once you create a bet, you must send the corresponding amount of AVAX to the smart contract who will keep it safe
        until someone play on your game, but don't worry, this front site has automated everything ! <br> <br>

        You always have the possibility to cancel your game later and get back your AVAX, but you will need the
        Metamask address that you used to create the game, and additionnaly, it will just cost you the gas fee. <br> <br>

        Each random number is generated using <a href="https://docs.chain.link/docs/intermediates-tutorial/"> Chainlink VRF</a>,
        which means it is a truly provable random number who is generated for each game. <br> 
        Pure randomness comes with a cost, and in order to play HOT games, you have to pay a randomness fee that will feed the Chainlink contract. <br> <br>

        Feel free to ask anything or make any feedback on the <a href=""> discord community</a> and we will answer as soon as possible.
      </p>
    </div>
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