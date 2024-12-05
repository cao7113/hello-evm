// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract ABITest is Test {
    function setUp() public {}

    function test_Encode() public pure {
        assertEq(hex"", bytes(""));
        // 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000
        // console.logBytes(abi.encode(""));
        assertEq(
            abi.encode(""),
            hex"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000"
        );
    }
}
