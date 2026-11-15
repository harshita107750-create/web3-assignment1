//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Betting{
    struct Bet{
        address payable better;
        uint amount;
        uint team_no;
    }

    Bet[] public bets;
    // 0. (0x1093, 1eth, 1)
    // 1. (0x3842, 2eth, 2)

    uint public team1_amount=0;
    uint public team2_amount=0;
    uint public total_bets=0;
    uint public result;

    address public owner;
    uint public min_bet_amount;
    constructor(uint _min_bet_amount){
        owner = msg.sender;
        min_bet_amount = _min_bet_amount;
    }

    modifier onlyOwner{
    require( msg.sender == owner , "Only owner can call this");
    _;
}

    string public team1_name;
    string public team2_name;
    bool public teams_set=false;
    bool public betting_open=false;
    bool public match_ended=false;

    function set_team_names(string memory _team1, string memory _team2)  public{
        require(teams_set==false, "team names are already set");
        team1_name = _team1;
        team2_name = _team2;
        teams_set = true;
        betting_open= true;
    }

    function put_bet(uint team_no) public payable {
    require( teams_set , "Team names are not set yet");
    require( betting_open , "Betting is closed");
    require( team_no == 1 || team_no == 2 , "Team number must be 1 or 2");
    require( msg.value >= min_bet_amount , "Bet is below minimum amount");
        bets.push(Bet(payable(msg.sender), msg.value, team_no));

    if (team_no == 1) {
        team1_amount += msg.value;
    } else {
        team2_amount += msg.value;
    }

    total_bets++;
    }

    function close_betting() public {
        require(betting_open==true, "Betting already closed!");
        betting_open = false;
    }

    function declare_result(uint winner) public onlyOwner{
    require(!betting_open, "Close betting before declaring result");
    require(!match_ended, "Result already declared");
    require(winner == 1 || winner == 2, "Winner must be team 1 or 2");

    result = winner;
    match_ended = true;
}

    function distribute_amount() public onlyOwner payable {
    require(match_ended, "Match has not ended yet");

    uint winning_total;
    uint losing_total;

    if (result == 1) {
        winning_total = team1_amount;
        losing_total = team2_amount;
    } else {
        winning_total = team2_amount;
        losing_total = team1_amount;
    }
        for (uint i = 0; i < bets.length; i++) {
        if (bets[i].team_no == result) {
            uint reward = bets[i].amount + (bets[i].amount * losing_total) / winning_total;

            (bool sent, ) = bets[i].better.call{value: reward}("");
            require(sent, "Transfer failed");
        }
    }
    
}
}