// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Frozeable {
    bool private _frozen = false;

    modifier notFrozen() {
        require(!_frozen, "Inactive Contract.");
        _;
    }

    function freeze() internal {
        _frozen = true;
    }
}

contract SimplePaymentChannelV2 is Frozeable {
    address payable public sender; // The account sending payments.
    address payable public recipient; // The account receiving the payments.
    uint256 public expiration; // Timeout in case the recipient never closes.

    constructor(address payable recipientAddress, uint256 duration) payable {
        sender = payable(msg.sender);
        recipient = recipientAddress;
        expiration = block.timestamp + duration;
    }

    /// the recipient can close the channel at any time by presenting a
    /// signed amount from the sender. the recipient will be sent that amount,
    /// and the remainder will go back to the sender
    function close(uint256 amount, bytes memory signature) external notFrozen {
        require(msg.sender == recipient, "Invalid recipient.");
        require(isValidSignature(amount, signature), "Invalid signature.");

        recipient.transfer(amount);
        freeze();
        sender.transfer(address(this).balance);
    }

    /// the sender can extend the expiration at any time
    function extend(uint256 newExpiration) external notFrozen {
        require(msg.sender == sender, "Not owner.");
        require(newExpiration > expiration, "Too less newExpiration");

        expiration = newExpiration;
    }

    /// if the timeout is reached without the recipient closing the channel,
    /// then the Ether is released back to the sender.
    function claimTimeout() external notFrozen {
        require(block.timestamp >= expiration, "Not expiration.");
        freeze();
        sender.transfer(address(this).balance);
    }

    function isValidSignature(uint256 amount, bytes memory signature) internal view returns (bool) {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        return ECDSA.recover(message, signature) == sender;
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
}
