// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import "../../src/basics/6-ReceiverPay.sol";

contract ReceiverPaysTest is Test {
    ReceiverPays public receiverPays;
    uint256 ownerPrivateKey;
    address public owner;
    address public claimant;

    function setUp() public {
        // use handy makeAddrAndKey
        (owner, ownerPrivateKey) = makeAddrAndKey("owner");
        claimant = makeAddr("claimant");

        vm.deal(owner, 10 ether);
        vm.deal(claimant, 1 ether);

        vm.prank(owner);
        receiverPays = new ReceiverPays{value: 1 ether}();
        vm.stopPrank();
    }

    function testClaimPayment() public {
        uint256 amount = 1 ether;
        uint256 nonce = 1;

        bytes32 message = prefixed(keccak256(abi.encodePacked(claimant, amount, nonce, address(receiverPays))));

        // Sign the message using the owner's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, message);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Claim the payment as the claimant
        uint256 initialClaimantBalance = claimant.balance;

        vm.prank(claimant);
        receiverPays.claimPayment(amount, nonce, signature);
        // Verify the payment was transferred
        assertEq(claimant.balance, initialClaimantBalance + amount, "Claimant did not receive payment");

        // Verify the nonce is marked as used
        vm.expectRevert("Nonce already used!");
        receiverPays.claimPayment(amount, nonce, signature);

        vm.stopPrank();
    }

    function testFreezeAndShutdown() public {
        vm.startPrank(owner);

        uint256 initialContractBalance = address(receiverPays).balance;
        uint256 initialOwnerBalance = owner.balance;

        // // Record gas before calling shutdown
        // uint256 gasStart = gasleft();

        // Call shutdown
        receiverPays.shutdown();

        // Donot need considered gas cost in forge test environment!!!
        // // Calculate gas used
        // uint256 gasUsed = gasStart - gasleft();
        // uint256 gasCost = gasUsed * tx.gasprice;

        // Verify contract balance is zero
        assertEq(address(receiverPays).balance, 0, "Contract balance is not zero");

        // Verify remaining funds (accounting for gas cost) were transferred to the owner
        assertEq(
            owner.balance,
            // initialOwnerBalance + initialContractBalance - gasCost,
            initialOwnerBalance + initialContractBalance,
            "Owner did not receive remaining funds"
        );

        // Verify the contract is now frozen
        vm.expectRevert("Inactive Contract.");
        receiverPays.shutdown();

        vm.stopPrank();
    }

    /// Adds Ethereum signed message prefix
    function prefixed(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
}
