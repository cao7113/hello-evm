// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

error ZeroInitHolder();

contract Test20 is ERC20 {
    address public immutable initHolder;
    uint256 public immutable initSupply;
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _initHolder,
        uint256 _initialSupply
    ) ERC20(_name, _symbol, _decimals) {
        if (_initHolder == address(0)) {
            revert ZeroInitHolder();
        }
        initHolder = _initHolder;
        initSupply = _initialSupply;
        _mint(_initHolder, _initialSupply);
    }
}
