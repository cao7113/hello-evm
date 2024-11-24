// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Hello2} from "../src/Hello2.sol";

contract Hello2Test is Test {
    Hello2 public hello;

    function setUp() public {
        hello = new Hello2();
    }

    function test_Greeting() public {
        assertEq(hello.get(), "hi");
        address setter = address(123);
        // anyone can set hello message
        vm.prank(setter);
        hello.set("hello");
        assertEq(hello.get(), "hello");
        vm.stopPrank();
    }
}
