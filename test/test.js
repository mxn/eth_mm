//const OptionPair = artifacts.require('TokenOption') // for live
const MockTokenBasis = artifacts.require('MockTokenBasis')
const MockTokenAsset = artifacts.require('MockTokenAsset')
const Exchange = artifacts.require('Exchange')


const deployer = '0x627306090abab3a6e1400e9345bc60c78a8bef57'
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
  it ("it should be run", () => {})
})

