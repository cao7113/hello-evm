// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Hello2 {
    string internal message;

    constructor() {
        message = "hi";
    }

    function set(string memory _message) public {
        message = _message;
    }

    function get() public view returns (string memory) {
        return message;
    }
}
