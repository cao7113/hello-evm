// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// https://docs.soliditylang.org/en/v0.8.28/units-and-global-variables.html

import {Test, console} from "forge-std/Test.sol";

contract A {
    struct Info {
        address sender;
        bytes data;
        bytes4 sig;
        uint256 age;
    }

    function info(uint256 age) public view returns (Info memory) {
        return Info(msg.sender, msg.data, msg.sig, age);
    }
}

contract UnitsAndGlobalsTest is Test {
    A a;

    function setUp() public {
        a = new A();
    }

    function testUnits() public pure {
        assert(1 wei == 1);
        assert(1 gwei == 1e9);
        assert(1 ether == 1e18);

        // 1 == 1 seconds
        // 1 minutes == 60 seconds
        // 1 hours == 60 minutes
        // 1 days == 24 hours
        // 1 weeks == 7 days
        // Note: leap seconds https://en.wikipedia.org/wiki/Leap_second

        assert(1 == 1 seconds);
        assert(60 == 1 minutes);
    }

    function testGlobals() public view {
        A.Info memory info = a.info(123);
        assertEq(info.sender, address(this));
        console.log(info.sender);
        console.logBytes(info.data);
        console.logBytes4(info.sig);
        console.log(info.age);
    }
}
