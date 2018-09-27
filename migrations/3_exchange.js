const Exchange = artifacts.require("Exchange")
const MockTokenBasis = artifacts.require("MockTokenBasis")
const MockTokenAsset = artifacts.require("MockTokenAsset")
//const BancorFormula = artifacts.require("BancorFormula")


module.exports = function(deployer, network) {
  //deployer.deploy(Ba)
  deployer.deploy(Exchange, MockTokenBasis.address, MockTokenAsset.address)
}
