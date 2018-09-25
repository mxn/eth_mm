var Exchange = artifacts.require("Exchange")

module.exports = function(deployer, network) {
    deployer.deploy(Exchange)
}
