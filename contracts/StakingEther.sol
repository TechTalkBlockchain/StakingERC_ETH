// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.9.0;

contract EtherStaking {
    struct StakersDetails {
        uint256 balance;
        uint256 Staketime;
        uint256 Stakereward;
    }

    mapping(address => StakersDetails) public stakingInfo;
    uint256 public rewardBalance;

      constructor() payable {
        rewardBalance += msg.value;
    }

    event StartStaking (address indexed user, uint256 amount, uint256 stakingTime);
    event WithdrawnConfirmation (address indexed user, uint256 amount, uint256 withdrawnTime);

    function stakeEther(uint256 _stakingTime) public payable {
        require(msg.value > 0, " Insufficient Balance");
        uint256 reward = calculateReward(msg.value, _stakingTime);
        require(rewardBalance >= reward, "Insufficient reward balance");
        rewardBalance -= reward;
        stakingInfo[msg.sender] = StakersDetails(msg.value, block.timestamp + _stakingTime, reward);

        emit StartStaking (msg.sender, msg.value, _stakingTime);
    }

    function calculateReward(uint256 amount, uint256 _stakingTime) public pure returns (uint256) {
        uint256 secondsperYear = 31536000; 
        uint256 reward = amount * _stakingTime / secondsperYear;
        return reward;
    }

    function withdrawal() public 

    {
        require(stakingInfo[msg.sender].balance > 0, "No Eth for withdrawal");
        require(block.timestamp >= stakingInfo[msg.sender].Staketime, "Staking in Progress");
        require(stakingInfo[msg.sender].balance > 0, "User has not staked any Ether");
        
        uint256 totalAmount = stakingInfo[msg.sender].balance + stakingInfo[msg.sender].Stakereward;
        
        stakingInfo[msg.sender].balance = 0;
        stakingInfo[msg.sender].Staketime = 0;
        stakingInfo[msg.sender].Stakereward = 0;
        (bool success, ) = payable(msg.sender).call{value: totalAmount}("");
        require(success, "Sending Ether Failed");
        emit WithdrawnConfirmation(msg.sender, totalAmount, block.timestamp);
    }
}
