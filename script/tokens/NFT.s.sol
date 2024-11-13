// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../../src/tokens/NFT.sol";

contract NFTScript is Script {
    function run() external {
        uint256 runnerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        address runnerAddress = vm.addr(runnerPrivateKey);
        vm.startBroadcast(runnerPrivateKey);

        NFT nft = new NFT(
            "NFT_tutorial",
            "TUT",
            "baseUri",
            runnerAddress,
            5 gwei,
            10000
        );

        vm.stopBroadcast();
    }
}
