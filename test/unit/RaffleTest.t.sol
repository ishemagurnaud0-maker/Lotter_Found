//SPDX-License-Identifieer: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffleScript} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Vm} from "forge-std/Vm.sol";

contract TestRaffle is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 lotteryTimeInterval;
    uint256 subscriptionId;
    bytes32 gaslane;
    uint32 callbackGasLimit;
    address vrfCoordinator;

    address public PLAYER1 = makeAddr("PLAYER1");
    address public PLAYER2 = makeAddr("PLAYER2");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    event PlayerAddedToRaffle(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestSentToVrfCoordinator(uint256 indexed requestId);


modifier raffleEntered() {
    vm.prank(PLAYER1);
    raffle.enterRaffle{value: entranceFee}();
    vm.warp(block.timestamp + lotteryTimeInterval + 1);
    vm.roll(block.number + 1);
    _;
}

    function setUp() external {
        DeployRaffleScript deployer = new DeployRaffleScript();
        (raffle, helperConfig) = deployer.deployContract();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        lotteryTimeInterval = config.lotteryTimeInterval;
        subscriptionId = config.subscriptionId;
        gaslane = config.gaslane;
        callbackGasLimit = config.callbackGasLimit;
        vrfCoordinator = config.vrfCoordinator;

        vm.deal(PLAYER1, STARTING_USER_BALANCE);
    }

    function testRaffleInitializeOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public {
        vm.prank(PLAYER1);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEnterRaffleEntranceReverts() public {
        vm.prank(PLAYER1);
        vm.expectRevert(Raffle.Raffle__NotEnoughFunds.selector);
        raffle.enterRaffle{value: 0.001 ether}();
    }

    function testRaffleEmitsEventOnEntrance() external {
        vm.prank(PLAYER11);
        vm.expectEmit(true, false, false, false,address(raffle));
        emit Raffle.PlayerAddedToRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testPlayersCannotEnterRaffleWhileCalculatingWinner() external {
        vm.prank(PLAYER1);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + lotteryTimeInterval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__RaffleHasClosed.selector);
        raffle.enterRaffle{value: entranceFee}();

    }

    function testCheckUpkeepReviewsTime() external {

        vm.warp(block.timestamp + lotteryTimeInterval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffle.checkUpKeep("");
        assert(!upkeepNeeded);
        
    }

    function testCheckUpkeepReturnsFalseWhenRaffleIsClosed() external {

        vm.prank(PLAYER1);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + lotteryTimeInterval + 1);
        vm.roll(block.number + 1);

        raffle.performUpkeep("");

        (bool upkeepNeeded, ) = raffle.checkUpKeep("");
        assert(!upkeepNeeded);
    }


    function testCheckUpKeepReturnsTrueWhenAllConditionsAreMet() external {
        vm.prank(PLAYER1);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + lotteryTimeInterval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffle.checkUpKeep("");
        assert(upkeepNeeded);
    }
    function testEnterRaffle() external {
        vm.prank(PLAYER1);
        raffle.enterRaffle{value: entranceFee}();
        address player = raffle.getPlayer(0);
        assertEq(player, PLAYER);
    }

    function testPerformUpkeepCanOnlyRunWhenCheckUpkeepIsTrue() external {
            vm.prank(PLAYER1);
            raffle.enterRaffle{value: entranceFee}();
            vm.warp(block.timestamp + lotteryTimeInterval + 1);
            vm.roll(block.number + 1);

            raffle.performUpkeep("");
    }



    function testPerformRevertsWhenCheckUpkeepReturnsFalse() external {
        vm.prank(PLAYER1);
        raffle.enterRaffle{value: entranceFee}();
        
        vm.expectRevert(Raffle.Raffle__UpkeepNotNeeded.selector);
        raffle.performUpkeep("");

    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequest() external {
        vm.prank(PLAYER1);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + lotteryTimeInterval + 1);
        vm.roll(block.number + 1);

        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        assert(uint256(requestId) > 0);
        assert(raffle.getRaffleState() == Raffle.RaffleState.CLOSED);


    }

    function testFullFillWordsOnlyRunsWhenPerformUpkeepHasRan(uint256 randomRequestId) external raffleEntered{
       vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
       VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
    }

    function testFullFillRandomWordsPicksWinnerResetsRaffleStateAndSendsMoney() external raffleEntered {
        uint256 startingIndex = 1;
        uint256 newPlayers = 3;

        for(uint256 i = startingIndex; i < startingIndex + newPlayers; i++) {
            address newPlayer = address(uint180(i));
            vm.hoax(newPlayer,STARTING_USER_BALANCE);
            raffle.enterRaffle{value: entranceFee}();
        }

        raffle.performUpkeep("");
        
    }
}
