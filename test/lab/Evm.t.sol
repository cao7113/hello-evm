// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract A {
    address public msgSender;

    constructor() {
        msgSender = msg.sender;
    }

    function setSender() public {
        msgSender = msg.sender;
    }
}

contract ATest is Test {
    A public ac;

    function setUp() public {
        // fixed from forge-test
        address defaultTester = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        assertEq(msg.sender, defaultTester);

        // 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        address testContractAddress = address(this);
        ac = new A();
        // above operator is testContractAddress
        assertEq(ac.msgSender(), testContractAddress);
    }

    function test_setSenderWithoutPrank() public {
        assertEq(ac.msgSender(), address(this));
        ac.setSender();
        assertEq(ac.msgSender(), address(this));
    }

    function test_setSenderWithPrank() public {
        uint256 defaultBal = ac.msgSender().balance;
        assertEq(ac.msgSender(), address(this));
        assertEq(defaultBal, 0xFFFFFFFFFFFFFFFFFFFFFFFF);

        address addr = makeAddr("some xxx random account");
        // switch sender
        vm.prank(addr);
        // default has 0 balance
        assertEq(addr.balance, 0);
        ac.setSender();
        assertEq(ac.msgSender(), addr);
        vm.stopPrank();
    }

    function testAccountUtils() public {
        address a;
        uint256 ak;
        assertEq(a, address(0));
        assertEq(ak, 0);
        (a, ak) = makeAddrAndKey("some account");
        assertEq(a, vm.addr(ak));
        assertEq(a.balance, 0);
        vm.deal(a, 1 gwei);
        assertEq(a.balance, 1_000_000_000);

        address a1 = makeAddr("x account");
        address a2 = makeAddr("x account");
        assertEq(a1, a2);
    }

    function testGasUsage() public {
        address addr = makeAddr("a account");
        vm.prank(addr);
        assertEq(addr.balance, 0);
        // no balance but can send transaction!
        // below no effect!!
        // vm.txGasPrice(1 gwei);
        ac.setSender();
        assertEq(ac.msgSender(), addr);
        // also is 0 after setSender transaction, no gas cost or gas-price?
        // This demonstrates that during tests, gas fees are not deducted from balances when using Foundry.
        // This is a feature of Foundry's simulation environment, which does not model real-world gas consumption and balance deductions unless explicitly configured.
        assertEq(addr.balance, 0);
        vm.stopPrank();
    }
}
