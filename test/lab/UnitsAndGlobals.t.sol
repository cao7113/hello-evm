// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// https://docs.soliditylang.org/en/v0.8.28/units-and-global-variables.html

import {Test, console} from "forge-std/Test.sol";

contract A {
    struct Info {
        address sender;
        bytes data;
        bytes4 sig;
        // bytes4 funcSig;
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
        // assertNotEq(info.sig, info.funcSig);
        console.log(info.age);
    }

    function testAddress() public {
        address addr = address(0x12345678);
        assertEq(addr.code, hex"");
        assertEq(bytes1(""), hex"");
        // 0x0000000000000000000000000000000000000000000000000000000000000000
        // console.logBytes32(addr.codehash);
        assertEq(addr.codehash, hex"0000000000000000000000000000000000000000000000000000000000000000");

        // Due to the fact that the EVM considers a call to a non-existing contract to always succeed, Solidity includes an extra check using the extcodesize opcode when performing external calls. This ensures that the contract that is about to be called either actually exists (it contains code) or an exception is raised.
        // call on non-contract address
        addr = makeAddr("unknown contract");
        assertEq(addr.code, bytes(""));
        (bool r, bytes memory rBytes) = addr.call(hex"123456");
        assertTrue(r);
        // console.log("result bytes");
        // // 0x
        // console.logBytes(rBytes);
        assertEq(rBytes, bytes(""));
        // Better use contract instance!
    }

    function testCodes() public view {
        // console.logBytes(type(A).creationCode);
        // console.logBytes(type(A).runtimeCode);
        assertEq(address(a).code, type(A).runtimeCode);
        assertNotEq(address(a).code, type(A).creationCode);
    }
}
