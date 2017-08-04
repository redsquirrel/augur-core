pragma solidity ^0.4.13;

import "ROOT/libraries/DelegationTarget.sol";
import "ROOT/legacy_reputation/Ownable.sol";

contract IterableMapUint256 is DelegationTarget, Ownable {

    struct Item {
        bool hasItem;
        uint256 value;
        uint256 offset;
    }

    address private owner;
    bool private initialized;
    uint256[] private itemsArray;
    mapping(uint256 => Item) private itemsMap;


    function initialize(address _owner) public onlyOwner returns (bool) {
        require(!initialized);
        initialized = true;
        owner = _owner;
        return (true);
    }

    function add(uint256 _key, uint256 _value) public onlyOwner returns (bool) {
        require(!contains(_key));
        itemsArray.push(_key);
        itemsMap[_key].hasValue = true;
        itemsMap[_key].value = _value;
        itemsMap[_key].offset = itemsArray.length - 1;
        return (true);
    }

    function update(uint256 _key, uint256 _value) public onlyOwner returns (bool) {
        require(contains(_key));
        itemsMap[_key].value = _value;
        return (true);
    }

    function addOrUpdate(uint256 _key, uint256 _value) public onlyOwner returns (bool) {
        if (!contains(_key)) {
            add(_key, _value);
        } else {
            update(_key, _value);
        }

        return (true);
    }

    function remove(uint256 _key) public onlyOwner returns (bool) {
        
        require(contains(_key));
        uint256 _keyRemovedOffset = itemsMap[_key].offset;
        delete itemsArray[_keyRemovedOffset];
        delete itemsMap[_key].hasValue;
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

    function getByKeyOrZero(uint256 _key) public constant returns (uint256) {
        return itemsMap[_key].value;
    }

    function getByKey(uint256 _key) public constant returns (uint256) {
        require(itemsMap[_key].hasValue);
        return (itemsMap[_key].value);
    }

    function getByOffset(uint256 _offset) public constant returns (uint256) {
        require(0 <= _offset && _offset < itemsArray.length);
        return itemsArray[_offset];
    }

    function contains(uint256 _key) public constant returns (bool) {
        return itemsMap[_key].hasValue;
    }

    function count() public constant returns (uint256) {
        return itemsArray.length;
    }
}
