// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//1 eth option = 1 eth
contract ExampleOption is ERC20, ReentrancyGuard{

    uint256 public ethPrice;
    uint256 public strikePrice;
    uint256 public expiryTime;
    mapping(address => uint256) public lockedEthBalance;
    mapping(address => uint256) public ethBalance;

    IERC20 public stablecoin;

    constructor(
        string memory _name,
        string memory _symbol,
        IERC20 _stablecoin
    ) ERC20(_name, _symbol) {
        stablecoin = _stablecoin;
    }

    function expired() public view returns (bool) {
        return block.timestamp > expiryTime;
    }

    function writeCall() external payable nonReentrant {
        require(msg.value > 0);
        ethBalance[msg.sender] -= msg.value;
        lockedEthBalance[msg.sender] += msg.value;
        _mint(msg.sender, msg.value);
    }

    function unlockEth(uint256 _amount) external nonReentrant {
        require(balanceOf(msg.sender) >= _amount);
        lockedEthBalance[msg.sender] -= _amount;
        ethBalance[msg.sender] += _amount;
        _burn(msg.sender, _amount);
    }

    function exerciseCall(uint256 _amount) external nonReentrant {
        require(!expired());
        require(ethPrice >= strikePrice);
        stablecoin.transferFrom(msg.sender, address(this), _amount * strikePrice);
        payable(msg.sender).transfer(_amount);
    }

    function depositEth() external payable nonReentrant {
        require(msg.value > 0);
        ethBalance[msg.sender] += msg.value;
    }

    function withdrawEth(uint256 _amount) external nonReentrant {
        require(ethBalance[msg.sender] >= _amount);
        ethBalance[msg.sender] -= _amount;
    }
}