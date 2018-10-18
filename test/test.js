//const OptionPair = artifacts.require('TokenOption') // for live
const MockTokenBasis = artifacts.require('MockTokenBasis')
const MockTokenAsset = artifacts.require('MockTokenAsset')
const Exchange = artifacts.require('Exchange')
const ExchangeCalculator = artifacts.require('ExchangeCalculator')



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

contract ("Tokens:", async  () =>  {
  const transferAmountAsset = 100000
  const transferAmountBasis = 1000000
  var exchange, asset, basis, exchangeCalculator

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

  it ("trader can buy asset", async  () => {
    let amountAssetToBuy = 1000
    await basis.approve(exchange.address, 10000000000, {from: trader})
    let basisAmountAndFee = await exchange.getBasisAmountAndFee(amountAssetToBuy, false)
    console.log("amount: ", basisAmountAndFee[0].toNumber() )
    console.log("fee: ", basisAmountAndFee[1].toNumber() )
    await exchange.buyAsset(amountAssetToBuy, 100000000, {from: trader})
    let balance = await asset.balanceOf(trader)
    assert.equal(amountAssetToBuy, balance.toNumber())
  })

  it ("trader can sell asset", async  () => {
    let amountAssetToBuy = 1000
    await asset.approve(exchange.address, 10000000000, {from: trader})
    let basisAmountAndFee = await exchange.getBasisAmountAndFee(amountAssetToBuy, true)
    console.log("amount: ", basisAmountAndFee[0].toNumber() )
    console.log("fee: ", basisAmountAndFee[1].toNumber() )
    await exchange.sellAsset(amountAssetToBuy, 1, {from: trader})
    let balance = await asset.balanceOf(trader)
    assert.equal(0, balance.toNumber())
  })


})

