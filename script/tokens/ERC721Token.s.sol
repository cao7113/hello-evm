// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC721Token} from "../../src/tokens/ERC721Token.sol";

contract ERC721TokenScript is Script {
    function run() external {
        uint256 runnerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        address runnerAddress = vm.addr(runnerPrivateKey);
        vm.startBroadcast(runnerPrivateKey);

        new ERC721Token("ERC721Token_tutorial", "TUT", "baseUri", runnerAddress, 5 gwei, 10000);

        vm.stopBroadcast();
    }
}
