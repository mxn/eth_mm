pragma solidity ^0.4.23;

import './bancor/converter/BancorFormula.sol';

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';


contract Exchange is Ownable, BancorFormula {
    using SafeMath for uint;
    using SafeMath for uint32;
    
    // calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public view returns (uint256);
    ERC20 public basis;
    ERC20 public asset;
    uint32 public weightBasis = 10;
    uint32 public weightAsset = 2;
    uint32 public constant MAX_PPM = 10000;
    uint32 public fractionInPpm = 100; //one perent
    
    constructor (address _basis, address _asset, uint32 _fractionInPpm) public
    Ownable()
    {
        basis = ERC20(_basis);
        asset = ERC20(_asset);
        fractionInPpm = _fractionInPpm;
    }

    function getBasisAmountToGet(uint _assetAmountToSell) public view returns(uint) {
        // function calculateCrossConnectorReturn(uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, 
        // uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount) public view returns (uint256);
        return calculateCrossConnectorReturn(asset.balanceOf(this), weightAsset,
            basis.balanceOf(this), weightBasis, 
            _assetAmountToSell).mul(MAX_PPM.sub(fractionInPpm)).div(MAX_PPM);
    } 

    function getBasisAmountToPut(uint _assetAmountToSell) public view returns(uint) {
        // function calculateCrossConnectorReturn(uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, 
        // uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount) public view returns (uint256);
        return calculateCrossConnectorReturn(asset.balanceOf(this), weightAsset,
            basis.balanceOf(this), weightBasis, 
            _assetAmountToSell).mul(MAX_PPM.add(fractionInPpm)).div(MAX_PPM);
    } 

    function getAssetAmountToGet(uint _basisAmountToPut) public view returns(uint) {
        return calculateCrossConnectorReturn(basis.balanceOf(this), weightBasis,
            asset.balanceOf(this), weightAsset, 
            _basisAmountToPut).mul(MAX_PPM.sub(fractionInPpm)).div(MAX_PPM);
    }

    function sellAsset(uint _assetAmount, uint _minBasisAmountToPush) public {
         
    }

    
    function buyAsset(uint _assetAmount, uint _maxBasisAmountToPush) public {

    }
}