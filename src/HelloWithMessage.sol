// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract HelloWithMessage {
    string internal message;

    constructor(string memory _message) {
        message = _message;
    }

    // anyone can set message
    function set(string memory _message) public {
        message = _message;
    }

    function get() public view returns (string memory) {
        return message;
    }
}
