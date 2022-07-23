import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
      fee: null,
      chainId: null,
      userAccount: null,
      contractInstance: null,
      avaxPrice: null,
      testNetContractAddr: '0x43830B93EF072b6FB72231e176EC11272561d60A',
      testNetContractABI: [
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
                  "name": "closingTime",
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
                  "name": "closingTime",
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
                  "name": "closingTime",
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
              "name": "closingTime",
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
                  "name": "closingTime",
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
              "name": "closingTime",
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
      ],
      contractAddr: null,
      contractABI: null,
  },
  getters: {
    getUserAccount(state) {
      return state.userAccount;
    },
    getChainId(state) {
      return state.chainId;
    },
    getAvaxPrice(state) {
      return state.avaxPrice;
    },
    getTestNetContractAddr(state) {
      return state.testNetContractAddr;
    },
    getTestNetContractABI(state) {
      return state.testNetContractABI;
    },
  },
  mutations: {
    setUserAccount : (state, address) => {
      state.userAccount = address;
    },
    setChainId : (state, chainId) => {
      state.chainId = chainId;
    },
    setAvaxPrice : (state, price) => {
      state.avaxPrice = price;
    },
  },
  actions: {
  },
  modules: {
  }
})
