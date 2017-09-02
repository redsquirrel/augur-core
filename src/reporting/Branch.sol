pragma solidity ^0.4.13;

import 'ROOT/reporting/IBranch.sol';
import 'ROOT/libraries/DelegationTarget.sol';
import 'ROOT/libraries/Typed.sol';
import 'ROOT/libraries/Initializable.sol';
import 'ROOT/factories/ReputationTokenFactory.sol';
import 'ROOT/factories/TopicsFactory.sol';
import 'ROOT/factories/ReportingWindowFactory.sol';
import 'ROOT/factories/BranchFactory.sol';
import 'ROOT/reporting/IMarket.sol';
import 'ROOT/reporting/IReputationToken.sol';
import 'ROOT/reporting/IReportingToken.sol';
import 'ROOT/reporting/IDisputeBond.sol';
import 'ROOT/reporting/IRegistrationToken.sol';
import 'ROOT/reporting/IReportingWindow.sol';


contract Branch is DelegationTarget, Typed, Initializable, IBranch {
    IBranch private parentBranch;
    bytes32 private parentPayoutDistributionHash;
    IReputationToken private reputationToken;
    ITopics private topics;
    IMarket private forkingMarket;
    uint256 private forkEndTime;
    mapping(uint256 => IReportingWindow) private reportingWindows;
    mapping(bytes32 => IBranch) private childBranches;

    function initialize(IBranch _parentBranch, bytes32 _parentPayoutDistributionHash) external beforeInitialized returns (bool) {
        endInitialization();
        parentBranch = _parentBranch;
        parentPayoutDistributionHash = _parentPayoutDistributionHash;
        reputationToken = ReputationTokenFactory(controller.lookup("ReputationTokenFactory")).createReputationToken(controller, this);
        require(reputationToken != address(0));
        topics = TopicsFactory(controller.lookup("TopicsFactory")).createTopics(controller);
        return true;
    }

    function fork() public afterInitialized returns (bool) {
        require(forkingMarket == address(0));
        require(isContainerForMarket(Typed(msg.sender)));
        forkingMarket = IMarket(msg.sender);
        forkEndTime = block.timestamp + 60 days;
        return true;
    }

    function getTypeName() constant returns (bytes32) {
        return "Branch";
    }

    function getParentBranch() constant returns (IBranch) {
        return parentBranch;
    }

    function getParentPayoutDistributionHash() constant returns (bytes32) {
        return parentPayoutDistributionHash;
    }

    function getReputationToken() constant returns (IReputationToken) {
        return reputationToken;
    }

    function getTopics() constant returns (ITopics) {
        return topics;
    }

    function getForkingMarket() constant returns (IMarket) {
        return forkingMarket;
    }

    function getForkEndTime() constant returns (uint256) {
        return forkEndTime;
    }

    function getReportingWindow(uint256 _reportingWindowId) constant returns (IReportingWindow) {
        return reportingWindows[_reportingWindowId];
    }

    // TODO: this has a signature conflict with the public version below.  for consistency, we should have this be the signature for the `constant` version and rename the `public` one
    //function getChildBranch(bytes32 _parentPayoutDistributionHash) constant returns (Branch);

    function getReportingWindowId(uint256 _timestamp) constant returns (uint256) {
        return _timestamp / getReportingPeriodDurationInSeconds();
    }

    function getReportingPeriodDurationInSeconds() constant returns (uint256) {
        // TODO: turn these into shared constants
        return 27 days + 3 days;
    }

    function getReportingWindowByTimestamp(uint256 _timestamp) public returns (IReportingWindow) {
        uint256 _windowId = getReportingWindowId(_timestamp);
        if (reportingWindows[_windowId] == address(0)) {
            reportingWindows[_windowId] = ReportingWindowFactory(controller.lookup("ReportingWindowFactory")).createReportingWindow(controller, this, _windowId);
        }
        return reportingWindows[_windowId];
    }

    function getReportingWindowByMarketEndTime(uint256 _endTime, bool _hasAutomatedReporter) public returns (IReportingWindow) {
        if (_hasAutomatedReporter) {
            // TODO: turn these into shared constants
            return getReportingWindowByTimestamp(_endTime + 3 days + 3 days + 1 + getReportingPeriodDurationInSeconds());
        } else {
            return getReportingWindowByTimestamp(_endTime + 1 + getReportingPeriodDurationInSeconds());
        }
    }

    function getPreviousReportingWindow() public returns (IReportingWindow) {
        return getReportingWindowByTimestamp(block.timestamp - getReportingPeriodDurationInSeconds());
    }

    function getCurrentReportingWindow() public returns (IReportingWindow) {
        return getReportingWindowByTimestamp(block.timestamp);
    }

    function getNextReportingWindow() public returns (IReportingWindow) {
        return getReportingWindowByTimestamp(block.timestamp + getReportingPeriodDurationInSeconds());
    }

    function getChildBranch(bytes32 _parentPayoutDistributionHash) public returns (IBranch) {
        if (childBranches[_parentPayoutDistributionHash] == address(0)) {
            childBranches[_parentPayoutDistributionHash] = BranchFactory(controller.lookup("BranchFactory")).createBranch(controller, this, _parentPayoutDistributionHash);
        }
        return childBranches[_parentPayoutDistributionHash];
    }

    function isContainerForReportingWindow(Typed _shadyTarget) constant returns (bool) {
        if (_shadyTarget.getTypeName() != "ReportingWindow") {
            return false;
        }
        IReportingWindow _shadyReportingWindow = IReportingWindow(_shadyTarget);
        uint256 _startTime = _shadyReportingWindow.getStartTime();
        if (_startTime == 0) {
            return false;
        }
        uint256 _reportingWindowId = getReportingWindowId(_startTime);
        IReportingWindow _legitReportingWindow = reportingWindows[_reportingWindowId];
        return _shadyReportingWindow == _legitReportingWindow;
    }

    function isContainerForDisputeBondToken(Typed _shadyTarget) constant returns (bool) {
        if (_shadyTarget.getTypeName() != "DisputeBondToken") {
            return false;
        }
        IDisputeBond _shadyDisputeBond = IDisputeBond(_shadyTarget);
        IMarket _shadyMarket = _shadyDisputeBond.getMarket();
        if (_shadyMarket == address(0)) {
            return false;
        }
        if (!isContainerForMarket(_shadyMarket)) {
            return false;
        }
        IMarket _legitMarket = _shadyMarket;
        return _legitMarket.isContainerForDisputeBondToken(_shadyDisputeBond);
    }

    function isContainerForRegistrationToken(Typed _shadyTarget) constant returns (bool) {
        if (_shadyTarget.getTypeName() != "RegistrationToken") {
            return false;
        }
        IRegistrationToken _shadyRegistrationToken = IRegistrationToken(_shadyTarget);
        IReportingWindow _shadyReportingWindow = _shadyRegistrationToken.getReportingWindow();
        if (_shadyReportingWindow == address(0)) {
            return false;
        }
        if (!isContainerForReportingWindow(_shadyReportingWindow)) {
            return false;
        }
        IReportingWindow _legitReportingWindow = _shadyReportingWindow;
        return _legitReportingWindow.isContainerForRegistrationToken(_shadyRegistrationToken);
    }

    function isContainerForMarket(Typed _shadyTarget) constant returns (bool) {
        if (_shadyTarget.getTypeName() != "Market") {
            return false;
        }
        IMarket _shadyMarket = IMarket(_shadyTarget);
        IReportingWindow _shadyReportingWindow = _shadyMarket.getReportingWindow();
        if (_shadyReportingWindow == address(0)) {
            return false;
        }
        if (!isContainerForReportingWindow(_shadyReportingWindow)) {
            return false;
        }
        IReportingWindow _legitReportingWindow = _shadyReportingWindow;
        return _legitReportingWindow.isContainerForMarket(_shadyMarket);
    }

    function isContainerForReportingToken(Typed _shadyTarget) constant returns (bool) {
        if (_shadyTarget.getTypeName() != "ReportingToken") {
            return false;
        }
        IReportingToken _shadyReportingToken = IReportingToken(_shadyTarget);
        IMarket _shadyMarket = _shadyReportingToken.getMarket();
        if (_shadyMarket == address(0)) {
            return false;
        }
        if (!isContainerForMarket(_shadyMarket)) {
            return false;
        }
        IMarket _legitMarket = _shadyMarket;
        return _legitMarket.isContainerForReportingToken(_shadyReportingToken);
    }

    function isContainerForShareToken(Typed _shadyTarget) constant returns (bool) {
        if (_shadyTarget.getTypeName() != "ShareToken") {
            return false;
        }
        IShareToken _shadyShareToken = IShareToken(_shadyTarget);
        IMarket _shadyMarket = _shadyShareToken.getMarket();
        if (_shadyMarket == address(0)) {
            return false;
        }
        if (!isContainerForMarket(_shadyMarket)) {
            return false;
        }
        IMarket _legitMarket = _shadyMarket;
        return _legitMarket.isContainerForShareToken(_shadyShareToken);
    }

    function isParentOf(IBranch _shadyChild) constant returns (bool) {
        bytes32 _parentPayoutDistributionHash = _shadyChild.getParentPayoutDistributionHash();
        return childBranches[_parentPayoutDistributionHash] == _shadyChild;
    }

    function getReportingWindowForForkEndTime() public constant returns (IReportingWindow) {
        return getReportingWindowByTimestamp(getForkEndTime());
    }
}
