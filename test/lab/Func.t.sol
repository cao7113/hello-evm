// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.4 <0.9.0;

contract Example {
    function f() public payable returns (bytes4) {
        assert(this.f.address == address(this));
        return this.f.selector;
    }

    function g() public {
        this.f{gas: 10, value: 800}();
    }
}

library ArrayUtils {
    // internal functions can be used in internal library functions because
    // they will be part of the same code context
    function map(uint256[] memory self, function (uint) pure returns (uint) f)
        internal
        pure
        returns (uint256[] memory r)
    {
        r = new uint256[](self.length);
        for (uint256 i = 0; i < self.length; i++) {
            r[i] = f(self[i]);
        }
    }

    function reduce(uint256[] memory self, function (uint, uint) pure returns (uint) f)
        internal
        pure
        returns (uint256 r)
    {
        r = self[0];
        for (uint256 i = 1; i < self.length; i++) {
            r = f(r, self[i]);
        }
    }

    function range(uint256 length) internal pure returns (uint256[] memory r) {
        r = new uint256[](length);
        for (uint256 i = 0; i < r.length; i++) {
            r[i] = i;
        }
    }
}

contract Pyramid {
    using ArrayUtils for *;

    function pyramid(uint256 l) public pure returns (uint256) {
        return ArrayUtils.range(l).map(square).reduce(sum);
    }

    function square(uint256 x) internal pure returns (uint256) {
        return x * x;
    }

    function sum(uint256 x, uint256 y) internal pure returns (uint256) {
        return x + y;
    }
}

contract Oracle {
    struct Request {
        bytes data;
        function(uint) external callback;
    }

    Request[] private requests;

    event NewRequest(uint256);

    function query(bytes memory data, function(uint) external callback) public {
        requests.push(Request(data, callback));
        emit NewRequest(requests.length - 1);
    }

    function reply(uint256 requestID, uint256 response) public {
        // Here goes the check that the reply comes from a trusted source
        requests[requestID].callback(response);
    }
}

contract OracleUser {
    Oracle private constant ORACLE_CONST = Oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa)); // known contract
    uint256 private exchangeRate;

    function buySomething() public {
        ORACLE_CONST.query("USD", this.oracleResponse);
    }

    function oracleResponse(uint256 response) public {
        require(msg.sender == address(ORACLE_CONST), "Only oracle can call this.");
        exchangeRate = response;
    }
}
