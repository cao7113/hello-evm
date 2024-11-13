// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/StdStorage.sol";
import "../../src/tokens/Test20.sol";

contract Test20Test is Test {
    // using stdStorage for StdStorage;
    Test20 private test20;
    address runnerAddress;

    function setUp() public {
        uint256 runnerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        runnerAddress = vm.addr(runnerPrivateKey);
        test20 = new Test20(
            "Local USDT",
            "USDT",
            4,
            10 ** (4 + 4),
            runnerAddress
        );
    }

    function test_constructorInfo() public view {
        assertEq(test20.name(), "Local USDT");
        assertEq(test20.symbol(), "USDT");
        assertEq(test20.decimals(), 4);
        assertEq(test20.balanceOf(runnerAddress), 100000000);
        assertEq(test20.balanceOf(address(1)), 0);
    }
}
