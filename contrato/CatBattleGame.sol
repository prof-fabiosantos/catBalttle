// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CatBattleGame {
    
    enum BattleStatus { NotInBattle, InBattle, Finished }

    struct Cat {
        uint256 id;
        address owner;
        string name;
        uint256 LowAttackPower;
        uint256 HighAttackPower;
        uint256 LowDefensePower;      
        uint256 HighDefensePower;        
        BattleStatus status;
    }

    uint256 public winner;
    uint256 public loser;

    uint256 public totalCats;

    mapping(uint256 => Cat) public cats;
    mapping(address => bool) public registeredPlayers;    

    event CatRegistered(uint256 catId, string name);
    event BattleStarted(uint256 catId1, uint256 catId2);
    event BattleEnded(uint256 winnerCatId, uint256 loserCatId);

    modifier onlyRegisteredPlayer() {
        require(registeredPlayers[msg.sender], "Player not registered");
        _;
    }

    function registerPlayer() external {
        registeredPlayers[msg.sender] = true;
    }

    function registerCat(string memory name, uint256 LowAttackPower, uint256 HighAttackPower, uint256 LowDefensePower, uint256 HighDefensePower) external onlyRegisteredPlayer {
        require(LowAttackPower >= 0 && HighAttackPower >= 0 && LowDefensePower >=0  && HighDefensePower >=0, "Attack and defense power must be greater than zero");
        require(bytes(name).length > 0, "Name cannot be empty");

        totalCats++;
        cats[totalCats] = Cat(totalCats, msg.sender, name, LowAttackPower, HighAttackPower, LowDefensePower,HighDefensePower, BattleStatus.NotInBattle);
        emit CatRegistered(totalCats, name);
    }

    function startBattle(uint256 catId1, uint256 catId2) external onlyRegisteredPlayer {
        require(cats[catId1].status == BattleStatus.NotInBattle && cats[catId2].status == BattleStatus.NotInBattle, "Both cats must not be in battle");

        cats[catId1].status = BattleStatus.InBattle;
        cats[catId2].status = BattleStatus.InBattle;
        emit BattleStarted(catId1, catId2);
    }

    function endBattle(uint256 catId1, uint256 catId2) external onlyRegisteredPlayer {
        require(cats[catId1].status == BattleStatus.InBattle && cats[catId2].status == BattleStatus.InBattle, "Both cats must be in battle");

        uint256 scoreCat1 = cats[catId1].LowAttackPower + cats[catId1].HighAttackPower + cats[catId1].LowDefensePower +  cats[catId1].HighDefensePower;
        uint256 scoreCat2 = cats[catId2].LowAttackPower + cats[catId2].HighAttackPower + cats[catId2].LowDefensePower +  cats[catId2].HighDefensePower;

        if (scoreCat1 >= scoreCat2) {
            cats[catId1].status = BattleStatus.Finished;
            cats[catId2].status = BattleStatus.Finished;
            winner = cats[catId1].id;
            loser = cats[catId2].id;
            emit BattleEnded(catId1, catId2);
        } else {
            cats[catId1].status = BattleStatus.Finished;
            cats[catId2].status = BattleStatus.Finished;
            winner = cats[catId2].id;
            loser = cats[catId1].id;
            emit BattleEnded(catId2, catId1);
        }
    }
}