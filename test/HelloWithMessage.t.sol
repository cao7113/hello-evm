// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {HelloWithMessage} from "../src/HelloWithMessage.sol";

contract HelloWithMessageTest is Test {
    HelloWithMessage public hello;

    function setUp() public {
        hello = new HelloWithMessage("hi");
    }

    function test_Greeting() public {
        assertEq(hello.get(), "hi");

        // anyone can set hello message
        address setter = address(123);
        vm.prank(setter);
        hello.set("hello");
        assertEq(hello.get(), "hello");
        vm.stopPrank();
    }
}
