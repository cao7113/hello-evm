// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Hello} from "../src/Hello.sol";

contract HelloTest is Test {
    Hello public hello;
    string constant message = "hello solidity in foundry!";

    function setUp() public {
        console.log("message sender", msg.sender, "init balance", msg.sender.balance);
        hello = new Hello();
    }

    function test_Greeting() public {
        assertEq(hello.message(), "");
        address setter = address(123);
        // anyone can set hello message
        vm.prank(setter);
        hello.set(message);
        assertEq(hello.message(), message);
        vm.stopPrank();
    }
}
