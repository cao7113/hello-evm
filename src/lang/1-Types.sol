// SPDX-License-Identifier: UNLICENCED
pragma solidity >=0.4.16 <0.9.0;
// variables always have a default value dependent on its type.

contract Types {
    // bool
    // The operators || and && apply the common short-circuiting rules. This means that in the expression f(x) || g(y), if f(x) evaluates to true, g(y) will not be evaluated even if it may have side-effects.

    // Integers
    // uint and int are aliases for uint256 and int256, respectively
    // Bit operators: &, |, ^ (bitwise exclusive or), ~ (bitwise negation)
    // ~int256(0) == int256(-1)
    // type(X).min and type(X).max to access the minimum and maximum value representable by the type.
    function minMax() public pure {
        require(type(uint8).min == 0, "min not 0.");
        require(type(uint8).max == 255, "min not 0.");
    }

    function checkedRevert() public pure {
        uint8 i = 200;
        i = i + 200;
    }

    function uncheckedWrapping() public pure returns (uint8) {
        uint8 i = 200;
        unchecked {
            i = i + 200;
        }
        return i;
    }

    // In Solidity, division rounds towards zero. This means that int256(-5) / int256(2) == int256(-2).

    //     This means that modulo results in the same sign as its left operand (or zero) and a % n == -(-a % n) holds for negative a:
    // int256(5) % int256(2) == int256(1)
    // int256(5) % int256(-2) == int256(1)
    // int256(-5) % int256(2) == int256(-1)
    // int256(-5) % int256(-2) == int256(-1)

    // Note that 0**0 is defined by the EVM as 1.

    // ufixed and fixed are aliases for ufixed128x18 and fixed128x18, respectively

    // Address
    // Implicit conversions from address payable to address are allowed, whereas conversions from address to address payable must be explicit via payable(<address>).
    // Explicit conversions to and from address are allowed for uint160, integer literals, bytes20 and contract types.

    // For a contract C you can use type(C) to access type information about the contract.

    // Fixed-size byte arrays
    // The value types bytes1, bytes2, bytes3, …, bytes32 hold a sequence of bytes from one to up to 32.
}
