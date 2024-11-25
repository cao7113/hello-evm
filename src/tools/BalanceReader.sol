// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// NOTE: direct use Multicall3.getEthBalance/1 instead
// https://github.com/mds1/multicall/blob/main/src/Multicall3.sol#L195

contract BalanceReader {
    uint256 public maxBatchSize = 20;
    uint256 public constant MAX_LIMIT = 100;

    function setBatchSize(uint256 newBatchSize) external {
        require(newBatchSize > 0, "Batch size must be greater than 0");
        require(newBatchSize <= MAX_LIMIT, "Batch size exceeds maximum limit");
        maxBatchSize = newBatchSize;
    }

    function getBalances(address[] memory accounts) public view returns (uint256[] memory balances) {
        require(accounts.length <= maxBatchSize, "Batch size exceeds limit");

        balances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            balances[i] = accounts[i].balance;
        }
    }

    function getBalance(address account) public view returns (uint256 balance) {
        balance = account.balance;
    }
}
