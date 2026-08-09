//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
    

    abstract contract VariableConstants {
        uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
        uint256 public constant ANVIL_CHAIN_ID = 31337;

        uint96 public constant MOCK_BASE_FEE = 0.25 ether;
        uint96 public constant MOCK_GAS_PRICE_LINK = 1e9;
        int256 public constant MOCK_WEI_UNIT_LINK = 1e18;
    }
    

contract HelperConfig is VariableConstants, Script {

    error HelperConfig__NoNetworkConfigForChainId();

    struct NetworkConfig {
    uint256 entranceFee;
    uint256 lotteryTimeInterval;
    uint256 subscriptionId;
    bytes32 gaslane;
    uint32 callbackGasLimit;
    address vrfCoordinator;
}




    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;


constructor() {
    networkConfigs[SEPOLIA_CHAIN_ID] = getSepoliaETHConfig();
}

function getConfigByChainId(uint256 chainId) public returns(NetworkConfig memory) {
    if (networkConfigs[chainId].vrfCoordinator != address(0)) {
        return networkConfigs[chainId];
    } else if (chainId == ANVIL_CHAIN_ID) {
        return getLocalChainConfig();
    } else {
        revert HelperConfig__NoNetworkConfigForChainId();
    }
}

    function getSepoliaETHConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            lotteryTimeInterval: 30,
            subscriptionId: 0,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gaslane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000
        });
    }

    function getLocalChainConfig() public returns(NetworkConfig memory) {
        if(localNetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }

         vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK,MOCK_WEI_UNIT_LINK);
        vm.stopBroadcast();

       localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            lotteryTimeInterval: 30,
            subscriptionId: 0,
            vrfCoordinator: address(vrfCoordinator),
            gaslane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000
        });

        return localNetworkConfig;

    }

function getConfig() external returns(NetworkConfig memory) {
    return getConfigByChainId(block.chainid);
    }

    
} 