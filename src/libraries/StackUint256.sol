pragma solidity ^0.4.13;

import "ROOT/libraries/DelegationTarget.sol";
import "ROOT/legacy_reputation/Ownable.sol";

contract StackUint256 is DelegationTarget, Ownable {
    
    uint256[] private collection;
    uint256 private head;
    address private owner;
    bool private initialized;

    function initialize(address _owner) public returns (bool) onlyOwner {
        require(!initialized);
        initialized = true;
        owner = _owner;
        return (true);
    }

    function push(uint256 _item) public returns (bool) onlyOwner {
        head += 1;
        collection.push(_item);
        return (true);
    }    

    function pop() public returns (uint256) onlyOwner {
        uint256 _index = head;
        require(_index != 0);
        head = _index - 1;
        uint256 _removedValue = collection[_index];
        delete collection[_index];
        return (_removedValue);
    }

    function peek() public returns (uint256) constant {
        require(head != 0);
        return (collection[head]);
    }

    function isEmpty() public returns (bool) constant {
         return (head == 0);
    }
}
