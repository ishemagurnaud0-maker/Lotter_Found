
// Layout of Contract:
// license
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

error Raffle__NotEnoughFunds();
error Raffle__NotTheWinner();


/**
* @title A sample Raffle Contract 
* @author Ishema Gurnaud
*@notice Contract for raffles and getting lottery winners
* @dev   Contract for testing VRFv2.5
 */


 contract Raffle {
    
    uint256 private immutable i_entranceFee;
    address private immutable i_vrfCoordinator;
    address payable[] s_players;

    event PlayerAddedToRaffle(address indexed player);

    constructor(uint256 entranceFee,address vrfCoordinator){
        i_entranceFee = entranceFee;
        i_vrfCoordinator = vrfCoordinator;
    }

    function enterRaffle() public payable{
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughFunds();
        }

        s_players.push(payable(msg.sender));
        emit PlayerAddedToRaffle(msg.sender);
    }

    function pickWinner() public {}


    /*Getter functions*/
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

 }


