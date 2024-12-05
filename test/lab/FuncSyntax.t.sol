// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract A1 {
    uint256 num;

    constructor() {
        num = 1;
    }

    function pureF() public pure returns (uint256) {
        // pure func can not access state variable
        // return num;
        return 1;
    }

    function viewF() public view returns (uint256) {
        // access state variable but can not change it.
        return num;
    }

    /// can call by contract and internal and external
    function publicF() public view returns (uint256) {
        return num;
    }

    // only call by external or this.externalF()
    function externalF() external view returns (uint256) {
        return num;
    }
}

// 总结
// 特性	view	pure
// 状态访问	读取但不修改	不读取、不修改
// 状态变量访问	可以访问	不可访问
// 特性	public	external
// 调用方式	内部和外部调用	仅外部调用（或间接内部）
// Gas 消耗	较高	较低

contract FuncSyntaxTest is Test {
    A1 a1;

    function setUp() public {
        a1 = new A1();
    }

    function test_view() public view {
        assertEq(a1.viewF(), 1);
    }
}
