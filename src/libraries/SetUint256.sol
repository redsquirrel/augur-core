pragma solidity ^0.4.13;

import "ROOT/libraries/DelegationTarget.sol";
import "ROOT/legacy_reputation/Ownable.sol";

contract IterableMapUint256 is DelegationTarget, Ownable {

	mapping(uint256 => bool) private collection;
	uint private count;
	address private owner;
	bool private initialized;

    function initialize(address _owner) public returns (bool) onlyOwner {
        require(!initialized);
        initialized = true;
        owner = _owner;
        return (true);
    }

    function addSetItem(uint256 _item) public returns (bool) onlyOwner {
    	require(!contains(_item));
    	collection[_item] = true;
    	count += 1;
    	return (true);
    }

    function remove(uint256 _item) public returns (bool) onlyOwner {
    	require(contains(_item));
    	delete collection[_item];
    	count -= 1;
    	return (true)
    }

    function contains(uint256 _item) public returns (bool) constant {
    	return (collection[_item]);
    }

    function count() public returns (uint256) constant {
    	return (count);
    }
}	