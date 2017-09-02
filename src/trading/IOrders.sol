pragma solidity ^0.4.13;

import 'ROOT/reporting/IMarket.sol';
import 'ROOT/trading/Trading.sol';


contract IOrders {
    function getOrders(bytes32 _orderId) public constant returns (uint256 _amount, int256 _price, address _owner, uint256 _sharesEscrowed, uint256 _tokensEscrowed, bytes32 _betterOrderId, bytes32 _worseOrderId);
    function getAmount(bytes32 _orderId, Trading.TradeTypes, IMarket, uint8) public constant returns (uint256);
    function getPrice(bytes32 _orderId, Trading.TradeTypes, IMarket, uint8) public constant returns (int256);
    function getOrderOwner(bytes32 _orderId, Trading.TradeTypes, IMarket, uint8) public constant returns (address);
    function getOrderSharesEscrowed(bytes32 _orderId, Trading.TradeTypes, IMarket, uint8) public constant returns (uint256);
    function getOrderMoneyEscrowed(bytes32 _orderId, Trading.TradeTypes, IMarket, uint8) public constant returns (uint256);
    function getBetterOrderId(bytes32 _orderId, Trading.TradeTypes, IMarket, uint8) public constant returns (bytes32);
    function getWorseOrderId(bytes32 _orderId, Trading.TradeTypes, IMarket, uint8) public constant returns (bytes32);
    function getBestOrderId(Trading.TradeTypes _type, IMarket _market, uint8 _outcome) public constant returns (bytes32);
    function getWorstOrderId(Trading.TradeTypes _type, IMarket _market, uint8 _outcome) public constant returns (bytes32);
    function isBetterPrice(Trading.TradeTypes _type, IMarket, uint8, int256 _fxpPrice, bytes32 _orderId) public constant returns (bool);
    function isWorsePrice(Trading.TradeTypes _type, IMarket, uint8, int256 _fxpPrice, bytes32 _orderId) public constant returns (bool);
    function assertIsNotBetterPrice(Trading.TradeTypes _type, IMarket _market, uint8 _outcome, int256 _fxpPrice, bytes32 _betterOrderId) public constant returns (bool);
    function assertIsNotWorsePrice(Trading.TradeTypes _type, IMarket _market, uint8 _outcome, int256 _fxpPrice, bytes32 _worseOrderId) public returns (bool);
    function completeSetsLog(address _sender, IMarket _market, Trading.TradeTypes _type, uint256 _fxpAmount, uint256 _numOutcomes, uint256 _marketCreatorFee, uint256 _reportingFee) public constant returns (bool);
}
