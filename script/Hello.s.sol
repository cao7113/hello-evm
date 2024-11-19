// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Hello} from "../src/Hello.sol";

contract HelloScript is Script {
    function setUp() public {}

    function run() public {
        // uint256 runnerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        uint256 runnerPrivateKey = vm.envUint("T0_KEY");

        vm.startBroadcast(runnerPrivateKey);
        new Hello();
        vm.stopBroadcast();
    }
}
