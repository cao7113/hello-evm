// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract Ac {
    address public msgSender;
    constructor() {
        msgSender = msg.sender;
    }
    function setSender() public {
        msgSender = msg.sender;
    }
}

contract AcTest is Test {
    Ac public ac;

    function setUp() public {
        console.log("msg.sender in setup", msg.sender);
        ac = new Ac();
        console.log("msg.sender of contract in setup", ac.msgSender());

        // msg.sender in setup 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        // msg.sender of contract in setup 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
    }

    function test_setSender() public {
        console.log("default msg sender", ac.msgSender());
        ac.setSender();
        console.log(
            "new msg sender after setSender in test_setSender",
            ac.msgSender()
        );

        // default msg sender 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        // new msg sender after setSender in test_setSender 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
    }

    function test_setSenderWithPrank() public {
        uint256 defaultBal = ac.msgSender().balance;
        console.log(
            "default msg sender",
            ac.msgSender(),
            "with balance:",
            defaultBal
        );

        address addr = address(7);
        vm.prank(addr);
        ac.setSender();
        console.log(
            "new msg sender",
            ac.msgSender(),
            "after setSender in test_setSenderWithPrank"
        );

        // get and set account's native balance
        console.log("blance is 0 after prank, can use vm.deal to set balance");
        uint256 bal = addr.balance;
        assertEq(bal, 0);
        vm.deal(addr, 1 gwei);
        assertEq(addr.balance, 1000000000);

        vm.stopPrank();

        // default msg sender 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
        // new msg sender after setSender in test_setSender 0x0000000000000000000000000000000000000007
    }
}
