const ExchangeCalculator = artifacts.require("ExchangeCalculator")
const Exchange = artifacts.require("Exchange")
const MockExchange = artifacts.require("MockExchange")
const MockTokenBasis = artifacts.require("MockTokenBasis")
const MockTokenAsset = artifacts.require("MockTokenAsset")

function getTestExpirationDate() {
  return new Date() / 1000 + 60 * 60; //one hour ahead
}

module.exports = function(deployer, network) {
  //deployer.deploy(Ba)
  deployer.deploy(ExchangeCalculator)
    .then(exchangeCalculatorInstance =>
     deployer.deploy(MockExchange, MockTokenBasis.address, 
        200, MockTokenAsset.address, 10, 100, 
        exchangeCalculatorInstance.address, getTestExpirationDate() ))
}
