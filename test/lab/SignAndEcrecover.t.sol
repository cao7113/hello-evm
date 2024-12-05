// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

contract SignatureVerifierTest is Test {
    address signer;
    uint256 signerPrivateKey;

    function setUp() public {
        // private key is uint256
        signerPrivateKey = 0x123456789abcdef123456789abcdef123456789abcdef123456789abcdef1234;
        signer = vm.addr(signerPrivateKey);
    }

    /// recommend standard sign method! avoid reuse attack! compacted with Metamask tools!
    function testEthSign() public view {
        bytes32 messageHash = keccak256(abi.encodePacked("Hello, Foundry!"));
        bytes32 prefixedMsgHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, prefixedMsgHash);
        address recoveredSigner = ecrecover(prefixedMsgHash, v, r, s);
        assertEq(recoveredSigner, signer, "Recovered signer does not match the expected signer");
    }

    function testSignOnAnyBytes32Msg() public view {
        // bytes32 message32 = keccak256("Hello, Foundry!");
        bytes32 message32 = bytes32("Hello, Foundry!");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, message32);
        address recoveredSigner = ecrecover(message32, v, r, s);
        assertEq(recoveredSigner, signer, "Recovered signer does not match the expected signer");
    }

    // function testFoundryVmPrivateKeyBehavior() public pure {
    //     address vmSigner = address(0x1);
    //     // This assumption is not true!!!
    //     uint256 vmSignerPrivateKey = uint256(uint160(vmSigner));

    //     bytes32 messageHash = keccak256(abi.encodePacked("Hello, Foundry!"));
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(vmSignerPrivateKey, messageHash);
    //     address recoveredSigner = ecrecover(messageHash, v, r, s);
    //     // assertEq(recoveredSigner, vmSigner, "Recovered signer does not match the expected signer");
    //     assertNotEq(recoveredSigner, vmSigner, "Recovered signer match the expected signer");
    // }

    // EIP-191: "Ethereum Signed Message" Standard
    // todo url
    // eth_sign 使用的哈希是将消息哈希加上一个固定前缀（"\x19Ethereum Signed Message:\n" + len(messageHash)）后重新哈希得到的。
    // 链外签名：off-chain signing
    // 消息前缀：保证签名仅适用于链外消息。"\x19Ethereum Signed Message:\n" 表明这是以太坊链外签名。
    // 防止签名被恶意使用，因为链外签名明确表明不能直接用于链上执行。
    // bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", uint256(len(message)), message));
    function testRemixSigIsEthSignOnRawMessageHash() public pure {
        address paymentContract = 0xDA0bab807633f07f013f94DD0E6A4F96F8742B53;
        uint256 amount = 1000 wei;
        bytes32 messageHash = keccak256(abi.encodePacked(paymentContract, amount));
        console.log("payment message hash:");
        console.logBytes32(messageHash);
        bytes32 ethMessageHash = prefixed(messageHash);
        console.log("payment eth-message hash:");
        console.logBytes32(ethMessageHash);

        // Logs:
        //   payment message hash:
        //   0x73ded127aa54b4311a857e9617f35e947a3598e887a955b9c314701dcabc0522
        //   payment eth-message hash:
        //   0x9e8ec29f21856616fd5b3022deb120abafa909d77d3351c98313bf74cc57c311

        // bytes memory remixSigOnEthMessageHash = hex"b342f0354153cea0955e77f9018ebe8236b56c134ebd235068874799550de61f715b4e9d7f3bf3422f0d9898231d4851bd4d8498e3c8484f3d956a32005a85cc1c";
        // NOTE: remix sign on raw message hash intead eth-prefixed message hash
        // that is Remix sign is eth-sign!!!
        bytes memory remixSigOnMessageHash =
            hex"784590cd39d748d310c1261905452d6cae6f8c6af342c6740a90b108a2672ed64297ab4bf3f3c1076f64b1cba369f6feb5dd036961e2a7a45299069e12704fe61b";
        address recoveredAddr = recoverSigner(ethMessageHash, remixSigOnMessageHash);
        address wantAddr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        assertEq(recoveredAddr, wantAddr);
    }

    // EIP-712: "Typed Structured Data" Signing
    // todo

    /// All functions below this are just taken from the chapter
    /// 'creating and verifying signatures' chapter.
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "Invalid signature length.");

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    /// Adds Ethereum signed message prefix
    function prefixed(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
}
