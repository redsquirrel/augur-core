pragma solidity ^0.4.13;

import "ROOT/libraries/DelegationTarget.sol";
import "ROOT/legacy_reputation/Ownable.sol";

contract IterableMapUint256 is DelegationTarget, Ownable {

    struct Item {
        bool hasItem;
        uint256 value;
        uint256 offset;
    }

    address public owner;
    bool public initialized;
    uint256[] public itemsArray;
    mapping(uint256 => Item) public itemsMap;


    function initialize(address _owner) returns (bool) onlyOwner {
        require(!initialized);
        initialized = true;
        owner = _owner;
        return (true);
    }

    function add(uint256 _key, uint256 _value) returns (bool) onlyOwner {
        require(!contains(_key));
        itemsArray.push(_key);
        itemsMap[_key].hasValue = true;
        itemsMap[_key].value = _value;
        itemsMap[_key].offset = itemsArray.length - 1;
        return (true);
    }

    function update(uint256 _key, uint256 _value) returns (bool) onlyOwner {
        require(contains(_key));
        itemsMap[_key].value = _value;
        return (true);
    }

    function addOrUpdate(uint256 _key, uint256 _value) returns (bool) onlyOwner {
        if (!contains(_key)) {
            add(_key, _value);
        } else {
            update(_key, _value);
        }

        return (true);
    }

    function remove(uint256 _key) returns (bool) onlyOwner {
        
        require(contains(_key));
        uint256 _keyRemovedOffset = itemsMap[_key].offset;
        delete itemsArray[_keyRemovedOffset];
        itemsMap[_key].hasValue = false;
        delete itemsMap[_key].value;
        delete itemsMap[_key].offset;

        if (itemsArray.length > 1 && _keyRemovedOffset != (itemsArray.length - 1)) { /* move tail item in collection to the newly opened slot from the key we just removed if not last or only item being removed */
            uint256 _tailItemKey = getByOffset(itemsArray.length - 1);
            delete itemsArray[itemsArray.length - 1];
            itemsArray[_keyRemovedOffset] = _tailItemKey;
            itemsMap[_tailItemKey].offset = itemsArray.length - 2;
        }

        itemsArray.length -= 1;
        return (true);
    
    }

    function getByKeyOrZero(uint256 _key) returns (uint256) constant {
        return itemsMap[_key].value;
    }

    function getByKey(uint256 _key) returns (uint256) constant {
        require(itemsMap[_key].hasValue);
        return (itemsMap[_key].value);
    }

    function getByOffset(uint256 _offset) returns (uint256) constant {
        require(0 <= _offset && _offset < itemsArray.length);
        return itemsArray[_offset];
    }

    function contains(uint256 _key) returns (bool) constant {
        return itemsMap[_key].hasValue;
    }

    function count() returns (uint256) constant {
        return itemsArray.length;
    }
}
