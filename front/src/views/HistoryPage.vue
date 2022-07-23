<template>
<div class="container">
    <v-data-table
    dense
    :loading="tableLoader"
    :headers="headers"
    :items="games"
    :items-per-page="15"
    class="elevation-1"
  ></v-data-table>
</div>
</template>


<script>
import Web3 from 'web3';


export default ({
    name: 'HistoryPage',
    props: {

    },
    data() {
        return {
            tableLoader: true,
            headers: [
                {
                    text: 'Game ID',
                    align: 'start',
                    sortable: false,
                    value: 'gameId',
                },
                { text: 'Creator', value: 'submitter' },
                { text: 'Bet', value: 'bet' },
                { text: 'Player', value: 'player' },
                { text: 'Winner', value: 'winner' },
                { text: 'Closing date', value: 'closingDate' },
                { text: 'Rand. Nbr.', value: 'randomNumber' },
            ],
            games: [],
        }
    },
    methods: {
    async getAllCards() {
      await this.hotContract.methods.getGames('FINISHED').call().then((response) => {
        console.log(response);        
        let i;
		let gameId;
		let closingDate;

        for (i = 1; i < response.length; i++) {
			gameId = response[i].gameId.slice(0, 7) + '...' + response[i].gameId.slice(22)
			closingDate = new Date(response[i].closingTime * 1000)
          this.games.push({
            gameId: gameId,
            submitter: response[i].submitter.toLowerCase().slice(0, 5) + '...' + response[i].submitter.toLowerCase().slice(38),
            bet: Web3.utils.fromWei(response[i].bet),
            player: response[i].player.toLowerCase().slice(0, 5) + '...' + response[i].player.toLowerCase().slice(38),
            winner: response[i].winner.toLowerCase().slice(0, 5) + '...' + response[i].winner.toLowerCase().slice(38),
            randomNumber: response[i].randomNumber,
			closingDate:  closingDate.getDate() + '/' + closingDate.getMonth() + '/' + closingDate.getFullYear() + ' ' + closingDate.getHours() + 'h' + closingDate.getMinutes() + 'm' + closingDate.getSeconds() + 's',
            });
        }
        this.tableLoader = false;
      });

    },
    },
	
    async created() {
      this.web3 = new Web3(window.ethereum);

      this.hotContract = new this.web3.eth.Contract(this.$store.getters.getTestNetContractABI, this.$store.getters.getTestNetContractAddr);

      await this.hotContract.methods.getFee().call().then((resp) => this.fee = resp);
      // console.log(this.fee);
      this.getAllCards();

    //   console.log(this.cards)
    }
})
</script>

<style scoped>

</style>