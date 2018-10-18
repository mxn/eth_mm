pragma solidity ^0.4.23;

import './IExchangeCalculator.sol';
import './WithdrawableByOwner.sol';

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";


contract Exchange is Ownable, BancorFormula {
    using SafeMath for uint;
    using SafeMath for uint32;
    using SafeERC20 for ERC20;

    uint32 private constant MAX_WEIGHT = 1000000;
    
    
    // calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public view returns (uint256);
    ERC20 public basis;
    ERC20 public asset;
    uint32 public weightBasis;
    uint32 public weightAsset;
    uint32 public constant MAX_BPP = 10000;
    uint32 public fractionInBpp; //fraction in basis points: % of %

    WithdrawableByOwner public feeTaker;
    IExchangeCalculator public exchangeCalculator;


    
    constructor (address _basis, uint32 _weightBasis, address _asset, uint32 _weightAsset, uint32 _fractionInBpp, address _exchangeCalculator) public
    Ownable()
    {
        basis = ERC20(_basis);
        asset = ERC20(_asset);
        weightBasis = _weightBasis;
        weightAsset = _weightAsset;
        fractionInBpp = _fractionInBpp;
        WithdrawableByOwner feeTakerInstance = new WithdrawableByOwner(_basis);
        feeTakerInstance.transferOwnership(msg.sender);
        feeTaker = feeTakerInstance;
        exchangeCalculator = IExchangeCalculator(_exchangeCalculator);
    }

    function getBasisAmountToGet(uint _assetAmountToSell) public view returns(uint) {
        uint basisAmount;
        uint fee;
        (basisAmount, fee) = getBasisAmountAndFee(_assetAmountToSell, true);
        return basisAmount.sub(fee);
    } 

    function getBasisAmountToPut(uint _assetAmountToGet) public view returns(uint) {
        uint basisAmount;
        uint fee;
        (basisAmount, fee) = getBasisAmountAndFee(_assetAmountToGet, false);
        return basisAmount.add(fee);
    } 

    function getBasisAmountAndFee(uint _assetAmount, bool _putAsset) public view returns (uint, uint) {
        uint basisAmount;//TODO dumb code
        if (_putAsset) {
            basisAmount = exchangeCalculator.calculateBasisAmountToGet(asset.balanceOf(this), weightAsset,
            basis.balanceOf(this), weightBasis, 
            _assetAmount);
        } else {
            basisAmount = exchangeCalculator.calculateBasisAmountToPut(asset.balanceOf(this), weightAsset,
            basis.balanceOf(this), weightBasis, 
            _assetAmount);
        }
        uint fee = basisAmount.mul(fractionInBpp).div(MAX_BPP);
        fee = fee == 0 ? 1 : fee;
        return (basisAmount, fee);
    }
    
    function sellAsset(uint _assetAmountToPut, uint _minBasisAmountToGet) public {
        uint basisAmount;
        uint fee;
        (basisAmount, fee) = getBasisAmountAndFee(_assetAmountToPut, true); 
        uint calcBasisAmount = basisAmount.sub(fee);
        require(calcBasisAmount > 0);
        require(calcBasisAmount >= _minBasisAmountToGet);
        asset.safeTransferFrom(msg.sender, this, _assetAmountToPut);
        basis.safeTransfer(msg.sender, calcBasisAmount);
        basis.safeTransfer(address(feeTaker), fee);
    }

    
    function buyAsset(uint _assetAmountToGet, uint _maxBasisAmountToPut) public {
        uint basisAmount;
        uint fee;
        (basisAmount, fee) = getBasisAmountAndFee(_assetAmountToGet, false);
        require(basisAmount > 0);
        uint calcBasisAmount = basisAmount.add(fee);
        require(calcBasisAmount <= _maxBasisAmountToPut);
        asset.safeTransferFrom(msg.sender, this, calcBasisAmount);
        basis.safeTransfer(msg.sender, _assetAmountToGet);
        basis.safeTransfer(address(feeTaker), fee);
    }

}