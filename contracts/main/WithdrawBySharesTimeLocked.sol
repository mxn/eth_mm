pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";
import "./ExchangeShareToken.sol";

contract WithdrawBySharesTimeLocked {
    
    using SafeERC20 for ERC20;
    using SafeERC20 for ExchangeShareToken;
    using SafeMath for uint;

    uint constant MAX_AMOUNT = 2**256 - 1;
    uint public lockExpireTime;
    ERC20[] lockedTokens;
    ExchangeShareToken public shareToken;

    modifier onlyAfterLockExpired () {
        require(getCurrentTime() > lockExpireTime);
        _;
    }
    
    function WithdrawBySharesTimeLocked (address[] _tokens, uint _lockExpireTime) public {
        shareToken = new ExchangeShareToken();
        uint lenOfArray = _tokens.length;
        lockedTokens = new ERC20[](lenOfArray);
        for (uint i = 0; i < lenOfArray; i++) {
            lockedTokens[i] = ERC20(_tokens[i]);
        }
        lockExpireTime = _lockExpireTime;
    }

    function getCurrentTime() public view returns (uint) { // to make  testing with tim setting possible
        return now;
    }

    function withdrawForShares (uint _shareTokenAmount) {
        _withdrawForShares(_shareTokenAmount);
    }

    function _withdrawForShares (uint _shareTokenAmount) private onlyAfterLockExpired {
        uint totalShareSupply = shareToken.totalSupply();
        shareToken.safeTransferFrom(msg.sender, this, _shareTokenAmount);
        for (uint i = 0; i < lockedTokens.length; i++) {
            ERC20 token = lockedTokens[i];
            uint claimedTokenAmount = _shareTokenAmount.mul(token.balanceOf(this)).div(totalShareSupply);
            token.transfer(msg.sender, claimedTokenAmount);
        }
        shareToken.burn(_shareTokenAmount);
    }

    function withdrawAll () public onlyAfterLockExpired {
        _withdrawForShares(shareToken.balanceOf(msg.sender));
    }

}