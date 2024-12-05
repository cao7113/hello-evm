// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import "../../src/basics/7-SimplePaymentChannel.sol";

contract SimplePaymentChannelTest is Test {
    SimplePaymentChannel public payment;
    uint256 ownerPrivateKey;
    address payable public owner;
    address payable public recipient;
    uint256 ownerInitBalance = 10 ether;

    function setUp() public {
        ownerPrivateKey = 0x1;
        owner = payable(vm.addr(ownerPrivateKey));
        recipient = payable(makeAddr("recipient"));

        vm.deal(owner, ownerInitBalance);
    }

    function test_close_asRecipient() public {
        vm.prank(owner);
        payment = new SimplePaymentChannel{value: 1 ether}(recipient, 3600);
        vm.stopPrank();

        uint256 amount = 0.1 ether;
        bytes32 message = prefixed(keccak256(abi.encodePacked(address(payment), amount)));

        // Sign the message using the owner's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, message);
        bytes memory signature = abi.encodePacked(r, s, v);

        uint256 initialRecipientBalance = recipient.balance;

        vm.prank(recipient);
        payment.close(amount, signature);
        // Verify the payment was transferred
        assertEq(recipient.balance, initialRecipientBalance + amount, "Recipient did not receive payment");
        assertEq(owner.balance, ownerInitBalance - amount, "Owner balance not refund");

        // Verify has closed
        vm.expectRevert("Inactive Contract.");
        payment.close(amount, signature);

        vm.stopPrank();
    }

    function test_claimTimeout_asOwner() public {
        vm.prank(owner);
        SimplePaymentChannel pay = new SimplePaymentChannel{value: 1 ether}(owner, 0);
        pay.claimTimeout();
        assertEq(owner.balance, ownerInitBalance, "Owner balance not refund!");

        // revert when claim again
        vm.expectRevert("Inactive Contract.");
        pay.claimTimeout();

        vm.stopPrank();
    }

    function test_extend() public {
        vm.prank(owner);
        SimplePaymentChannel pay = new SimplePaymentChannel{value: 1 ether}(owner, 0);
        vm.stopPrank();

        assertEq(owner, pay.sender(), "No expected owner.");
        uint256 initExpiration = pay.expiration();

        // here require prank again???
        vm.prank(owner);
        pay.extend(initExpiration + 1);
        assertEq(pay.expiration(), initExpiration + 1, "Extend expiration failed.");
        vm.stopPrank();
    }

    /// Adds Ethereum signed message prefix
    function prefixed(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
}
