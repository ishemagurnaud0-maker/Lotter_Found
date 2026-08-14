//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {DeployRaffleScript} from "../../script/DeployRaffle.s.sol";
import {HelperConfig, VariableConstants} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Test, console} from "forge-std/Test.sol";

contract IntergrationTest is Test {
    function setUp() {}
}