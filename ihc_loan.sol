pragma experimental ABIEncoderV2;
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

contract IHC_LOAN {
    using SafeMath for uint256;
    struct Terms {
        uint256 collateralAmount;
        uint repayByType;
    }
    
    Terms public terms;
    enum LoanState{Created, Funded, Taken}
    LoanState public state;
    address payable public lender;
    address payable public borrower;
    address public ihcTokenAddress;
    uint256 repayByTimestamp;
    uint loanDuration;
    uint256 feePercent;
    uint256 loanAmountWithoutFee;
    uint256 loanAmount;
    uint256 loanMinAmount;
    uint256 collateralAmountWithoutFee;
    uint256 private transactionFeePercent;
    bool public borrower_result;
    bool public lender_result;
    bool public repay_result;
    bool public liquidate_result;

    constructor (
        Terms memory _terms
    ) public payable{
        terms = _terms;
        if(terms.repayByType == 1) {
            repayByTimestamp = block.timestamp + 30 days;
            loanDuration = 30;
        }else if(terms.repayByType == 2) {
            repayByTimestamp = block.timestamp + 90 days;
            loanDuration = 90;
        }else if(terms.repayByType == 3) {
            repayByTimestamp = block.timestamp + 180 days;
            loanDuration = 180;
        }else if(terms.repayByType == 4) {
            repayByTimestamp = block.timestamp + 365 days;
            loanDuration = 365;
        }else {
            revert();
        }
        ihcTokenAddress = 0x86a53fcd199212FEa44FA7e16EB1f28812be911D;
        lender = IHC(ihcTokenAddress).getLoanPoolAddress();
        state = LoanState.Created;
    }
    
    modifier onlyInState(LoanState expectedState) {
        require(state == expectedState, "Not allowed in this state");
        _;
    }
    
    function getIhcTokenAddress() public view returns(address) {
        
        return ihcTokenAddress;
    }
    
    function getThisContractAddress() public view returns(address) {
        
        return address(this);
    }
    
    function getLoanPoolAddress() public view returns(address) {
        
        return lender;
    }
    
    function getBalanceOfPool() public view returns(uint256) {
        
        return IHC(ihcTokenAddress).balanceOf(lender);
    }
    
    function getLoanAmountWithoutFee() public view returns(uint256) {
        
        return loanAmountWithoutFee;
    }
    
    function getLoanAmount() public view returns(uint256) {
        
        return loanAmount;
    }
    
    function getCollateralAmount() public view returns(uint256) {
        
        return terms.collateralAmount;
    }
    
    function getCollateralAmountWithoutFee() public view returns(uint256) {
        
        return collateralAmountWithoutFee;
    }
    
    function getRepayByTimestamp() public view returns(uint256) {
        return repayByTimestamp;
    }
    
    function getFeePercent() public view returns(uint256) {
        return feePercent;
    }
    
    function getFeeAmount() public view returns(uint256) {
        return ((loanAmountWithoutFee * feePercent) / 100 / 365) * loanDuration;
    }
    
    function getRepayAmount() public view returns(uint256) {
        uint feeAmount = ((loanAmountWithoutFee * feePercent) / 100 / 365) * loanDuration;
        return loanAmount.add(feeAmount);
    }
    
    function checkTokenAllowance(address owner) public view returns (uint256) {
        return IHC(ihcTokenAddress).allowance(owner, address(this));
    }
    
    function takeALoanAndAcceptLoanTerms() public payable onlyInState(LoanState.Created) returns(bool) {
        require(terms.collateralAmount >= IHC(ihcTokenAddress).getLoanMinAmount(), "Minimum loan amount not met");
        borrower = msg.sender;
        state = LoanState.Taken;
        
        // calculate
        feePercent = IHC(ihcTokenAddress).getLoanFeePercent();
        transactionFeePercent = IHC(ihcTokenAddress).getTransactionFeePercent();
        loanAmount = terms.collateralAmount * IHC(ihcTokenAddress).getLoanSizePercent() / 100;
        loanAmountWithoutFee = calculateTransferAmount(loanAmount);
        collateralAmountWithoutFee = calculateTransferAmount(terms.collateralAmount);
        
        // grant allowance on token smart contract
        borrower_result = IHC(ihcTokenAddress).transferFrom(borrower, address(this), terms.collateralAmount);
        
        // grant allowance on token smart contract
        lender_result = IHC(ihcTokenAddress).transferFrom(lender, borrower, loanAmount);
        
        if(borrower_result == true && lender_result == true) {
            return true;
        }else{
            return false;
        }
    }
    
    function repay() public onlyInState(LoanState.Taken) returns(bool) {
        require(msg.sender == borrower, "Only the borrower can repay the loan");
        uint feeAmount = ((loanAmountWithoutFee * feePercent * loanDuration) / 100) / 365;        
        repay_result = IHC(ihcTokenAddress).transferFrom(borrower, lender, loanAmount.add(feeAmount));
        selfdestruct(borrower);

        return repay_result;
    }
    
    function liquidate() public onlyInState(LoanState.Taken) returns(bool) {
        require(msg.sender == lender, "Only the lender can liquidate the loan");
        require(block.timestamp >= repayByTimestamp, "Can not liquidate before the loan is due");
        liquidate_result = IHC(ihcTokenAddress).transfer(lender, collateralAmountWithoutFee);
        selfdestruct(lender);
        return liquidate_result;
    }
    
    function calculateTransferAmount(uint256 originalAmount) internal returns(uint256) {
        uint256 feeAmount = (originalAmount.mul(transactionFeePercent)).div(100);
        return originalAmount.sub(feeAmount);
    }
}