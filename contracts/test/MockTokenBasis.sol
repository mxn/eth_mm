pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/mocks/StandardTokenMock.sol';

contract MockTokenBasis is StandardTokenMock {
  function MockTokenBasis() public 
       StandardTokenMock(msg.sender, 10 ** 12) {}
 
}


