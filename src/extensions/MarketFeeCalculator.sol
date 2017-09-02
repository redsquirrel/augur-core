pragma solidity ^0.4.13;

import 'ROOT/reporting/IReputationToken.sol';
import 'ROOT/reporting/IBranch.sol';
import 'ROOT/reporting/IReportingWindow.sol';


contract MarketFeeCalculator {
    mapping (address => uint256) private shareSettlementPerEthFee;
    mapping (address => uint256) private validityBondInAttoeth;

    function getValidityBond(IReportingWindow _reportingWindow) public returns (uint256) {
        uint256 _currentValidityBondInAttoeth = validityBondInAttoeth[_reportingWindow];
        if (_currentValidityBondInAttoeth != 0) {
            return _currentValidityBondInAttoeth;
        }
        // TODO: get the real data for this
        uint256 _indeterminateMarketsInPreviousWindow = 10;
        // TODO: get the real data for this
        uint256 _totalMarketsInPreviousWindow = 1000;
        uint256 _previousTimestamp = _reportingWindow.getStartTime() - 1;
        IBranch _branch = _reportingWindow.getBranch();
        IReportingWindow _previousReportingWindow = _branch.getReportingWindowByTimestamp(_previousTimestamp);
        uint256 _previousValidityBondInAttoeth = validityBondInAttoeth[_previousReportingWindow];
        if (_previousValidityBondInAttoeth == 0) {
            _previousValidityBondInAttoeth = 1 * 10 ** 16;
        }
        uint256 _targetIndeterminateMarketsPerHundred = 1;
        _currentValidityBondInAttoeth = _previousValidityBondInAttoeth * _targetIndeterminateMarketsPerHundred * _totalMarketsInPreviousWindow / _indeterminateMarketsInPreviousWindow / 100;
        validityBondInAttoeth[_reportingWindow] = _currentValidityBondInAttoeth;
        return _currentValidityBondInAttoeth;
    }

    function getTargetReporterGasCosts() constant public returns (uint256) {
        // TODO: get number of registration tokens issued last period
        // TODO: get target reporter count + wiggle room
        // TODO: calculate estimated reporters per market
        uint256 _estimatedReportsPerMarket = 10;
        // TODO: figure out what the number actually is
        uint256 _gasToReport = 100000;
        // we double it to ensure we have more than enough rather than not enough
        uint256 _estimatedReportingGas = _gasToReport * _estimatedReportsPerMarket * 2;
        // TODO: multiply this by average gas costs of reporters historically
        return _estimatedReportingGas;
    }

    function getReportingFeeInAttoethPerEth(IReportingWindow _reportingWindow) public returns (uint256) {
        // CONSIDER: store this on the reporting window rather than here
        uint256 _currentPerEthFee = shareSettlementPerEthFee[_reportingWindow];
        if (_currentPerEthFee != 0) {
            return _currentPerEthFee;
        }
        IBranch _branch = _reportingWindow.getBranch();
        uint256 _repMarketCapInAttoeth = getRepMarketCapInAttoeth(_branch);
        uint256 _targetRepMarketCapInAttoeth = getTargetRepMarketCapInAttoeth(_reportingWindow);
        uint256 _previousTimestamp = _reportingWindow.getStartTime() - 1;
        IReportingWindow _previousReportingWindow = _branch.getReportingWindowByTimestamp(_previousTimestamp);
        uint256 _previousPerEthFee = shareSettlementPerEthFee[_previousReportingWindow];
        if (_previousPerEthFee == 0) {
            _previousPerEthFee = 1 * 10 ** 16;
        }
        _currentPerEthFee = _previousPerEthFee * _targetRepMarketCapInAttoeth / _repMarketCapInAttoeth;
        if (_currentPerEthFee < 1 * 10 ** 14) {
            _currentPerEthFee = 1 * 10 ** 14;
        }
        shareSettlementPerEthFee[_reportingWindow] = _currentPerEthFee;
        return _currentPerEthFee;
    }

    function getRepMarketCapInAttoeth(IBranch _branch) constant public returns (uint256) {
        // TODO: get these from an auto-generated market
        uint256 _attorepPerEth = 11 * 10 ** 18;
        uint256 _repMarketCapInAttoeth = _branch.getReputationToken().totalSupply() * _attorepPerEth;
        return _repMarketCapInAttoeth;
    }

    function getTargetRepMarketCapInAttoeth(IReportingWindow _reportingWindow) constant public returns (uint256) {
        uint256 _outstandingSharesInAttoeth = getOutstandingSharesInAttoeth(_reportingWindow);
        uint256 _targetRepMarketCapInAttoeth = _outstandingSharesInAttoeth * 5;
        return _targetRepMarketCapInAttoeth;
    }

    function getOutstandingSharesInAttoeth(IReportingWindow) constant public returns (uint256) {
        // TODO: start tracking the real number and store it somewhere
        // NOTE: make sure we are getting the share value in attoeth, since complete set fees are not normalized across markets
        // NOTE: eventually we will need to support shares in multiple denominations
        uint256 _outstandingSharesInAttoeth = 100 * 10 ** 18;
        return _outstandingSharesInAttoeth;
    }

    function getMarketCreationCost(IReportingWindow _reportingWindow) constant public returns (uint256) {
        return getValidityBond(_reportingWindow) + getTargetReporterGasCosts();
    }
}
