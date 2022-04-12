// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

pragma solidity ^0.8.0;

/**A crowdfunding contract, similar to kickstarter.
1. Allows users to create a project for funding, project details stored off-chain
2. Creators set a target amount and deadline. Target amount must be reached before deadline
    for money to go to creator.
3. Contract collects a 5% fee if goal has been achieved. */
contract Crowdfund {

    uint public deadline;
    uint public targetAmount;
    uint public feePercent = 5;
    address public creator;
    address public owner;
    IERC20 public token; 
    mapping(address => uint) public pledgedAmount;

    modifier onlyCreator {
        require(msg.sender == creator);
        _;
    }

    constructor(
        uint _duration, 
        uint _targetAmount, 
        address _creator, 
        address _owner,
        IERC20 _token
    ) {
        require(_duration > 0);
        require(_targetAmount > 0);
        deadline = block.timestamp + _duration;
        targetAmount = _targetAmount;
        creator = _creator;
        owner = _owner;
        token = _token;
    }

    function deadlinePassed() public view returns (bool) {
        return block.timestamp > deadline;
    }

    function targetReached() public view returns (bool) {
        return(token.balanceOf(address(this)) >= targetAmount && targetAmount > 0);
    }

    function pledge(uint _amount) external {
        require(!deadlinePassed(), "Crowdfunding has ended");
        token.transferFrom(msg.sender, address(this), _amount);
        pledgedAmount[msg.sender] += _amount; 
    }

    function unpledge(uint _amount) external {
        require(!deadlinePassed(), "Crowdfunding has ended");
        require(_amount <= pledgedAmount[msg.sender]);
        token.transfer(msg.sender, _amount);
        pledgedAmount[msg.sender] -= _amount; 
    }

    function collectPledges() external onlyCreator {
        require(deadlinePassed());
        require(targetReached(), "Target amount not reached");
        token.transfer(owner, token.balanceOf(address(this)) * feePercent / 100);
        token.transfer(creator, token.balanceOf(address(this)));
    }

    function end() external onlyCreator {
        deadline = block.timestamp;
        targetAmount = 0;
    }

    function collectRefund() external {
        require(deadlinePassed());
        require(!targetReached());
        token.transfer(msg.sender, pledgedAmount[msg.sender]);
    }

}