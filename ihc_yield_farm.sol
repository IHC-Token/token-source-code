pragma solidity ^0.5.16;
import {IHC} from 'ihc_token.sol';

library SafeMath {
    /**
    * @dev Returns the addition of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `+` operator.
    *
    * Requirements:
    * - Addition cannot overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
    
    return c;
    }
    
    /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    /**
    * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        
        return c;
    }
    
    /**
    * @dev Returns the multiplication of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `*` operator.
    *
    * Requirements:
    * - Multiplication cannot overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
    
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        
        return c;
    }
    
    /**
    * @dev Returns the integer division of two unsigned integers. Reverts on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    /**
    * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        
        return c;
    }
    
    /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    
    /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts with custom message when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract IHC_YIELD_FARM {
    using SafeMath for uint256;
    
    enum FarmState{Created, Funded}
    FarmState public state;
    address payable public yieldFarmer;
    address payable public yieldFarmPoolAddress;
    address public ihcTokenAddress;
    uint256 withdrawDeadlineByTimestamp;
    uint256 yieldFarmAmount;
    uint apy;
    uint256 private transactionFeePercent;
    uint yieldFarmDays;
    uint256 yieldFarmMinAmount;
    
    constructor () public payable{
        ihcTokenAddress = 0xf7AfD1438CB234A58f8740Be20EB2094019D71d8;
        state = FarmState.Created;
        apy = IHC(ihcTokenAddress).getApy();
        transactionFeePercent = IHC(ihcTokenAddress).getTransactionFeePercent();
        yieldFarmPoolAddress = IHC(ihcTokenAddress).getYieldFarmPoolAddress();
    }
    
    modifier onlyInState(FarmState expectedState) {
        require(state == expectedState, "Not allowed in this state");
        _;
    }
    
    function getIhcTokenAddress() external view returns(address) {
        
        return ihcTokenAddress;
    }
    
    function getThisContractAddress() external view returns(address) {
        
        return address(this);
    }
    
    function getBalanceOfPool() external view returns(uint256) {
        
        return IHC(ihcTokenAddress).balanceOf(yieldFarmPoolAddress);
    }
    
    function getYieldFarmAmount() external view returns(uint256) {
        
        return yieldFarmAmount;
    }
    
    function getYieldFarmApy() external view returns(uint) {
        return apy;
    }
    
    function getYieldAmount() external view returns(uint256) {
        uint256 yeildAmount = ((yieldFarmAmount * apy) / 100) / 365 * yieldFarmDays;
        return yeildAmount;
    }
    
    function getWithdrawDeadlineByTimestamp() external view returns(uint256) {
        return withdrawDeadlineByTimestamp;
    }
    
    function yieldFarm(uint256 _yieldFarmAmount, uint _daysAfter) external payable onlyInState(FarmState.Created) returns (bool) {
        require(_yieldFarmAmount >= IHC(ihcTokenAddress).getYieldFarmMinAmount(), "Minimum yieldFarmAmount not met");
        state = FarmState.Funded;
        withdrawDeadlineByTimestamp = block.timestamp + (_daysAfter * 1 days);
        yieldFarmer = msg.sender;
        yieldFarmDays = _daysAfter;
        yieldFarmAmount = calculateTransferAmount(_yieldFarmAmount);
        
        IHC(ihcTokenAddress).transferFrom(msg.sender, yieldFarmPoolAddress, _yieldFarmAmount);
        
        return true;
    }
    
    function withdraw() external onlyInState(FarmState.Funded) returns (bool){
        require(msg.sender == yieldFarmer, "Only the yieldFarmer can withdraw the yieldFarm");
        require(block.timestamp >= withdrawDeadlineByTimestamp, "It's not time to end");
        
        uint256 yeildAmount = ((yieldFarmAmount * apy) / 100) / 365 * yieldFarmDays;
        IHC(ihcTokenAddress).transferFrom(yieldFarmPoolAddress, yieldFarmer, yieldFarmAmount.add(yeildAmount));
        selfdestruct(yieldFarmer);
        
        return true;
    }
    
    function calculateTransferAmount(uint256 originalAmount) internal returns(uint256) {
        uint256 feeAmount = (originalAmount.mul(transactionFeePercent)).div(100);
        return originalAmount.sub(feeAmount);
    }
}