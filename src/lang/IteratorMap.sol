// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

struct IndexValue {
    uint256 keyIndex;
    uint256 value;
}

struct KeyFlag {
    uint256 key;
    bool deleted;
}

struct itmap {
    mapping(uint256 => IndexValue) data;
    KeyFlag[] keys;
    uint256 size;
}

type Iterator is uint256;

library IterableMapping {
    function insert(itmap storage self, uint256 key, uint256 value) internal returns (bool replaced) {
        uint256 keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;
        if (keyIndex > 0) {
            return true;
        } else {
            keyIndex = self.keys.length;
            self.keys.push();
            self.data[key].keyIndex = keyIndex + 1;
            self.keys[keyIndex].key = key;
            self.size++;
            return false;
        }
    }

    function remove(itmap storage self, uint256 key) internal returns (bool success) {
        uint256 keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0) {
            return false;
        }
        delete self.data[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size--;
    }

    function contains(itmap storage self, uint256 key) internal view returns (bool) {
        return self.data[key].keyIndex > 0;
    }

    function iterateStart(itmap storage self) internal view returns (Iterator) {
        return iteratorSkipDeleted(self, 0);
    }

    function iterateValid(itmap storage self, Iterator iterator) internal view returns (bool) {
        return Iterator.unwrap(iterator) < self.keys.length;
    }

    function iterateNext(itmap storage self, Iterator iterator) internal view returns (Iterator) {
        return iteratorSkipDeleted(self, Iterator.unwrap(iterator) + 1);
    }

    function iterateGet(itmap storage self, Iterator iterator) internal view returns (uint256 key, uint256 value) {
        uint256 keyIndex = Iterator.unwrap(iterator);
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }

    function iteratorSkipDeleted(itmap storage self, uint256 keyIndex) private view returns (Iterator) {
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted) {
            keyIndex++;
        }
        return Iterator.wrap(keyIndex);
    }
}

// How to use it
contract User {
    // Just a struct holding our data.
    itmap data;
    // Apply library functions to the data type.

    using IterableMapping for itmap;

    // Insert something
    function insert(uint256 k, uint256 v) public returns (uint256 size) {
        // This calls IterableMapping.insert(data, k, v)
        data.insert(k, v);
        // We can still access members of the struct,
        // but we should take care not to mess with them.
        return data.size;
    }

    // Computes the sum of all stored data.
    function sum() public view returns (uint256 s) {
        for (Iterator i = data.iterateStart(); data.iterateValid(i); i = data.iterateNext(i)) {
            (, uint256 value) = data.iterateGet(i);
            s += value;
        }
    }
}
