const ExchangeCalculator = artifacts.require("ExchangeCalculator")
const Exchange = artifacts.require("Exchange")
const MockTokenBasis = artifacts.require("MockTokenBasis")
const MockTokenAsset = artifacts.require("MockTokenAsset")
//const BancorFormula = artifacts.require("BancorFormula")


module.exports = function(deployer, network) {
  //deployer.deploy(Ba)
  deployer.deploy(ExchangeCalculator)
    .then(exchangeCalculatorInstance => 
      deployer.deploy(Exchange, MockTokenBasis.address, 200, MockTokenAsset.address, 10, 100, 
      exchangeCalculatorInstance.address))
}
