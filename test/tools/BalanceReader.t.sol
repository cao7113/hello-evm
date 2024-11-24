// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/tools/BalanceReader.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BalanceReaderTest is Test {
    BalanceReader public reader;

    function setUp() public {
        reader = new BalanceReader();
    }

    function testGetBalances() public view {
        address[] memory accounts = _generateAddresses(3);
        uint256[] memory balances = reader.getBalances(accounts);

        assertEq(balances.length, accounts.length, "Balances array length should match accounts length");

        for (uint256 i = 0; i < accounts.length; i++) {
            assertEq(
                balances[i],
                accounts[i].balance,
                string(abi.encodePacked("Balance of account ", _addressToString(accounts[i]), " should match"))
            );
        }
    }

    function testGetBalancesExceedBatchSize() public {
        address[] memory accounts = _generateAddresses(21);
        vm.expectRevert("Batch size exceeds limit");
        reader.getBalances(accounts);
    }

    function testGetBalance() public {
        address account = address(0x123);
        vm.deal(account, 123 gwei);
        assertEq(account.balance, 123 gwei);
    }

    function _generateAddresses(uint256 count) internal pure returns (address[] memory) {
        address[] memory accounts = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            accounts[i] = address(uint160(i + 1));
        }
        return accounts;
    }

    function _addressToString(address account) internal pure returns (string memory) {
        return Strings.toHexString(uint160(account), 20);
    }
}
