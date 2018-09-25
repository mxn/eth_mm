pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/mocks/StandardTokenMock.sol';

contract MockTokenAsset is StandardTokenMock {
  function MockTokenAsset () public 
       StandardTokenMock(msg.sender, 10 ** 12) {}
 
}


