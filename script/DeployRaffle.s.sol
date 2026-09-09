//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {SubscriptionManager, FundSubscription, AddConsumer} from "./Interactions.s.sol";


contract DeployRaffleScript is Script {
    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        uint256 entranceFee = config.entranceFee;
        uint256 lotteryTimeInterval = config.lotteryTimeInterval;
        uint256 subscriptionId = config.subscriptionId;
        bytes32 gaslane = config.gaslane;
       uint32 callbackGasLimit = config.callbackGasLimit;
        address vrfCoordinator = config.vrfCoordinator;
        address link = config.link;

        if(subscriptionId == 0) {
            SubscriptionManager subscriptionManager = new SubscriptionManager();
            (subscriptionId,vrfCoordinator) = subscriptionManager.createSubscription();

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(subscriptionId, vrfCoordinator, link);

            
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(entranceFee, subscriptionId, lotteryTimeInterval, vrfCoordinator, gaslane, callbackGasLimit);
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(subscriptionId, address(raffle), vrfCoordinator);

        return (raffle, helperConfig);
    }

    function run() public returns (Raffle, HelperConfig) {
        return deployContract();
    }
}
