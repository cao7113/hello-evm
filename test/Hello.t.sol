// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Hello} from "../src/Hello.sol";

contract HelloTest is Test {
    Hello public hello;
    string constant greeting = "solidity in foundry!";

    function setUp() public {
        hello = new Hello();
        hello.set(greeting);
    }

    function test_Greeting() public view {
        assertEq(hello.greeting(), greeting);
    }
}
