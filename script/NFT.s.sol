// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";

contract NFTScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        NFT nft = new NFT("NFT_tutorial", "TUT", "baseUri");

        vm.stopBroadcast();
    }
}
