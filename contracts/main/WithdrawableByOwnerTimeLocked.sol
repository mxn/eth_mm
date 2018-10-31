pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract WithdrawableByOwnerTimeLocked is Ownable {

  using SafeERC20 for ERC20;
  uint constant MAX_AMOUNT = 2**256 - 1;
  address public token;
  uint public lockExpireTime;

  modifier onlyAfterLockExpired () {
    require(getCurrentTime() > lockExpireTime);
    _;
  }

  function WithdrawableByOwnerTimeLocked(address _erc20, uint _lockExpireTime) {
    token = _erc20;
    ERC20(token).approve(msg.sender, MAX_AMOUNT);
  }

  function withdraw(uint _amount) public onlyOwner onlyAfterLockExpired  {
    require(msg.sender == owner);
    ERC20 tokenErc20 = ERC20 (token);
    require(tokenErc20.balanceOf(this) >= _amount);
    tokenErc20.safeTransfer(owner, _amount);
  }

  function getCurrentTime() internal returns (uint) { // to make  testing with tim setting possible
    return now;
  }

}
