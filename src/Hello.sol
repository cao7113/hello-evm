// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract Hello {
    string public message;

    function set(string memory _message) public {
        message = _message;
    }

    function get() public view returns (string memory) {
        return message;
    }
}
