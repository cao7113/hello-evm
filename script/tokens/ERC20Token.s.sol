// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC20Token} from "../../src/tokens/ERC20Token.sol";

contract ERC20TokenScript is Script {
    function run() external {
        // uint256 runnerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        uint256 runnerPrivateKey = vm.envUint("T0_KEY");

        address runnerAddress = vm.addr(runnerPrivateKey);
        vm.startBroadcast(runnerPrivateKey);

        //
        new ERC20Token("USDT Mock", "USDT", uint8(6), runnerAddress, uint256(10 ** (6 + 6)));

        vm.stopBroadcast();
    }
}
