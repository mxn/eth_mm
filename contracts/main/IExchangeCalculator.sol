pragma solidity ^0.4.23;

import './bancor/converter/BancorFormula.sol';

import 'zeppelin-solidity/contracts/math/SafeMath.sol';


contract IExchangeCalculator is BancorFormula {

    function calculateBasisAmountToPut(uint256 _balanceBasis, uint32 _weightBasis, uint256
         _balanceAsset, uint32 _weightAsset, uint256 _amountAssetToGet) public view returns (uint256);

    function calculateBasisAmountToGet(uint256 _balanceBasis, uint32 _weightBasis, uint256
         _balanceAsset, uint32 _weightAsset, uint256 _amountAssetToPut) public view returns (uint256);


}