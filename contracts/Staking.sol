// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staking is ERC20 {
    address public owner;
    uint256 public secondsInAYear = 3.154e7;
    mapping(address => uint256) public staked;
    mapping(address => uint256) public stakedFromTS;

    constructor() ERC20("Staking", "STK") {
        owner = msg.sender;
        _mint(msg.sender, 1000000e18);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }

    function mintTokens(address _account, uint256 _amount) external onlyOwner {
        _mint(_account, _amount);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be a positive number");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, address(this), amount);
        if (staked[msg.sender] > 0) {
            claim();
        }
        stakedFromTS[msg.sender] = block.timestamp;
        staked[msg.sender] += amount;
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be a positive number");
        require(
            staked[msg.sender] >= amount,
            "amount is greater than staked value"
        );
        claim();
        staked[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }

    function claim() public {
        require(staked[msg.sender] > 0, "You have not staked your tokens.");
        uint256 secondsStaked = block.timestamp - stakedFromTS[msg.sender];
        uint256 rewards = (staked[msg.sender] * secondsStaked) / secondsInAYear;
        _mint(msg.sender, rewards);
        stakedFromTS[msg.sender] = block.timestamp;
    }

    function stakedValue(address _account) external view returns (uint256) {
        return staked[_account];
    }
}

// 999900,000000000000000000
// 999900,000174381737476220
//1000000,000951173113506656
