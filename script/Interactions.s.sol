pragma solidity ^0.8.30;


import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract SubscriptionManager is Script {

function createSubscription() public returns(uint256 subId, address vrfCoordinator){
    HelperConfig helperConfig = new HelperConfig();
    HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

     vrfCoordinator = config.vrfCoordinator;

    vm.startBroadcast();
     subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
    vm.stopBroadcast();
    return (subId, vrfCoordinator);
}

    function run() external {
         createSubscription();
    }
}


contract FundSubscription is Script {

    uint256 public constant FUND_AMOUNT = 0.01 ether;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

        function fundSubscriptionUsingConfig() internal {
            HelperConfig helperConfig = new HelperConfig();
            HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
            address vrfCoordinator = config.vrfCoordinator;
            uint256 subId = config.subscriptionId;
            address link = config.link;

            fundSubscription(subId, vrfCoordinator, link);\
    
    }

    function fundSubscription(uint256 subId, address vrfCoordinator, address link) internal {
        if(block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        }else {
            vm.startBroadcast();
           LinkToken(link).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subId)); 
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}





contract AddConsumer is Script {

function addConsumerUsingConfig(address consumerAddress) internal {
    HelperConfig helperConfig = new HelperConfig();
    HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
    address vrfCoordinator = config.vrfCoordinator;
    uint256 subId = config.subscriptionId;

    addConsumer(subId, consumerAddress, vrfCoordinator);

}

    function addConsumer(uint256 subId, address consumerAddress, address vrfCoordinator) public {
        
       vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, consumerAddress,vrfCoordinator);
        vm.stopBroadcast();
    }

    function run() external {
        address consumerAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(consumerAddress);

    }
}

}