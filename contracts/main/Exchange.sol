pragma solidity ^0.4.23;

import './ExchangeShareToken.sol';
import './IExchangeCalculator.sol';
import './WithdrawableByOwnerTimeLocked.sol';

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import "zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";


contract Exchange is Ownable, BancorFormula, WithdrawableByOwnerTimeLocked {
    using SafeMath for uint;
    using SafeMath for uint32;
    using SafeERC20 for ERC20;

    uint32 private constant MAX_WEIGHT = 1000000;

    uint public constant INITIAL_SHARE_AMOUNT = 10 ** 18;
    
    
    // calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public view returns (uint256);
    ERC20 public basis;
    ERC20 public asset;
    uint32 public weightBasis;
    uint32 public weightAsset;
    uint32 public constant MAX_BPP = 10000;
    uint32 public fractionInBpp; //fraction in basis points: % of %

    //WithdrawableByOwner public feeTaker;
    IExchangeCalculator public exchangeCalculator;
    uint public collectedFeesInBasis; 

    //ExchangeShareToken
    ExchangeShareToken public shareToken;

    
    constructor (address _basis, uint32 _weightBasis, address _asset, uint32 _weightAsset, uint32 _fractionInBpp, address _exchangeCalculator, uint _releaseTime) public
    Ownable()
    WithdrawableByOwnerTimeLocked(_basis, _asset, _releaseTime)
    {
        basis = ERC20(_basis);
        asset = ERC20(_asset);
        weightBasis = _weightBasis;
        weightAsset = _weightAsset;
        fractionInBpp = _fractionInBpp;
        exchangeCalculator = IExchangeCalculator(_exchangeCalculator);
        shareToken = new ExchangeShareToken();
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
        uint basisAmount;
        if (_putAsset) {
            basisAmount = exchangeCalculator.calculateBasisAmountToGet(
            getExchangeBasisBalance(), weightBasis, asset.balanceOf(this), weightAsset, 
            _assetAmount);
        } else {
            basisAmount = exchangeCalculator.calculateBasisAmountToPut(
                getExchangeBasisBalance(), weightBasis, asset.balanceOf(this), weightAsset,
            _assetAmount);
        }
        uint fee = basisAmount.mul(fractionInBpp).div(MAX_BPP);
        fee = fee == 0 ? 1 : fee;
        return (basisAmount, fee);
    }

    function getExchangeBasisBalance() public view returns (uint) {
        return basis.balanceOf(this).sub(collectedFeesInBasis);
    }
    
    function getExchangeAssetBalance() public view returns (uint) {
        return asset.balanceOf(this);
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
        collectedFeesInBasis = collectedFeesInBasis.add(fee);
    }
    
    function buyAsset(uint _assetAmountToGet, uint _maxBasisAmountToPut) public {
        uint basisAmount;
        uint fee;
        (basisAmount, fee) = getBasisAmountAndFee(_assetAmountToGet, false);
        require(basisAmount > 0);
        uint calcBasisAmount = basisAmount.add(fee);
        require(calcBasisAmount <= _maxBasisAmountToPut);
        basis.safeTransferFrom(msg.sender, this, calcBasisAmount);
        asset.safeTransfer(msg.sender, _assetAmountToGet);
        collectedFeesInBasis = collectedFeesInBasis.add(fee);
    }

    function initMM(uint basisAmount, uint assetAmount) public  {
        require(basisAmount > 0 && assetAmount > 0, "amounts should be more than 0");
        require(shareToken.totalSupply() == 0, "total supply should be 0");
        basis.safeTransferFrom(msg.sender, this, basisAmount);
        asset.safeTransferFrom(msg.sender, this, assetAmount);
        shareToken.mint(msg.sender, INITIAL_SHARE_AMOUNT);
    }

    function getShareTokenAmount(uint basisAmount, uint assetAmount) public view returns(uint) {
        uint shareFromBasis;
        uint shareFromAsset;
        uint shareTokenTotalSupply = shareToken.totalSupply();
        shareFromBasis = basisAmount.mul(shareTokenTotalSupply).div(getExchangeBasisBalance()).div(2);  
        shareFromAsset = assetAmount.mul(shareTokenTotalSupply).div(getExchangeAssetBalance()).div(2);
        return shareFromBasis.add(shareFromAsset);
        
    }

    function supplyLiquidity(uint basisAmount, uint assetAmount) public {
        require(basisAmount > 0 || assetAmount > 0, "amounts should be more than 0");
        if (basisAmount > 0) {
            basis.safeTransferFrom(msg.sender, this, basisAmount);
        }
        if (assetAmount > 0) {
            asset.safeTransferFrom(msg.sender, this, assetAmount);
        }
        shareToken.mint(msg.sender, getShareTokenAmount(basisAmount, assetAmount));
    }

}