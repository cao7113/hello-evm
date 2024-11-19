// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Create2} from "../src/Create2.sol";
import {Counter} from "../src/Counter.sol";
import {ERC20Token} from "../src/tokens/ERC20Token.sol";
import {ERC721Token} from "../src/tokens/ERC721Token.sol";

// check whether existed on a pre-known address?

contract AnvilInitScript is Script {
    Create2 public create2Deployer;
    Counter public counter;

    // require nonce = 0
    address mustRunnerAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
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

        // deploy Counter
        bytes memory initCode = abi.encodePacked(type(Counter).creationCode);
        address computedCounterAddress = create2Deployer.computeAddress(salt, keccak256(initCode));
        address counterAddress = create2Deployer.deploy(salt, initCode);
        require(computedCounterAddress == counterAddress, "create2 counter computed-address invalid");
        Counter(counterAddress).increment();
        uint256 num = Counter(counterAddress).number();
        require(num == 1, "counter number != 1");

        // deploy erc20token by create2
        initCode = abi.encodePacked(
            type(ERC20Token).creationCode,
            abi.encode("USDT Mock", "USDT", uint8(6), runnerAddress, uint256(10 ** (6 + 6)))
        );
        address erc20tokenAddress = create2Deployer.deploy(salt, initCode);

        // deploy nft by create2
        initCode = abi.encodePacked(
            type(ERC721Token).creationCode,
            abi.encode("Hero ERC721Token", "Hero", "blank://todo-hero-url", runnerAddress, 100 gwei, uint256(10_000))
        );

        address nftAddress = create2Deployer.deploy(salt, initCode);
        uint256 mintValue = ERC721Token(nftAddress).mintPrice();
        uint256 token_id = ERC721Token(nftAddress).mintTo{value: mintValue}(runnerAddress);
        require(token_id == 1, "init mint hero token != 1");

        // try write final result
        console.log("## Anvil Create Init Result Begin");
        console.log("CREATE2_FACTORY:", address(create2Deployer));
        console.log("CREATE2_COUNTER_ADDRESS:", counterAddress);
        console.log("CREATE2_USDT_MOCK_ADDRESS:", erc20tokenAddress);
        console.log("CREATE2_HERO_ADDRESS:", nftAddress);
        console.log("## Anvil Create Init Result End");

        vm.stopBroadcast();
    }

    // Helper function to get the nonce of an address
    function getNonce(address addr) internal view returns (uint256) {
        return addr == address(0) ? 0 : vm.getNonce(addr);
    }
}
