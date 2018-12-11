pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';

contract ExchangeShareToken is StandardToken, BurnableToken, MintableToken {
}