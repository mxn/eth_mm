//const OptionPair = artifacts.require('TokenOption') // for live
const MockTokenBasis = artifacts.require('MockTokenBasis')
const MockTokenAsset = artifacts.require('MockTokenAsset')
const Exchange = artifacts.require('MockExchange')
const ExchangeCalculator = artifacts.require('ExchangeCalculator')
const ExchangeShareToken = artifacts.require('ExchangeShareToken')



const deployer = '0x627306090abab3a6e1400e9345bc60c78a8bef57'
const trader = '0xf17f52151ebef6c7334fad080c5704d77216b732'
/* const writer1 = '0xf17f52151ebef6c7334fad080c5704d77216b732'
const buyer2 = '0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef'
const optionSerieCreator = '0x0d1d4e623d10f9fba5db95830f7d3839406c6af2'
const optionSerieTokenBuyer = '0x2932b7a2355d6fecc4b5c0b6bd44cc31df247a2e'
const writer2 = '0x2191ef87e392377ec08e7c08eb105ef5448eced5'

const tokensOwner = '0x5aeda56215b167893e80b4fe645ba6d5bab767de'
const optionFactoryCreator = '0x6330a553fc93768f612722bb8c2ec78ac90b3bbc'
const optionTokenCreator = '0x0f4f2ac550a1b4e2280d04c21cea7ebd822934b5' */

if (typeof web3 !== 'undefined') {
  console.log('web3 is defined');

} else {
  throw 'web3 is not defined'
  console.log('web3 is not defined');
}

var exchange, asset, basis, exchangeCalculator

contract ("Tokens:", async  () =>  {
  const transferAmountAsset = 100000
  const transferAmountBasis = 1000000
  
  it("contracts should be correctly initialized", async () => {
    asset = await MockTokenAsset.deployed()
    exchange = await Exchange.deployed()
    basis = await MockTokenBasis.deployed()
    exchangeCalculator = await ExchangeCalculator.deployed()
    assert.ok(true, "the last line is not reached: init is not OK")
  })

  it ("should transfer asset token to Exchange contract", async () => {
    await asset.transfer(exchange.address, transferAmountAsset, {from: deployer})
    let balance = await asset.balanceOf(exchange.address)
    assert.equal(transferAmountAsset, balance.toNumber())
  })

  it ("should transfer basis token to Exchange contract", async () => {
    await basis.transfer(exchange.address, transferAmountBasis, {from: deployer})
    let balance = await basis.balanceOf(exchange.address)
    assert.equal(transferAmountBasis, balance.toNumber())
  })

  it("test calculateBasisAmountToPut", async() => {
    let  assetAmountToGet = 20000
    let basisAmountToPut = await exchangeCalculator.calculateBasisAmountToPut(100000, 20, 
      50000, 1, assetAmountToGet);
    console.log("BasisAmountToPut", basisAmountToPut.toNumber())
    console.log("price per 1", basisAmountToPut.toNumber() / assetAmountToGet)
    
  })

  it("test calculateBasisAmountToGet", async() => {
    let  assetAmountToPut = 20000
    let basisAmountToGet = await exchangeCalculator.calculateBasisAmountToGet(100000, 20, 
      50000, 1, assetAmountToPut);
    console.log("BasisAmountToGet", basisAmountToGet.toNumber())
    console.log("price per 1", basisAmountToGet.toNumber() / assetAmountToPut)
    
  })

  it ("ask price should be OK", async () => {
    let amount = await exchange.getBasisAmountToPut(1000)
    //assert.ok()
    console.log("amount to put", amount.toNumber())
  })

  it ("bid price should be OK", async () => {
    let amount = await exchange.getBasisAmountToGet(1000)
    console.log("amount to get", amount.toNumber())
  })

  it ("transfer basis to trader should be OK", async  () => {
    await basis.transfer(trader, transferAmountBasis, {from: deployer})
    let balance = await basis.balanceOf(trader)
    assert.equal(transferAmountBasis, balance.toNumber())
  
  })

  it ("revert by buy asset if exchange price is more than limit price", async  () => {
    try {
      await basis.approve(exchange.address, 10000000000, {from: trader})
      await exchange.buyAsset(amountAssetToBuy, 1, {from: trader})
      assert.ok(false, "should not be there")
    } catch(e) {
      //NOP
    }
  })

  it ("trader can buy asset", async  () => {
    let amountAssetToBuy = 1000
    await basis.approve(exchange.address, 10000000000, {from: trader})
    let basisAmountAndFee = await exchange.getBasisAmountAndFee(amountAssetToBuy, false)
    console.log("amount: ", basisAmountAndFee[0].toNumber() )
    console.log("fee: ", basisAmountAndFee[1].toNumber() )
    let startAssetBalance = await asset.balanceOf(trader)
    let startBasisBalanceTrader = await basis.balanceOf(trader)
    let startBasisBalanceExchangeAddress = await basis.balanceOf(exchange.address)
    let startBasisBalanceExchange = await exchange.getExchangeBasisBalance()
    let startFee = await exchange.collectedFeesInBasis()
    
    await exchange.buyAsset(amountAssetToBuy, 100000000, {from: trader})
    let endAssetBalance = await asset.balanceOf(trader)
    let endBasisBalanceTrader = await basis.balanceOf(trader)
    let endBasisBalanceExchangeAddress = await basis.balanceOf(exchange.address)
    let endBasisBalanceExchange = await exchange.getExchangeBasisBalance()
    let endFee = await exchange.collectedFeesInBasis()
    assert.equal(amountAssetToBuy, endAssetBalance.sub(startAssetBalance).toNumber(), 
      "amount asset to buy is equal to delta balances of trader")
    assert.equal(startBasisBalanceTrader.sub(endBasisBalanceTrader).toNumber(), 
      endBasisBalanceExchangeAddress.sub(startBasisBalanceExchangeAddress).toNumber(), 
      "income in basis for exchange is equal to outcome in basis of trader ")
    assert.equal(endFee.sub(startFee).add(endBasisBalanceExchange.sub(startBasisBalanceExchange)).toNumber(), 
      endBasisBalanceExchangeAddress.sub(startBasisBalanceExchangeAddress).toNumber(),
      "change in contract exchange balance equals to fee + exchange balance"
      )
  })

  it ("revert by sell asset if exchange price is less than limit price", async  () => {
    try {
      await asset.approve(exchange.address, 10000000000, {from: trader})
      await exchange.sellAsset(amountAssetToBuy, 10000000000, {from: trader})
      assert.ok(false, "should not be there")
    } catch(e) {
      //NOP
    }
  })

  it ("trader can sell asset", async  () => {
    let amountAsset = 1000
    await asset.approve(exchange.address, 10000000000, {from: trader})
    let basisAmountAndFee = await exchange.getBasisAmountAndFee(amountAsset, true)
    console.log("amount: ", basisAmountAndFee[0].toNumber() )
    console.log("fee: ", basisAmountAndFee[1].toNumber() )
    let startAssetBalance = await asset.balanceOf(trader)
    let startBasisBalanceTrader = await basis.balanceOf(trader)
    let startBasisBalanceExchangeAddress = await basis.balanceOf(exchange.address)
    let startBasisBalanceExchange = await exchange.getExchangeBasisBalance()
    let startFee = await exchange.collectedFeesInBasis()
    
    await exchange.sellAsset(amountAsset, 1, {from: trader})
    let endAssetBalance = await asset.balanceOf(trader)
    let endBasisBalanceTrader = await basis.balanceOf(trader)
    let endBasisBalanceExchangeAddress = await basis.balanceOf(exchange.address)
    let endBasisBalanceExchange = await exchange.getExchangeBasisBalance()
    let endFee = await exchange.collectedFeesInBasis()
    assert.equal(amountAsset, startAssetBalance.sub(endAssetBalance).toNumber(), 
    "amount asset to sell is equal to delta balances of trader")
    assert.equal(endBasisBalanceTrader.sub(startBasisBalanceTrader).toNumber(), 
    startBasisBalanceExchangeAddress.sub(endBasisBalanceExchangeAddress).toNumber(), 
    "outcome in basis for exchange is equal to income in basis of trader ")
    assert.equal(startBasisBalanceExchange.sub(endBasisBalanceExchange).sub(endFee.sub(startFee)).toNumber(), 
    startBasisBalanceExchangeAddress.sub(endBasisBalanceExchangeAddress).toNumber(),
    "change in contract exchange balance equals to fee + exchange balance")
    console.log("fee collected", endFee.toNumber())
  })

  it ("cannot withdraw before expire date", async () => {
    let ownerOfExchange = await exchange.owner()
    assert.equal(ownerOfExchange, deployer) 
    let lockExpireTime = await exchange.lockExpireTime()
    let curTime = await exchange.getCurrentTime()
    assert.isBelow(curTime.toNumber(), lockExpireTime.toNumber())
    try {
      await exchange.withdrawAll({from: ownerOfExchange})
      assert.ok(false)
    } catch (e) {
      //NOP
      assert.ok(true)
    }
  })

    it ("can withdraw after expire date", async () => {
      let ownerOfExchange = await exchange.owner()
      assert.equal(ownerOfExchange, deployer) 
      let releaseDate = await exchange.lockExpireTime()
      let mockedCurTime = releaseDate.toNumber() + 1
      await exchange.setCurrentTime(mockedCurTime)
      let startAssetBalanceOwner = await asset.balanceOf(ownerOfExchange)
      let startBasisBalanceOwner = await basis.balanceOf(ownerOfExchange)
      let startBasisBalanceExchangeAddress = await basis.balanceOf(exchange.address)
      let startAssetBalanceExchangeAddress = await asset.balanceOf(exchange.address)
      await exchange.withdrawAll({from: ownerOfExchange})
      let endAssetBalanceOwner = await asset.balanceOf(ownerOfExchange)
      let endBasisBalanceOwner = await basis.balanceOf(ownerOfExchange)
      let endBasisBalanceExchangeAddress = await basis.balanceOf(exchange.address)
      let endAssetBalanceExchangeAddress = await asset.balanceOf(exchange.address)
      assert.equal(endBasisBalanceExchangeAddress.toNumber(), 0)
      assert.equal(endAssetBalanceExchangeAddress.toNumber(), 0)
      assert.equal(endBasisBalanceOwner.sub(startBasisBalanceOwner).toNumber(), startBasisBalanceExchangeAddress)
      assert.equal(endAssetBalanceOwner.sub(startAssetBalanceOwner).toNumber(), startAssetBalanceExchangeAddress)
      
      assert.ok(true)
    })
})

contract("Money Maker", async () => {
  
  const initialPrice = 47
  const assetAmount = 10000
  const basisAmount = assetAmount * initialPrice
  
  it ("should be correctly initialized", async() => {
    
    
    await basis.approve(exchange.address, 10**9)
    await asset.approve(exchange.address, 10**9)
    let shareToken = ExchangeShareToken.at(await exchange.shareToken())
    let startBalanceShare = await shareToken.balanceOf(deployer)
    assert.equal(startBalanceShare.toNumber(), 0, "initial startBalanceShare should be 0")
    await exchange.initMM(basisAmount, assetAmount, {from: deployer})
    let endBalanceShare = await shareToken.balanceOf(deployer)
    let endBalanceAsset = await asset.balanceOf(exchange.address)
    let endBalanceBasis = await basis.balanceOf(exchange.address)
    console.log("endBalance asset", endBalanceAsset.toNumber())
    console.log("endBalance basis", endBalanceBasis.toNumber())
    assert.equal(endBalanceShare.sub(startBalanceShare).toNumber(), 
      (await exchange.INITIAL_SHARE_AMOUNT()).toNumber())
    
  })
  
  it ("the price should be approximately equal initial price ", async() => {
    let amountToSell = 100
    let basisToGetCalc = await exchangeCalculator.calculateBasisAmountToGet(47 * 10000, 10, 
      10000, 10, amountToSell);
    let assetAmount = await exchange.getBasisAmountToGet(amountToSell)
    assert.ok(assetAmount.toNumber() < 4800 && assetAmount.toNumber() > 4600)
  })
})
