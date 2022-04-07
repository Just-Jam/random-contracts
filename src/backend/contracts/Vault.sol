// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

pragma solidity ^0.8.0;

contract Vault is ERC20, ReentrancyGuard {

    using SafeMath for uint256;
    IERC20 public Token; 

    //input name, symbol of xToken, contract of token
    constructor(
        string memory _name,
        string memory _symbol,
        IERC20 _Token
    ) ERC20(_name, _symbol) {
        Token = _Token;
    }

    function deposit(uint _amount) public nonReentrant{
        require(_amount > 0);
        //Gets amount of tokens in vault
        uint totalTokens = Token.balanceOf(address(this));
        //Gets amount of xTokens in vault (vault shares)
        uint totalxTokens = totalSupply();
        //If no xTokens exist, mint it 1:1 to the amount deposited
        if(totalxTokens == 0){
            _mint(msg.sender, _amount);
        }
        //Calculate xToken:Token value, and mint xTokens to user. Ratio will change over time
        else{
            uint xTokenValue = totalTokens.div(totalxTokens);
            uint xTokensRecieved = _amount.div(xTokenValue);
            _mint(msg.sender, xTokensRecieved);
        }
        //Deposit Tokens in vault
        Token.transferFrom(msg.sender, address(this), _amount); 

    }

    function withdraw(uint _xAmount) public nonReentrant{
        require(_xAmount > 0);
        //Gets amount of tokens in vault
        uint totalTokens = Token.balanceOf(address(this));
        //Gets amount of xTokens in vault (vault shares)
        uint totalxTokens = totalSupply();

        //Calculate xToken:Token value, and allows user to exchange xTokens for tokens. Ratio will change over time
        uint xTokenValue = totalTokens.div(totalxTokens);
        uint tokensRecieved = _xAmount.mul(xTokenValue);
        //Burn xTokens
        _burn(msg.sender, _xAmount);
        //Transfer Tokens from vault to user
        Token.transfer(msg.sender, tokensRecieved);
        
    }

}