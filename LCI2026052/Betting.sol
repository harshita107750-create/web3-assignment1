// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Betting {
    struct Bet {
        address payable better;
        uint amount;
        uint team_no;
    }

    Bet[] public bets;
    uint public team1_amount;
    uint public team2_amount;
    uint public total_bets;
    uint public result;
    address public owner;
    uint public min_bet_amount;
    
    string public team1_name;
    string public team2_name;
    bool public teams_set;
    bool public betting_open;
    bool public match_ended;

    constructor(string memory _team1, string memory _team2, uint _minBet) {
        owner = msg.sender;
        team1_name = _team1;
        team2_name = _team2;
        teams_set = true;
        min_bet_amount = _minBet;
        betting_open = true;
        match_ended = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function close_betting() external onlyOwner {
        betting_open = false;
    }

    function put_bet(uint team_no) external payable {
        require(teams_set, "Team names have not been configured yet.");
        require(betting_open, "Betting is currently closed.");
        require(team_no == 1 || team_no == 2, "Invalid team number. Choose 1 or 2.");
        require(msg.value >= min_bet_amount, "Sent ETH is less than the minimum bet amount.");

        bets.push(Bet({
            better: payable(msg.sender),
            amount: msg.value,
            team_no: team_no
        }));

        if (team_no == 1) {
            team1_amount += msg.value;
        } else {
            team2_amount += msg.value;
        }
        total_bets++;
    }

    function declare_result(uint winner) external onlyOwner {
        require(!betting_open, "Betting must be closed before declaring the result.");
        require(winner == 1 || winner == 2, "Invalid winner team number. Choose 1 or 2.");

        result = winner;
        match_ended = true;
    }

    function distribute_amount() external onlyOwner {
        require(match_ended, "Match has not ended yet.");

        uint winningTotal = (result == 1) ? team1_amount : team2_amount;
        uint losingTotal = (result == 1) ? team2_amount : team1_amount;

        require(winningTotal > 0, "No bets placed on the winning team.");

        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].team_no == result) {
                uint profitShare = (bets[i].amount * losingTotal) / winningTotal;
                uint totalReward = bets[i].amount + profitShare;

                (bool success, ) = bets[i].better.call{value: totalReward}("");
                require(success, "Transfer failed.");
            }
        }
    }
}