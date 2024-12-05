// SPDX-License-Identifier: UNLICENCED
// https://docs.soliditylang.org/en/v0.8.28/layout-of-source-files.html#pragmas
pragma solidity >=0.4.16 <0.9.0;

// This is a single-line comment.

/*
This is a
multi-line comment.
*/

// NatSpec comment, which is detailed in the style guide. They are written with a triple slash (///) or a double asterisk block (/** ... */) and they should be used directly above function declarations or statements.

// https://remix-ide.readthedocs.io/en/latest/import.html

// There are also special kinds of contracts called libraries and interfaces.

library Lib {}

interface Interf {}

abstract contract AbstractCon {}

// A plain solidity contract.

contract HelloSolidity {
    // state variable stored in contract storage (persitent storage on chain)
    uint8 age;

    address public seller;

    modifier onlySeller() {
        // Modifier
        require(msg.sender == seller, "Only seller can call this.");
        _;
    }

    function abort() public view onlySeller { // Modifier usage
            // ...
    }
}

// Helper function defined outside of a contract
function helper(uint256 x) pure returns (uint256) {
    return x * 2;
}

event HighestBidIncreased(address bidder, uint256 amount); // Event

contract SimpleAuction {
    function bid() public payable {
        // ...
        emit HighestBidIncreased(msg.sender, msg.value); // Triggering event
    }
}

/// Not enough funds for transfer. Requested `requested`,
/// but only `available` available.
error NotEnoughFunds(uint256 requested, uint256 available);

contract Token {
    mapping(address => uint256) balances;

    function transfer(address to, uint256 amount) public {
        uint256 balance = balances[msg.sender];
        if (balance < amount) {
            revert NotEnoughFunds(amount, balance);
        }
        balances[msg.sender] -= amount;
        balances[to] += amount;
        // ...
    }
}

contract Ballot {
    struct Voter {
        // Struct
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }
}

contract Purchase {
    enum State {
        Created,
        Locked,
        Inactive
    } // Enum
}
