pragma solidity ^0.4.23;

import './bancor/converter/BancorFormula.sol';
import './IExchangeCalculator.sol';

import 'zeppelin-solidity/contracts/math/SafeMath.sol';


contract ExchangeCalculator is BancorFormula, IExchangeCalculator {
    using SafeMath for uint;
    using SafeMath for uint32;
    
    function calculateBasisAmountToPut(uint256 _balanceBasis, uint32 _weightBasis, uint256
         _balanceAsset, uint32 _weightAsset, uint256 _amountAssetToGet) public view returns (uint256) {
       uint newBalanceAsset = _balanceAsset.sub(_amountAssetToGet);
       uint powerResult;
       uint precision;
       (powerResult, precision) = power (_balanceAsset, newBalanceAsset, _weightAsset, _weightBasis);
       uint newBalanceBasisAux = _balanceBasis.mul(powerResult);
       uint newBalanceBasis = newBalanceBasisAux >> precision;
       return newBalanceBasis.sub(_balanceBasis);
    }

    function calculateBasisAmountToGet(uint256 _balanceBasis, uint32 _weightBasis, uint256
         _balanceAsset, uint32 _weightAsset, uint256 _amountAssetToPut) public view returns (uint256) {
        uint newBalanceAsset = _balanceAsset.add(_amountAssetToPut);
       uint powerResult;
       uint precision;
       (powerResult, precision) = power (newBalanceAsset, _balanceAsset, _weightAsset, _weightBasis);
       uint newBalanceBasisAux = _balanceBasis.mul(powerResult);
       uint newBalanceBasis = newBalanceBasisAux >> precision;
       return newBalanceBasis.sub(_balanceBasis);    
    }


}