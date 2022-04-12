// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Crowdfund.sol";

contract CrowdfundFactory {
    Crowdfund public crowdfund;
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function createCrowdfund(uint _duration, uint _targetAmount, address _creator) public {
        require(_duration > 0);
        require(_targetAmount > 0);
        require(_creator != address(0));
        crowdfund = new Crowdfund(_duration, _targetAmount, _creator, msg.sender, token);
    }
}