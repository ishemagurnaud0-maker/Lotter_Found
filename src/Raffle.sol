
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
//import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";




/**
* @title A sample Raffle Contract 
* @author Ishema Gurnaud
*@notice Contract for raffles and getting lottery winners
* @dev   Contract for testing VRFv2.5
 */


 contract Raffle is VRFConsumerBaseV2Plus{

error Raffle__NotEnoughFunds();
error Raffle__NotTheWinner();
error Raffle__SetTimeHasNotElapsed();
error Raffle__PaymentFailed();
error Raffle__RaffleHasClosed();

    enum RaffleState{
        OPEN,
        CLOSED
    }

    uint256 private immutable i_lotteryTimeInterval;
    uint256 private immutable i_entranceFee;
    uint256 private i_subscriptionId;
    bytes32 private i_keyHash;
    uint32 private i_callbackGasLimit;

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint16 private constant NUM_WORDS = 1;

    address payable[] s_players;
    uint256 private s_lastTimeStamp;
    address public s_recentWinner;
    RaffleState private s_raffleState;
    
    

    event PlayerAddedToRaffle(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(uint256 _entranceFee,uint256 _subId,uint256 _timeInterval,address vrfCoordinator,bytes32 _gaslane,uint32 _callbackGasLimit)VRFConsumerBaseV2Plus(vrfCoordinator){
        i_entranceFee = _entranceFee;
        i_keyHash = _gaslane;
        i_lotteryTimeInterval = _timeInterval;
        i_subscriptionId = _subId;
        i_callbackGasLimit = _callbackGasLimit;
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
        
    }

    function enterRaffle() external payable{
        if(s_raffleState != RaffleState.OPEN){
            revert Raffle__RaffleHasClosed();
        }

        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughFunds();
        }

        s_players.push(payable(msg.sender));
        emit PlayerAddedToRaffle(msg.sender);
    }

function checkUpKeep(bytes memory /*checkData*/ ) public view returns (bool upKeepNeeded, bytes memory /*checkData*/) {
     uint256 timeDifference = block.timestamp - s_lastTimeStamp;

    bool timeHasElapsed = timeDifference > i_lotteryTimeInterval;
    bool hasplayers = s_players.length > 0;
    bool isOpen = s_raffleState == RaffleState.OPEN;
    bool hasBalance = address(this).balance > 0;
    upKeepNeeded = timeHasElapsed && hasplayers && isOpen && hasBalance;

    return (upKeepNeeded, "0x0");
}




    function performUpkeep(bytes memory /*performData*/ ) external {
        (bool upKeepNeeded,) = checkUpKeep("");

        if(!upKeepNeeded){
            revert Raffle__SetTimeHasNotElapsed();
        }
 
        s_raffleState = RaffleState.CLOSED;

    VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });

         s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 /*requestId*/, uint256[] calldata randomWords) internal override{
        uint256 winnerIndex = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[winnerIndex];
        s_recentWinner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        emit WinnerPicked(recentWinner);

        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__PaymentFailed();
        }

    }

    //111156905340625053542389350583940108777420172393988756622693613794872779825267 // subId

    /*Getter functions*/
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

    function getRecentWinner() external view returns(address) {
        return s_recentWinner;
    }

 }


