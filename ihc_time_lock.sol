pragma solidity ^0.5.16;
import {IHC} from 'ihc_token.sol';

contract IHC_TIME_LOCK {
    uint public end;
    address payable public owner;
    address public ihcTokenAddress;

    constructor(address payable _owner, uint _daysAfter) public payable {
        require(_owner != address(0),"_owner: zero address!");
        end = block.timestamp + (_daysAfter * 1 days);
        owner = _owner;
        ihcTokenAddress = 0x86a53fcd199212FEa44FA7e16EB1f28812be911D;
    }

    function deposit(uint amount) external returns(bool) {
        return IHC(ihcTokenAddress).transferFrom(msg.sender, address(this), amount);
    }
    
    function withdraw(uint amount) external returns(bool) {
        require(msg.sender == owner, 'only owner');
        require(block.timestamp >= end, 'too early');
        return IHC(ihcTokenAddress).transfer(owner, amount);
    }
    
    function getEndOfTime() external view returns (uint256) {
        return end;
    }
    
    function getOwner() external view returns (address payable) {
        return owner;
    }
    
    
}