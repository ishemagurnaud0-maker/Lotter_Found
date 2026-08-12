pragma solidity ^0.8.30;


import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract SubscriptionManager is Script {

function createSubscription(address vrfCoordinator) public returns(uint256 subId){
    vm.startBroadcast();
    subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
    vm.stopBroadcast();
    return subId;
}

    function run(address vrfCoordinator) external returns (uint256 subId) {
        subId = createSubscription(vrfCoordinator);
    }
}


contract FundSubscription is Script {

    uint256 public constant FUND_AMOUNT = 5 ether;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

    function fundSubscription(uint256 subId, address vrfCoordinator, address link) public {
        if(block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
           LinkToken(link).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subId)); 
            vm.stopBroadcast();
        }
    }

    function run(uint256 subId, address vrfCoordinator, address link) external {
        fundSubscription(subId, vrfCoordinator, link);
    }
}





contract AddConsumer is Script {

    function addConsumer(uint256 subId, address consumerAddress, address vrfCoordinator) public {
       vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, consumerAddress);
        vm.stopBroadcast();
    }

    function run(uint256 subId, address consumerAddress, address vrfCoordinator) external {
        addConsumer(subId, consumerAddress, vrfCoordinator);
    }
}

