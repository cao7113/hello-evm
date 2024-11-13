// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Hello {
    string public greeting;

    function set(string memory _greeting) public {
        greeting = _greeting;
    }
}
