pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract WithdrawableByOwnerTimeLocked is Ownable {

  using SafeERC20 for ERC20;
  uint constant MAX_AMOUNT = 2**256 - 1;
  address public token;
  address public basis;
  uint public lockExpireTime;

  modifier onlyAfterLockExpired () {
    require(getCurrentTime() > lockExpireTime);
    _;
  }

  function WithdrawableByOwnerTimeLocked(address _basis, address _token, uint _lockExpireTime) {
    token = _token;
    basis = _basis;
    lockExpireTime = _lockExpireTime;
    ERC20(token).approve(msg.sender, MAX_AMOUNT);
    ERC20(basis).approve(msg.sender, MAX_AMOUNT);
  }

  function withdraw(address _token, uint _amount) public onlyOwner onlyAfterLockExpired  {
    ERC20 tokenErc20 = ERC20 (token);
    require(tokenErc20.balanceOf(this) >= _amount);
    tokenErc20.safeTransfer(owner, _amount);
  }

  function withdrawAll() public onlyOwner onlyAfterLockExpired  {
    ERC20 tokenErc20 = ERC20 (token);
    tokenErc20.safeTransfer(owner, tokenErc20.balanceOf(this));
    ERC20 basisErc20 = ERC20 (basis);
    basisErc20.safeTransfer(owner, basisErc20.balanceOf(this));
  }


  function getCurrentTime() public view returns (uint) { // to make  testing with tim setting possible
    return now;
  }

}
