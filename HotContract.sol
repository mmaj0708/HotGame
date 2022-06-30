// SPDX-License-Identifier: MIT

// problème de retard sur l'acquisition du random number

pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract HotGame is VRFConsumerBaseV2, Ownable {

    event NewHotGame(GameData); // event triggered for each game newly created
    event HotGameClaimBack(GameData); // event triggered for each game canceled
    event HotGameFinished(GameData, address); // event triggered when is played, second arg is the winner

    struct GameData {
        string  gameId;     // used to link the back of this wonderful DApp
        address submitter;  // first player who created the game
        uint256 bet;        // bet value, set in wei
        uint256 submitTime; // Timestamp of the launching game
    }
    
    uint256 _fee;   // fee in wei
    address _owner;
    GameData[] public games;

    uint256 public randomInt;
    // uint256 public prev_randomInt;
    uint256 public requestId;

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

    function requestRandomWords() internal {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
        s_keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }

    function fulfillRandomWords(uint256 /* requestId */,uint256[] memory randomWords) internal override {
        // prev_randomInt = randomInt;
        randomInt = (randomWords[0] % 100) + 1; // 1 to 100
    }

    function createHotGame(string memory gameId, uint256 bet) public payable returns(bool) {
        require(_gameIdCheck(gameId), "gameId already exist");
        require(msg.value - _fee == bet, "value is not fitting bet"); // bet announced is corresponding to msg.value
        payable(_owner).transfer(_fee);
        GameData memory newGame;
        newGame = GameData(gameId, msg.sender, bet, block.timestamp);

        games.push(newGame);
        emit NewHotGame(newGame);
        return true;
    }

    function playHotGame(string memory gameIdToPlay) public payable {
        uint256 gameIndex = 0;

        for (uint256 i = 0; i < games.length; i++) {
            if (keccak256(abi.encodePacked(games[i].gameId)) == keccak256(abi.encodePacked(gameIdToPlay)))
                gameIndex = i;
        }
        require(gameIndex >= 0, "game not found");    // gameId not found 
        require(msg.value - _fee == games[gameIndex].bet, "value not fitting bet"); // if not => value not corresponding to bet
        payable(_owner).transfer(_fee);

        // randInt = _random(); // 0 < randInt < 11499
        requestRandomWords();

        // require(prev_randomInt != randomInt);

        // submitter Win
        if (randomInt > 5749) {
            payable(games[gameIndex].submitter).transfer(games[gameIndex].bet * 2);
            emit HotGameFinished(games[gameIndex], games[gameIndex].submitter);
        }
        // playerTwo Win
        else {
            payable(msg.sender).transfer(games[gameIndex].bet * 2);
            emit HotGameFinished(games[gameIndex], msg.sender);
        }
        delete games[gameIndex];
        _reorderArray(gameIndex);   // to order elements in games array and get correct length
    }

    function claimBack(string memory gameIdClaimed) public returns(bool) {
        uint256 gameIndex = 0;

        for (uint256 i = 0; i < games.length; i++) {
            if (keccak256(abi.encodePacked(games[i].gameId)) == keccak256(abi.encodePacked(gameIdClaimed)))
                gameIndex = i;
        }
        require(gameIndex >= 0, "gameId not found");
        require(msg.sender == games[gameIndex].submitter, "sender is not the submitter");
        payable(msg.sender).transfer(games[gameIndex].bet);

        // games[gameIndex].submitter = address(0) ?
        emit HotGameClaimBack(games[gameIndex]);
        delete games[gameIndex];
        _reorderArray(gameIndex);   // to order elements in games array and get correct length
        return true;
    }

    function setFee(uint256 newFee) onlyOwner public returns(bool) {
        _fee = newFee;
        return (true);
    }

    function _reorderArray(uint emptyIndex) private {
        for(uint i = emptyIndex; i < games.length-1; i++){
            games[i] = games[i+1];      
        }
        games.pop();
    }

    function _random() public view returns (uint) { // will be truly random in HOTGAME V2 with chainlink
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, games.length))) / 10**(73);
    }

    function _gameIdCheck(string memory idToCheck) private view returns(bool) {
        for (uint i = 0; i < games.length; i++) {
            if (keccak256(abi.encodePacked(games[i].gameId)) == keccak256(abi.encodePacked(idToCheck)))
                return false;
        }
        return true;
    }

    function getGames() public view returns(GameData[] memory){
        return games;
    }

    function getContractStock() public view returns(uint){
        return address(this).balance;
    }

    function getFee() public view  returns(uint){
        return _fee;
    }
}
