// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract TypesTest is Test {
    function setUp() public {}

    function test_Div() public pure {
        // below compile failed
        // uint8 i = 5 / 2;
        // require(i == 2, "5/2 != 2.5");
    }

    function testString() public pure {
        // assertEq("a" "b", "ab");

        string memory a =
            "abc\
def";
        assertEq(a, "abcdef", "not equal");
        // string memory a = unicode"Hello 😃";

        //  The value of the literal will be the binary representation of the hexadecimal sequence.
        // Multiple hexadecimal literals separated by whitespace are concatenated into a single literal: hex"00112233" hex"44556677" is equivalent to hex"0011223344556677"
        string memory a1 = hex"00112233" hex"44556677";
        string memory a2 = hex"0011223344556677";
        assertEq(a1, a2);
    }

    function testBytesN() public pure {
        assertEq(hex"1122", bytes.concat(hex"11", hex"22"));
    }
}
