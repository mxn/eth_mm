pragma solidity ^0.4.23;

import './bancor/converter/BancorFormula.sol';

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';


contract Exchange is Ownable, BancorFormula {
    // calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public view returns (uint256);
    ERC20 public basis;
    ERC20 public asset;
    uint32 public weightBasis = 10;
    uint32 public weightAsset = 2;
    
    constructor (address _basis, address _asset) public
    Ownable()
    {
        basis = ERC20(_basis);
        asset = ERC20(_asset);
    }

    function getBasisAmountToGet(uint _assetAmountToSell) public view returns(uint) {
        // function calculateCrossConnectorReturn(uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, 
        // uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount) public view returns (uint256);
        return calculateCrossConnectorReturn( asset.balanceOf(this), weightAsset,
            basis.balanceOf(this), weightBasis, 
            _assetAmountToSell);
    }   

    function getBasisAmountToPut(uint _assetAountToBuy) public view returns(uint) {
        return calculateCrossConnectorReturn(asset.balanceOf(this), weightAsset,
            basis.balanceOf(this), weightBasis, 
            _assetAountToBuy);
    }

    function sellAsset(uint _assetAmount, uint _minBasisAmountToPush) public {

    }

    
    function buyAsset(uint _assetAmount, uint _maxBasisAmountToPush) public {

    }
}