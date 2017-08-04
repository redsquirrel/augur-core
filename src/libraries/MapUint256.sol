pragma solidity ^0.4.13;

import "ROOT/libraries/DelegationTarget.sol";
import "ROOT/legacy_reputation/Ownable.sol";

contract MapUint256 is DelegationTarget, Ownable {

    struct MapItem {
        bool hasValue;
        uint256 value;
    }

    mapping(uint256 => MapItem) private collection;
    address private owner;
    bool private initialized;
    uint256 private count;
    

    function initialize(address _owner) public returns (bool) onlyOwner {
        require(!initialized);
        initialized = true;
        owner = _owner;
        return (true);
    }

    function addMapItem(uint256_key, uint256_value) public returns (bool) onlyOwner {
        require(!contains(_key));
        collection[_key].hasValue = true;
        collection[_key].value = _value;
        count += 1;
        return (true);
    }

    function remove(uint256 _key) public returns (bool) onlyOwner {
        require(contains(_key));
        delete collection[_key].hasValue;
        delete collection[_key].value;
        count -= 1;
        return (true);
    }

    function contains(uint256 _key) public returns (bool) constant {
        return(collection[_key].hasValue); 
    } 

    function getValueOrZero(uint256 _key) public returns (uint256) constant {
        return(collection[_key].value);
    }

    function getValue(uint256 _key) public returns (uint256) constant {
        require(contains(_key));
        return(collection[_key].value);
    }

    function count() public returns (uint256) constant {
        return (count);
    }
}