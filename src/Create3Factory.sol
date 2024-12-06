// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

// Copied from solmate/utils/CREATE3.sol
// check raw test in solmate/src/test/CREATE3.t.sol

import {Bytes32AddressLib} from "@solmate/utils/Bytes32AddressLib.sol";

/// @notice Deploy to deterministic addresses without an initcode factor.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/CREATE3.sol)
/// @author Modified from 0xSequence (https://github.com/0xSequence/create3/blob/master/contracts/Create3.sol)
library CREATE3Lib {
    using Bytes32AddressLib for bytes32;

    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 0 size               //
    // 0x37       |  0x37                 | CALLDATACOPY     |                        //
    // 0x36       |  0x36                 | CALLDATASIZE     | size                   //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 size                 //
    // 0x34       |  0x34                 | CALLVALUE        | value 0 size           //
    // 0xf0       |  0xf0                 | CREATE           | newContract            //
    //--------------------------------------------------------------------------------//
    // Opcode     | Opcode + Arguments    | Description      | Stack View             //
    //--------------------------------------------------------------------------------//
    // 0x67       |  0x67XXXXXXXXXXXXXXXX | PUSH8 bytecode   | bytecode               //
    // 0x3d       |  0x3d                 | RETURNDATASIZE   | 0 bytecode             //
    // 0x52       |  0x52                 | MSTORE           |                        //
    // 0x60       |  0x6008               | PUSH1 08         | 8                      //
    // 0x60       |  0x6018               | PUSH1 18         | 24 8                   //
    // 0xf3       |  0xf3                 | RETURN           |                        //
    //--------------------------------------------------------------------------------//
    bytes internal constant PROXY_BYTECODE = hex"67363d3d37363d34f03d5260086018f3";

    bytes32 internal constant PROXY_BYTECODE_HASH = keccak256(PROXY_BYTECODE);

    function deploy(bytes32 salt, bytes memory creationCode, uint256 value) internal returns (address deployed) {
        bytes memory proxyChildBytecode = PROXY_BYTECODE;

        address proxy;
        /// @solidity memory-safe-assembly
        assembly {
            // Deploy a new contract with our pre-made bytecode via CREATE2.
            // We start 32 bytes into the code to avoid copying the byte length.
            proxy := create2(0, add(proxyChildBytecode, 32), mload(proxyChildBytecode), salt)
        }
        require(proxy != address(0), "DEPLOYMENT_FAILED");

        deployed = getDeployed(salt);
        (bool success,) = proxy.call{value: value}(creationCode);
        require(success && deployed.code.length != 0, "INITIALIZATION_FAILED");
    }

    function getDeployed(bytes32 salt) internal view returns (address) {
        return getDeployed(salt, address(this));
    }

    function getDeployed(bytes32 salt, address creator) internal pure returns (address) {
        address proxy = keccak256(abi.encodePacked(bytes1(0xFF), creator, salt, PROXY_BYTECODE_HASH))
            // Prefix:
            // Creator:
            // Salt:
            // Bytecode hash:
            .fromLast20Bytes();

        return keccak256(abi.encodePacked(hex"d694", proxy, hex"01")) // Nonce of the proxy contract (1)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)
            .fromLast20Bytes();
    }

    // Below are self-customized!

    /**
     * @notice Gets the address of the deployed proxy contract for a specific salt.
     * @param salt The salt used for deployment.
     * @return proxy The address of the proxy contract.
     */
    function getProxyAddress(bytes32 salt) internal view returns (address proxy) {
        proxy = keccak256(abi.encodePacked(bytes1(0xFF), address(this), salt, PROXY_BYTECODE_HASH)).fromLast20Bytes();
    }

    function getCreator() internal view returns (address) {
        return address(this);
    }
}

contract Create3Factory {
    function deploy(bytes32 _salt, bytes calldata _creationCode) external returns (address) {
        bytes memory creationCode = abi.encodePacked(_creationCode);
        return CREATE3Lib.deploy(_salt, creationCode, 0);
    }

    function deploy(bytes32 _salt, bytes calldata _creationCode, bytes calldata _argsEoncodeCode)
        external
        returns (address)
    {
        bytes memory creationCode = abi.encodePacked(_creationCode, _argsEoncodeCode);
        return CREATE3Lib.deploy(_salt, creationCode, 0);
    }

    function computeAddress(bytes32 _salt) external view returns (address computedAddress) {
        computedAddress = CREATE3Lib.getDeployed(_salt);
    }

    function getProxyAddress(bytes32 _salt) external view returns (address) {
        return CREATE3Lib.getProxyAddress(_salt);
    }

    function getCreator() external view returns (address) {
        return CREATE3Lib.getCreator();
    }
}
