// SPDX-License-Identifier: MIT

// Il faut garder en mémoire les fees à la hotGameCreation ? 

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract HotGame is Ownable {

    uint256 _fee;   // fee in wei
    address _owner;

    struct GameData {
        string  gameId;     // used to link the back of wonderful DApp
        address playerOne;  // first player who created the game
        uint256 bet;        // bet value, set in wei
        uint256 submitTime; // Timestamp of the launching game (bet will be given back within one week delay)
    }

    constructor(uint256 fee) {
        _fee = fee; // set first fee
        _owner = msg.sender;
    }

    event NewHotGame(GameData); // event triggered for each game newly created
    event HotGameClaimBack(GameData); // event triggered for each game canceled
    event HotGameFinished(GameData, address); // event triggered when is played, address is the winner

    GameData[] public games;

    function createHotGame(
        string memory gameId,
        address playerOne,
        uint256 bet
    ) public payable returns(bool) {
        // require(msg.value - _fee == bet, "value is not fitting bet"); // bet announced is corresponding to msg.value
        payable(_owner).transfer(_fee);
        GameData memory newGame;
        newGame = GameData(gameId, playerOne, bet, block.timestamp);

        games.push(newGame);
        emit NewHotGame(newGame);
        return true;
    }

    function playHotGame(string memory gameIdToPlay) public payable {
        uint256 gameIndex = 0;
        uint    randInt;

        for (uint256 i = 0; i < games.length; i++) {
            if (keccak256(abi.encodePacked(games[i].gameId)) == keccak256(abi.encodePacked(gameIdToPlay)))
                gameIndex = i;
        }
        require(gameIndex >= 0, "game not found");    // gameId not found 
        require(msg.value - _fee == games[gameIndex].bet, "value not fitting bet"); // if not => value not corresponding to bet
        payable(_owner).transfer(_fee);
        
        randInt = _random();
        // playerOne Win
        if (randInt > 50) {
            payable(games[gameIndex].playerOne).transfer(games[gameIndex].bet);
            emit HotGameFinished(games[gameIndex], games[gameIndex].playerOne);
        }
        // playerTwo Win
        else {
            payable(msg.sender).transfer(games[gameIndex].bet);
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
        require(gameIndex >= 0);    // gameId not found
        require(msg.sender == games[gameIndex].playerOne);  // sender is the submitter
        payable(msg.sender).transfer(games[gameIndex].bet);

        // games[gameIndex].playerOne = address(0) ?
        emit HotGameClaimBack(games[gameIndex]);
        delete games[gameIndex];
        _reorderArray(gameIndex);   // to order elements in games array and get correct length
        return true;
    }

    function getGames() public view  returns(GameData[] memory){
        return games;
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

    function _random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, games.length)));
    }
}
