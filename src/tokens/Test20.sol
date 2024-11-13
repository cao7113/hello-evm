// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

error ZeroInitHolder();

contract Test20 is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 initialSupply,
        address initHolder
    ) ERC20(name, symbol, decimals) {
        if (initHolder == address(0)) {
            revert ZeroInitHolder();
        }
        _mint(initHolder, initialSupply);
    }
}
