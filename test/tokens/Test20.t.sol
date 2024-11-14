// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/StdStorage.sol";
import "../../src/tokens/Test20.sol";

contract Test20Test is Test {
    Test20 private test20;
    address constant runnerAddress = address(123);

    function setUp() public {
        test20 = new Test20(
            "Local USDT",
            "USDT",
            4,
            runnerAddress,
            10 ** (4 + 4)
        );
    }

    function test_constructorInfo() public view {
        assertEq(test20.name(), "Local USDT");
        assertEq(test20.symbol(), "USDT");
        assertEq(test20.decimals(), 4);
        assertEq(test20.initHolder(), runnerAddress);
        assertEq(test20.initSupply(), 10 ** 8);

        assertEq(test20.balanceOf(runnerAddress), 100000000);
        assertEq(test20.balanceOf(address(1)), 0);
    }
}
