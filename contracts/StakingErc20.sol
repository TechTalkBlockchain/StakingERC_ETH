// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.9.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';


contract StakingErc20 {
    
    address owner;
    address tokenAddress;

    struct Stake {
        uint256 amount;
        uint256 rewards;
        uint256 stakeTime;
        uint256 endTime;
        bool isClaimed;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;

    }

    mapping(address => Stake[]) public totalStakes;

    mapping(address => uint256) public balances;

    event StakedSuccessfully(address indexed staker, uint256 amount, uint256 endTime);
    event WithdrawalSuccessful(address indexed staker, uint256 amount);


    function stakeTokens(uint256 _amount) external {
        require(msg.sender != address(0), "Address zero not allowed");
        require(_amount > 0, "Amount must be more than zero");

        uint256 _userTokenBalance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(_userTokenBalance >= _amount, "Insufficient balance");

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

        balances[msg.sender] += _amount;

        Stake memory _stake = Stake({
            amount: _amount,
            rewards: 0,
            
            stakeTime: block.timestamp, // stakeTime: 30 * 1 days,
            
            endTime: block.timestamp + 30 * 1 days, // endTime: block.timestamp + 30 * 1 days,
            isClaimed: false
        });

        totalStakes[msg.sender].push(_stake);

        emit StakedSuccessfully(msg.sender, _amount, _stake.endTime);
    }

    function getMyStakes() external view returns(Stake[] memory) {
        return totalStakes[msg.sender];
    }

    function withdrawRewardTokens(uint _index) external {
        require(totalStakes[msg.sender].length > 0, "You have no stakes");
        
        Stake storage selectedStake = totalStakes[msg.sender][_index];
        require(!selectedStake.isClaimed, "You have already claimed reward tokens");
        require(block.timestamp >= selectedStake.endTime, "Stake still ongoing");

        uint _principal = selectedStake.amount;
    
        uint _stakeDuration = selectedStake.endTime; 
        uint _interest = calculateInterest(_principal, _stakeDuration / 60); 
        selectedStake.rewards += _interest;

        balances[msg.sender] -= selectedStake.amount;

        IERC20(tokenAddress).transfer(msg.sender, selectedStake.amount + selectedStake.rewards);
        
        selectedStake.isClaimed = true;

        emit WithdrawalSuccessful(msg.sender, selectedStake.amount + selectedStake.rewards);
    }

    function calculateInterest(uint256 _principal, uint _stakeDuration) private pure returns (uint256) {
        uint256 rate = 25; 
        uint256 precision = 1e18; 
        uint256 timeInYears = (_stakeDuration * precision) / 365 days; 

        uint256 interest = (_principal * rate * timeInYears) / (100 * precision);

        return interest;
    }
}