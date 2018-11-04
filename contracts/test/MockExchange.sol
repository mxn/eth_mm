import '../main/Exchange.sol';
//import '../main/WithdrawableByOwnerTimeLocked.sol';


contract MockExchange is Exchange {
    uint private currentTime;
    
    constructor (address _basis, uint32 _weightBasis, address _asset, uint32 _weightAsset, uint32 _fractionInBpp, address _exchangeCalculator, uint _releaseTime) 
    Exchange(_basis, _weightBasis, _asset, _weightAsset, _fractionInBpp, _exchangeCalculator, _releaseTime)
    public {}
    

    function getCurrentTime() public view returns (uint) { // for testing we made it overridable
        if (currentTime == 0) {
            return now;
        }
        return currentTime;
    }

    function setCurrentTime(uint _currentTime) public {
        currentTime = _currentTime;
    }
}