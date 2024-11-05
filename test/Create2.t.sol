// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Create2} from "../src/Create2.sol";

contract Create2Test is Test {
    Create2 internal create2;
    Counter internal counter;

    function setUp() public {
        create2 = new Create2();
        counter = new Counter();
    }

    function testDeterministicDeploy() public {
        vm.deal(address(0x1), 100 ether);

        vm.startPrank(address(0x1));
        bytes32 salt = "12345";
        bytes memory creationCode = abi.encodePacked(
            type(Counter).creationCode
        );

        address computedAddress = create2.computeAddress(
            salt,
            keccak256(creationCode)
        );
        address deployedAddress = create2.deploy(salt, creationCode);
        vm.stopPrank();

        assertEq(computedAddress, deployedAddress);
    }

    // function testReDeploy() public {
    //     vm.deal(address(0x1), 100 ether);

    //     vm.startPrank(address(0x1));
    //     bytes32 salt = "12345";
    //     bytes memory creationCode = abi.encodePacked(
    //         type(Counter).creationCode
    //     );

    //     create2.deploy(salt, creationCode);

    //     vm.expectRevert(Create2.Create2FailedDeployment.selector);
    //     create2.deploy(salt, creationCode);
    //     vm.stopPrank();

    //     //         │   ├─ [0] → new Counter@0xeecDeD4CB8d3D24bC1e6D7cEC21DA3855dF1cAf6
    //     // │   │   └─ ← [CreateCollision] EvmError: CreateCollision
    //     // │   └─ ← [Revert] Create2FailedDeployment()
    //     // └─ ← [Revert] Create2FailedDeployment()
    // }
}
