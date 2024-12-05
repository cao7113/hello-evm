// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;

contract MappingExample {
    mapping(address => uint256) public balances;

    function update(uint256 newBalance) public {
        balances[msg.sender] = newBalance;
    }
}

contract MappingUser {
    function f() public returns (uint256) {
        MappingExample m = new MappingExample();
        m.update(100);
        return m.balances(address(this));
    }
}
