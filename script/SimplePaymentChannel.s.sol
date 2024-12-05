// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

contract SimplePaymentChannelScript is Script {
    function setUp() public {}

    function run() public pure {
        address paymentContract = 0xDA0bab807633f07f013f94DD0E6A4F96F8742B53;
        // second account in Remix VM
        // address receiver = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        uint256 amount = 1000 wei;
        bytes32 messageHash = keccak256(abi.encodePacked(paymentContract, amount));
        console.log("payment message hash:");
        console.logBytes32(messageHash);
        bytes32 ethMessageHash = prefixed(messageHash);
        console.log("payment eth-message hash:");
        console.logBytes32(ethMessageHash);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
}
