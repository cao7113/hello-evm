// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Create3Factory} from "../src/Create3Factory.sol";
import {Hello} from "../src/Hello.sol";
import {HelloWithMessage} from "../src/HelloWithMessage.sol";

contract Create3FactoryTest is Test {
    Create3Factory create3Factory;

    function setUp() public {
        create3Factory = new Create3Factory();
    }

    function testDeployHelloWithMessage() public {
        bytes32 salt = keccak256("mock hello-with-message salt");
        address hello1 = create3Factory.deploy(salt, type(HelloWithMessage).creationCode, abi.encode("aBc"));
        HelloWithMessage hello1Contract = HelloWithMessage(hello1);
        assertEq(hello1Contract.get(), "aBc");

        assertEq(address(create3Factory), create3Factory.getCreator());
        assertNotEq(address(this), create3Factory.getCreator());

        address proxy = create3Factory.getProxyAddress(salt);
        assertNotEq(address(create3Factory), proxy);
        console.log("proxy address", proxy);
        assert(proxy.code.length != 0);

        // deploy again using same salt
        vm.expectRevert("DEPLOYMENT_FAILED");
        create3Factory.deploy(salt, type(HelloWithMessage).creationCode, abi.encode("aBc"));
    }

    function testDeployHelloWithoutArgs() public {
        bytes32 salt = keccak256("mock hello salt");
        address hello1 = create3Factory.deploy(salt, type(Hello).creationCode);
        Hello hello1Contract = Hello(hello1);
        assertEq(hello1Contract.get(), "");

        assertEq(address(create3Factory), create3Factory.getCreator());
        assertNotEq(address(this), create3Factory.getCreator());

        address proxy = create3Factory.getProxyAddress(salt);
        assertNotEq(address(create3Factory), proxy);
        console.log("proxy address", proxy);
        assert(proxy.code.length != 0);

        // deploy again using same salt
        vm.expectRevert("DEPLOYMENT_FAILED");
        create3Factory.deploy(salt, type(Hello).creationCode);
    }

    function testProxy() public {
        Create3Factory factory1 = new Create3Factory();
        Create3Factory factory2 = new Create3Factory();
        bytes32 salt = keccak256("mock hello salt");
        // keccak256(abi.encodePacked(bytes1(0xFF), address(this), salt, PROXY_BYTECODE_HASH)).fromLast20Bytes();
        // depends on factory contract address as proxy creator
        assertNotEq(factory1.getProxyAddress(salt), factory2.getProxyAddress(salt));

        vm.prank(address(0x1));
        Create3Factory factory3 = new Create3Factory();
        assertNotEq(factory1.getProxyAddress(salt), factory3.getProxyAddress(salt));
        vm.stopPrank();
    }
}
