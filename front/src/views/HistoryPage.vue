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
                { text: 'Date', value: 'date' },
                { text: 'Rand. Nbr.', value: 'randomNumber' },
            ],
            games: [],
        }
    },
    methods: {
    async getAllCards() {
      await this.hotContract.methods.getGames('FINISHED').call().then((response) => {
        // console.log(response);        
        let i;
		let gameId;
		let date;

        for (i = 1; i < response.length; i++) {
			gameId = response[i].gameId.slice(0, 7) + '...' + response[i].gameId.slice(22)
			date = new Date(response[i].submitTime * 1000)
          this.games.push({
            gameId: gameId,
            submitter: response[i].submitter.toLowerCase().slice(0, 5) + '...' + response[i].submitter.toLowerCase().slice(38),
            bet: Web3.utils.fromWei(response[i].bet),
            player: response[i].player.toLowerCase().slice(0, 5) + '...' + response[i].player.toLowerCase().slice(38),
            winner: response[i].winner.toLowerCase().slice(0, 5) + '...' + response[i].winner.toLowerCase().slice(38),
            randomNumber: response[i].randomNumber,
			date:  date.getDate() + '/' + date.getMonth() + '/' + date.getFullYear() + ' ' + date.getHours() + 'h' + date.getMinutes() + 'm' + date.getSeconds() + 's',
            });
        }
        this.tableLoader = false;
      });

    },
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
      // console.log(this.fee);
      this.getAllCards();

    //   console.log(this.cards)
    }
})
</script>

<style scoped>

</style>