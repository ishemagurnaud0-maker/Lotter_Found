
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
error Raffle__SetTimeHasNotElapsed();


/**
* @title A sample Raffle Contract 
* @author Ishema Gurnaud
*@notice Contract for raffles and getting lottery winners
* @dev   Contract for testing VRFv2.5
 */


 contract Raffle is VRFConsumerBaseV2Plus,VRFV2PlusClient{

    uint256 private immutable i_lotteryTimeInterval;
    uint256 private immutable i_entranceFee;
   // address private immutable i_vrfCoordinator;
    address payable[] s_players;
    uint256 private s_lastTimeStamp;
    uint256 private s_subId;

    event PlayerAddedToRaffle(address indexed player);

    constructor(uint256 _entranceFee,uint256 _subId,uint256 _timeInterval)VRFConsumerBaseV2Plus(vrfCoordinator){
        i_entranceFee = _entranceFee;
        i_lotteryTimeInterval = _timeInterval;
        s_lastTimeStamp = block.timestamp;
        s_subId = _subId;
    }

    function enterRaffle() external payable{
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughFunds();
        }

        s_players.push(payable(msg.sender));
        emit PlayerAddedToRaffle(msg.sender);
    }

    function pickWinner() external {
        if(block.timestamp - s_lastTimeStamp < i_lotteryTimeInterval) revert Raffle__SetTimeHasNotElapsed();

        VRFV2PlusClient.requestRandomWords request = VRFV2PlusClient.requestRandomWords({
            keyHash:s_keyHash,
            subId:s_subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal virtual{}

111156905340625053542389350583940108777420172393988756622693613794872779825267 // subId

    /*Getter functions*/
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

 }


