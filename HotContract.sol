// SPDX-License-Identifier: MIT

/*
** Author: Melchior Maj
** Github: https://github.com/mmaj0708
*/

/*
** This is a decentralized HEAD OR TAILS GAME with proven randomness
**
** It is not a live game, so you can submit a bet stored in the blockchain
** and wait for someone to follow your bet, or you can follow a bet already submitted.
** Submitters will always have the possibility to claim back there bet if no one followed,
** as long as they claim back with the submitting wallet address.
**
** There is no limit on the size bets you can submit nor the number of bets.
**
** Random numbers are generated with Chainlink. Meaning, all the random numbers
** are truly random, with provable randomness.
** 
** some fees are added to the bet and send to the contract owner, in order to add some LINK tokens
** to the contract address, which is mandatory to generate fully random number.
*/


// utiliser une librairie pour accéder à tous les éléments de map ?
// améliorer le delete en décalant les éléments de map ?

pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract HotGame is VRFConsumerBaseV2, Ownable {

    event NewHotGame(GameData); // event triggered for each game newly created
    event HotGameClaimBack(GameData); // event triggered for each game canceled
    event HotGameFinished(GameData, address); // event triggered when is played, second arg is the winner

    enum gameStatus{ CREATED, RANDOM_REQUESTED }

    struct GameData {
        string  gameId;             // used to link the back of this wonderful DApp
        address submitter;          // first player who created the game
        address player;             // first player who created the game
        uint256 bet;                // bet value, set in wei
        uint256 submitTime;         // Timestamp of the launching game
        uint256 randomRequestId;    // request ID to identify for which game is the random number
        gameStatus  status;         // used to know the state of game (created or in random requesting)
    }
    
    uint256 _fee;   // fee in wei
    address _owner;

    mapping(string => GameData) public games;
    mapping(uint => GameData) public randReq;

    uint64 s_subscriptionId; // must be 210 for fuji-testnet
    address vrfCoordinator = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610; // (fuji-testnet)
    bytes32 s_keyHash = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61; // (fuji-testnet)
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;
    VRFCoordinatorV2Interface COORDINATOR;

    constructor(uint256 fee, uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        _fee = fee; // set first fee
        _owner = msg.sender;
        s_subscriptionId = subscriptionId;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }

    function requestRandomWords() internal returns (uint256) {
        uint256 requestId;

        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256  randomInt = (randomWords[0] % 100) + 1;

        if (randomInt > 50) { // submitter Win
            payable(randReq[requestId].submitter).transfer(randReq[requestId].bet * 2);
            emit HotGameFinished(randReq[requestId], randReq[requestId].submitter);
        }
        else { // player Win
            payable(randReq[requestId].player).transfer(randReq[requestId].bet * 2);
            emit HotGameFinished(randReq[requestId], randReq[requestId].player);
        }
        delete games[randReq[requestId].gameId];
        delete randReq[requestId];
    }

    function createHotGame(string memory gameId, uint256 bet) public payable {
        require(games[gameId].submitter == address(0), "game Id already exist");
        require(msg.value - _fee == bet, "value is not fitting bet");
        payable(_owner).transfer(_fee);
        GameData memory newGame;
        newGame = GameData(gameId, msg.sender, address(0), bet, block.timestamp, 0, gameStatus.CREATED);

        games[gameId] = newGame;
        emit NewHotGame(newGame);
    }

    function playHotGame(string memory gameIdToPlay) public payable {
        require(games[gameIdToPlay].submitter != address(0), "game Id not found");
        require(msg.value - _fee == games[gameIdToPlay].bet, "value not fitting bet");
        require(games[gameIdToPlay].status == gameStatus.CREATED, "Game is already processing (waiting for random number...)");

        games[gameIdToPlay].player = msg.sender;

        payable(_owner).transfer(_fee);

        games[gameIdToPlay].randomRequestId = requestRandomWords();
        randReq[games[gameIdToPlay].randomRequestId] = games[gameIdToPlay];
        games[gameIdToPlay].status = gameStatus.RANDOM_REQUESTED;

        // now player must wait for the random number to be send to fullfillRandomWords()
        // from here winner will be determined and payout will be done
    }

    function claimBack(string memory gameIdClaimed) public {
        require(games[gameIdClaimed].submitter != address(0), "game Id not found");
        require(msg.sender == games[gameIdClaimed].submitter, "sender is not the submitter");
        require(games[gameIdClaimed].status == gameStatus.CREATED);

        payable(msg.sender).transfer(games[gameIdClaimed].bet);

        emit HotGameClaimBack(games[gameIdClaimed]);
        delete games[gameIdClaimed];
    }

    function setFee(uint256 newFee) onlyOwner public {
        _fee = newFee;
    }

    function getContractStock() public view returns(uint){
        return address(this).balance;
    }

    function getFee() public view  returns(uint){
        return _fee;
    }
}
