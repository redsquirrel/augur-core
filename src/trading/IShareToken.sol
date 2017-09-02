pragma solidity ^0.4.13;

import 'ROOT/libraries/Typed.sol';
import 'ROOT/libraries/token/ERC20.sol';
import 'ROOT/reporting/IMarket.sol';


contract IShareToken is Typed, ERC20 {
    function initialize(IMarket _market, uint8 _outcome) public returns (bool);
    function getMarket() constant returns (IMarket);
    function balanceOf(address) constant returns (uint256);
    function transfer(address, uint256) returns (bool);
    function transferFrom(address, address, uint256) returns (bool);
    function destroyShares(address, uint256 balance) public;
    function getOutcome() public constant returns (uint8);
    function createShares(address _owner, uint256 _amount) public returns (bool);
}
