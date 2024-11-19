// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Hello {
    string public message;

    function set(string memory _message) public {
        message = _message;
    }
}
