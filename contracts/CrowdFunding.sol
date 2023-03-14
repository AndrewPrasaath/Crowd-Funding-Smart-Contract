// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

// Custom errors
error FundingStarted();
error NotInTimeInterval();
error FundingEnded();
error FundingNotEnded();
error TargetReached();
error TargetNotReached();
error AmountClaimed();

/// @title CrowdFunding
/// @author Andrew Prasaath
contract CrowdFunding {
    // Type Declaration
    struct Campaign {
        address owner;
        uint256 target;
        uint256 pledged;
        uint256 startTime;
        uint256 endTime;
        bool claimed;
    }

    // State Variables
    ERC20 public crowdFundToken;
    uint256 private _campaignCount;
    uint256 private _timeInterval;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => uint256) private _numberOfDonors;
    mapping(uint256 => mapping(address => uint256)) private _pledgedAmount;

    // Events
    event Deploy(
        uint256 _id,
        address indexed owner,
        uint256 _target,
        uint256 _startTime,
        uint256 _endTime
    );
    event Revoke(uint256 _id);
    event Pledge(uint256 _id, address indexed _caller, uint256 _amount);
    event Unpledge(uint256 _id, address indexed _caller, uint256 _amount);
    event Withdraw(uint _id);
    event Refund(uint _id, address indexed _caller, uint _amount);

    constructor(address _tokenAddress, uint time_interval) {
        crowdFundToken = ERC20(_tokenAddress);
        _timeInterval = time_interval;
    }

    modifier onlyOwner(Campaign storage campaign) {
        require(campaign.owner == msg.sender);
        _;
    }

    // Functions
    function deploy(uint256 _target, uint256 _startTime) external {
        _campaignCount++;
        campaigns[_campaignCount] = Campaign({
            owner: msg.sender,
            target: _target,
            pledged: 0,
            startTime: block.timestamp + _startTime,
            endTime: block.timestamp + _startTime + _timeInterval,
            claimed: false
        });

        emit Deploy(
            _campaignCount,
            msg.sender,
            _target,
            _startTime,
            _startTime + _timeInterval
        );
    }

    function revoke(uint256 _id) external onlyOwner(campaigns[_id]) {
        Campaign storage campaign = campaigns[_id];
        if (block.timestamp > campaign.startTime) {
            revert FundingStarted();
        }

        delete campaigns[_id];
        emit Revoke(_id);
    }

    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        if (
            block.timestamp < campaign.startTime &&
            block.timestamp > campaign.endTime
        ) {
            revert NotInTimeInterval();
        }

        campaign.pledged += _amount;
        if (_pledgedAmount[_id][msg.sender] == 0) {
            _numberOfDonors[_id]++;
        }
        _pledgedAmount[_id][msg.sender] += _amount;
        crowdFundToken.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function unpledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        if (block.timestamp > campaign.endTime) {
            revert FundingEnded();
        }

        campaign.pledged -= _amount;
        _pledgedAmount[_id][msg.sender] -= _amount;
        crowdFundToken.transfer(msg.sender, _amount);

        emit Unpledge(_id, msg.sender, _amount);
    }

    function withdraw(uint256 _id) external onlyOwner(campaigns[_id]) {
        Campaign storage campaign = campaigns[_id];
        if (block.timestamp <= campaign.endTime) {
            revert FundingNotEnded();
        }
        if (campaign.pledged < campaign.target) {
            revert TargetNotReached();
        }
        if (campaign.claimed) {
            revert AmountClaimed();
        }

        campaign.claimed = true;
        crowdFundToken.transfer(campaign.owner, campaign.pledged);

        emit Withdraw(_id);
    }

    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        if (block.timestamp <= campaign.endTime) {
            revert FundingNotEnded();
        }
        if (campaign.pledged >= campaign.target) {
            revert TargetReached();
        }

        uint balance = _pledgedAmount[_id][msg.sender];
        _pledgedAmount[_id][msg.sender] = 0;
        crowdFundToken.transfer(msg.sender, balance);

        emit Refund(_id, msg.sender, balance);
    }

    // Utility functions
    function getFunding(uint256 _id) public view returns (uint256) {
        return campaigns[_id].pledged;
    }

    function getCampaignOwner(uint256 _id) public view returns (address) {
        return campaigns[_id].owner;
    }

    function numberOfDonors(uint256 _id) public view returns (uint256) {
        return _numberOfDonors[_id];
    }

    function getPledgedAmount(
        uint256 _id,
        address _funder
    ) public view returns (uint256) {
        return _pledgedAmount[_id][_funder];
    }

    function getTimeInterval(uint256) public view returns (uint256) {
        return _timeInterval;
    }

    function getCampaignCount() public view returns (uint256) {
        return _campaignCount;
    }
}
