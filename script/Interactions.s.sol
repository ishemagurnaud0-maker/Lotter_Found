pragma solidity ^0.8.30;


import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract SubscriptionManager is Script {

function createSubscription(address vrfCoordinator,address account) public returns(uint256 subId){
    vm.startBroadcast(account);
    subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
    vm.stopBroadcast();
    return subId;
}

    function run(address vrfCoordinator, address account) external returns (uint256 subId) {
        subId = createSubscription(vrfCoordinator, account);
    }
}


contract FundSubscription is Script {

    uint256 public constant FUND_AMOUNT = 5 ether;
    uint256 public constant LOCAL_CHAIN_ID = 31337;

    function fundSubscription(uint256 subId, address vrfCoordinator, address link, address account) public {
        if(block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast(account);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(account);
           LinkToken(link).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subId)); 
            vm.stopBroadcast();
        }
    }

    function run(uint256 subId, address vrfCoordinator, address link, address account) external {
        fundSubscription(subId, vrfCoordinator, link, account);
    }
}





contract AddConsumer is Script {

    function addConsumer(uint256 subId, address consumerAddress, address vrfCoordinator) public {
         
         ( ,,, address owner,) = VRFCoordinatorV2_5Mock(vrfCoordinator).getSubscription(subId);
         vm.startBroadcast(owner);
         VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, consumerAddress);
         vm.stopBroadcast();
    }

    function run(uint256 subId, address consumerAddress, address vrfCoordinator) external {
        addConsumer(subId, consumerAddress, vrfCoordinator);
    }
}

