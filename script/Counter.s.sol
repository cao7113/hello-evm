// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    Counter public counter;

    function setUp() public {}

    function run() public {
        uint256 runnerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        vm.startBroadcast(runnerPrivateKey);

        counter = new Counter();

        vm.stopBroadcast();
    }
}
