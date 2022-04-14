// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

pragma solidity ^0.8.0;

contract CrowdFundV2 {

    struct Campaign {
        address creator;
        uint targetAmount;
        uint pledgedAmount;
        uint32 startAt;
        uint32 endAt;
    }
    
    IERC20 public immutable token;
    uint public feePercent = 5;
    uint public campaignCount;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public userPledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launchCampaign(uint _targetAmount, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        campaignCount += 1;
        campaigns[campaignCount] = Campaign(
            msg.sender,
            _targetAmount,
            0,
            _startAt,
            _endAt
        );
    }

    function end(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(block.timestamp < campaign.startAt, "started");

        delete campaigns[_id];
    }

    function claimPledges(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "only creator can end campaign");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledgedAmount >= campaign.targetAmount, "pledged < target");
        token.transfer(msg.sender, campaign.pledgedAmount);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended");
        campaign.pledgedAmount += _amount;
        userPledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended");
        campaign.pledgedAmount -= _amount;
        userPledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
    }

    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledgedAmount < campaign.targetAmount, "pledged >= target");

        uint bal = userPledgedAmount[_id][msg.sender];
        userPledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
    }
}