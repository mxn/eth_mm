var MockTokenBasis = artifacts.require("MockTokenBasis")
var MockTokenAsset = artifacts.require("MockTokenAsset")

module.exports = function(deployer, network) {
    deployer.deploy(MockTokenBasis)
    deployer.deploy(MockTokenAsset)

}
