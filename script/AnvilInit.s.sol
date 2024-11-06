// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Create2} from "../src/Create2.sol";
import {Counter} from "../src/Counter.sol";
import {Test20} from "../src/tokens/Test20.sol";
import {NFT} from "../src/tokens/NFT.sol";

// check whether existed on a pre-known address?

contract AnvilInitScript is Script {
    Create2 public create2Deployer;
    Counter public counter;

    // require nonce = 0
    address mustRunnerAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    // Create2 deployer address:  0x5FbDB2315678afecb367f032d93F642f64180aa3
    // Counter contract address:  0xfe401ec7fBcc826338f8b63bbAca0b09a3Aef0D6
    // Test20 contract address:  0xa4BFDCF8dC43415e9a56Bf8066cC8660De5A695d
    // Hero NFT address:  0xc4B5D23666480Ef1E8C3f49532184F41B83C50B0
    bytes32 salt = "123456";

    function setUp() public {}

    function run() public {
        uint256 runnerPrivateKey = vm.envUint("SCRIPT_RUNNER_PRIVATE_KEY");
        address runnerAddress = vm.addr(runnerPrivateKey);
        uint256 nonce = getNonce(runnerAddress);
        require(nonce == 0, "Init runner nonce should be 0, aborting deployment.");
        require(runnerAddress == mustRunnerAddress, "Unmatched deployer");

        vm.startBroadcast(runnerPrivateKey);

        create2Deployer = new Create2();
        console.log("Create2 deployer address: ", address(create2Deployer));

        // deploy Counter
        bytes memory initCode = abi.encodePacked(type(Counter).creationCode);
        address computedCounterAddress = create2Deployer.computeAddress(salt, keccak256(initCode));
        address deployedAddress = create2Deployer.deploy(salt, initCode);
        console.log("Counter contract address: ", deployedAddress);
        require(computedCounterAddress == deployedAddress, "create2 counter computed-address invalid");
        Counter(deployedAddress).increment();
        uint256 num = Counter(deployedAddress).number();
        require(num == 1, "counter number != 1");

        // deploy test20 by create2
        initCode = abi.encodePacked(
            type(Test20).creationCode, abi.encode("Local Test20", "Test20", uint8(6), uint256(10000000000))
        );
        address test20Address = create2Deployer.deploy(salt, initCode);
        console.log("Test20 contract address: ", test20Address);

        // todo: refactor
        // uint256 bal = Test20(test20Address).balanceOf(runnerAddress);
        // string memory name = Test20(test20Address).name();
        // console.log("test20: runnerAddress blance: ", bal, ", name: ", name);
        // bal = Test20(test20Address).balanceOf(address(create2Deployer));
        // console.log("test20: create2 deployer blance of test20: ", bal);

        // deploy nft by create2
        initCode = abi.encodePacked(type(NFT).creationCode, abi.encode("Hero NFT", "Hero", "blank://hero-url"));
        address nftAddress = create2Deployer.deploy(salt, initCode);
        console.log("Hero NFT contract address: ", nftAddress);
        uint256 mintValue = NFT(nftAddress).MINT_PRICE();
        uint256 token_id = NFT(nftAddress).mintTo{value: mintValue}(runnerAddress);
        require(token_id == 1, "init mint hero token != 1");

        vm.stopBroadcast();
    }

    // Helper function to get the nonce of an address
    function getNonce(address addr) internal view returns (uint256) {
        return addr == address(0) ? 0 : vm.getNonce(addr);
    }
}
