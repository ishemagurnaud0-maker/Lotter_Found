//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
   

contract SubscriptionManager is Script {

function createSubscription() private returns(uint256){
    HelperConfig helperConfig = new HelperConfig();
    HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

    address vrfCoordinator = config.vrfCoordinator;

    vm.startBroadcast();
    uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
    vm.stopBroadcast();
    return subId;
}

    function run() external  returns(uint256){
        return createSubscription();
    }
}