// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/StdStorage.sol";
import "solmate/tokens/ERC721.sol";
import "../../src/tokens/ERC721Token.sol";

contract ERC721TokenTest is Test {
    using stdStorage for StdStorage;

    ERC721Token private nft;
    address constant runnerAddress = address(123);
    uint256 public fee;

    function setUp() public {
        nft = new ERC721Token("ERC721Token_tutorial", "TUT", "baseUri", runnerAddress, 5 gwei, 10_000);
        fee = nft.mintPrice();
    }

    function test_constructorInfo() public view {
        assertEq(runnerAddress, nft.owner());
        assertEq(nft.totalSupply(), 10_000);
        assertEq(nft.mintPrice(), 5 gwei);
        assertEq(fee, 5 gwei);
    }

    function test_invalidSupply() public {
        vm.expectRevert(InvalidSupply.selector);
        new ERC721Token("ERC721Token_tutorial", "TUT", "baseUri", runnerAddress, 5 gwei, 0);
    }

    function test_RevertMintWithoutValue() public {
        vm.expectRevert(MintPriceNotPaid.selector);
        nft.mintTo(address(1));
    }

    function test_MintPricePaid() public {
        nft.mintTo{value: nft.mintPrice()}(address(1));
    }

    function test_changeBaseURIAsOwner() public {
        // console.log("## balance of runnerAddress", runnerAddress.balance);
        assertEq(runnerAddress.balance, 0);
        vm.startPrank(runnerAddress);
        // console.log(
        //     "## balance of runnerAddress after startPrank",
        //     runnerAddress.balance
        // );
        assertEq(runnerAddress.balance, 0);
        assertNotEq(nft.baseURI(), "new://base-url");
        nft.setBaseURI("new://base-url");
        vm.stopPrank();
        assertEq(nft.baseURI(), "new://base-url");
    }

    // todo: why failed ???
    // function test_RevertMintToZeroAddress() public {
    //     vm.expectRevert("INVALID_RECIPIENT");
    //     nft.mintTo{value: nft.mintPrice()}(address(0));
    // }
    function test_RevertMintToZeroAddress() public {
        vm.expectRevert("INVALID_RECIPIENT");
        nft.mintTo{value: fee}(address(0));
    }

    function test_RevertMintMaxSupplyReached() public {
        uint256 slot = stdstore.target(address(nft)).sig("currentTokenId()").find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10_000));
        vm.store(address(nft), loc, mockedCurrentTokenId);

        assertEq(nft.totalSupply(), 10_000);
        assertEq(nft.currentTokenId(), 10_000);

        vm.expectRevert(MaxSupply.selector);
        nft.mintTo{value: fee}(address(1));
    }

    function test_NewMintOwnerRegistered() public {
        nft.mintTo{value: nft.mintPrice()}(address(1));
        uint256 slotOfNewOwner = stdstore.target(address(nft)).sig(nft.ownerOf.selector).with_key(address(1)).find();

        uint160 ownerOfTokenIdOne = uint160(uint256((vm.load(address(nft), bytes32(abi.encode(slotOfNewOwner))))));
        assertEq(address(ownerOfTokenIdOne), address(1));
    }

    function test_BalanceIncremented() public {
        nft.mintTo{value: nft.mintPrice()}(address(1));
        uint256 slotBalance = stdstore.target(address(nft)).sig(nft.balanceOf.selector).with_key(address(1)).find();

        uint256 balanceFirstMint = uint256(vm.load(address(nft), bytes32(slotBalance)));
        assertEq(balanceFirstMint, 1);

        nft.mintTo{value: nft.mintPrice()}(address(1));
        uint256 balanceSecondMint = uint256(vm.load(address(nft), bytes32(slotBalance)));
        assertEq(balanceSecondMint, 2);
    }

    function test_SafeContractReceiver() public {
        Receiver receiver = new Receiver();
        nft.mintTo{value: nft.mintPrice()}(address(receiver));
        uint256 slotBalance =
            stdstore.target(address(nft)).sig(nft.balanceOf.selector).with_key(address(receiver)).find();

        uint256 balance = uint256(vm.load(address(nft), bytes32(slotBalance)));
        assertEq(balance, 1);
    }

    function test_RevertUnSafeContractReceiver() public {
        // Adress set to 11, because first 10 addresses are restricted for precompiles
        vm.etch(address(11), bytes("mock code"));

        vm.expectRevert(bytes(""));
        nft.mintTo{value: fee}(address(11));
    }

    function test_WithdrawalWorksAsOwner() public {
        // Mint an ERC721Token, sending eth to ERC721Token contract
        Receiver receiver = new Receiver();
        nft.mintTo{value: fee}(address(receiver));

        address payable withdrawTo = payable(runnerAddress);
        uint256 priorPayeeBalance = withdrawTo.balance;
        assertEq(priorPayeeBalance, 0);

        uint256 nftBalance = address(nft).balance;
        // Check that the balance of the contract is correct
        assertEq(nftBalance, fee);

        vm.startPrank(runnerAddress);
        // Withdraw the balance and assert it was transferred
        nft.withdrawPayments(withdrawTo);
        assertEq(withdrawTo.balance, priorPayeeBalance + nftBalance);
        vm.stopPrank();
    }

    function test_WithdrawalFailedAsOwner() public {
        address payable withdrawTo = payable(runnerAddress);
        uint256 priorPayeeBalance = withdrawTo.balance;
        assertEq(priorPayeeBalance, 0);

        uint256 nftBalance = address(nft).balance;
        // Check that the balance of the contract is correct
        assertEq(nftBalance, 0);

        vm.startPrank(runnerAddress);
        // No balance to withdraw and revert
        vm.expectRevert(NoBalanceToWithdraw.selector);
        nft.withdrawPayments(withdrawTo);
        assertEq(withdrawTo.balance, priorPayeeBalance + nftBalance);
        vm.stopPrank();
    }

    function test_WithdrawalFailsAsNotOwner() public {
        // Mint an ERC721Token, sending eth to the contract
        Receiver receiver = new Receiver();
        nft.mintTo{value: nft.mintPrice()}(address(receiver));
        // Check that the balance of the contract is correct
        assertEq(address(nft).balance, nft.mintPrice());
        // Confirm that a non-owner cannot withdraw
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(0xd3ad));
        nft.withdrawPayments(payable(address(0xd3ad)));
        vm.stopPrank();
    }
}

contract Receiver is ERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 id, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
}
