pragma solidity ^0.5.16;
import {IHC} from 'ihc_token.sol';

contract IHC_TIME_LOCK {
    uint public end;
    address payable public owner;
    address public ihcTokenAddress;

    constructor(address payable _owner, uint _daysAfter) public payable {
        end = block.timestamp + (_daysAfter * 1 days);
        owner = _owner;
        ihcTokenAddress = 0xf7AfD1438CB234A58f8740Be20EB2094019D71d8;
    }

    function deposit(address token, uint amount) external {
        IHC(ihcTokenAddress).transferFrom(msg.sender, address(this), amount);
    }
    
    function withdraw(address token, uint amount) external {
        require(msg.sender == owner, 'only owner');
        require(block.timestamp >= end, 'too early');
        if(token == address(0)) { 
            owner.transfer(amount);
        } else {
            IHC(ihcTokenAddress).transfer(owner, amount);
        }
    }
}