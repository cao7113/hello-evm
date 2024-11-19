// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/StdStorage.sol";
import "../../src/tokens/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token private erc20token;
    address constant runnerAddress = address(123);

    function setUp() public {
        erc20token = new ERC20Token("USDT Mock", "USDT", 4, runnerAddress, 10 ** (4 + 4));
    }

    function test_constructorInfo() public view {
        assertEq(erc20token.name(), "USDT Mock");
        assertEq(erc20token.symbol(), "USDT");
        assertEq(erc20token.decimals(), 4);
        assertEq(erc20token.initHolder(), runnerAddress);
        assertEq(erc20token.initSupply(), 10 ** 8);

        assertEq(erc20token.balanceOf(runnerAddress), 100_000_000);
        assertEq(erc20token.balanceOf(address(1)), 0);
    }
}
