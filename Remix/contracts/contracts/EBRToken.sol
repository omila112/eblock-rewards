// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EBRToken is ERC20, Ownable {
    
    // Mapping to keep track of authorized "Smart Bins" (Recyclers)
    mapping(address => bool) public recyclers;

    constructor() ERC20("E-Block Reward", "EBR") Ownable(msg.sender) {
        // Mint 1 million tokens to the owner (you) when deploying
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    // Function to authorize a smart bin address
    function addRecycler(address _recycler) public onlyOwner {
        recyclers[_recycler] = true;
    }

    // Modifier to check if caller is an authorized recycler
    modifier onlyRecycler() {
        require(recyclers[msg.sender] || msg.sender == owner(), "Not authorized recycler");
        _;
    }

    // The core function: Issue rewards to a user
    function issueReward(address user, uint256 weight) public onlyRecycler {
        // Reward formula: 50 tokens per 1 kg
        uint256 rewardAmount = weight * 50 * 10 ** decimals();
        _transfer(owner(), user, rewardAmount);
    }

    // ========== WITHDRAWAL FUNCTION ==========
    /**
     * @notice Allows users to withdraw tokens from their balance
     * @dev Uses require() for security checks before transfer
     * @param _amount The amount of tokens to withdraw (in smallest unit)
     * 
     * Requirements:
     * - Must have sufficient balance
     * - Amount must be greater than 0
     * - Contract must have enough tokens to process withdrawal
     */
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "EBRToken: Withdrawal amount must be greater than 0");
        require(balanceOf(msg.sender) >= _amount, "EBRToken: Insufficient balance");
        require(balanceOf(address(this)) >= _amount, "EBRToken: Contract has insufficient funds");
        
        // Transfer tokens from user to contract (burn/hold)
        _transfer(msg.sender, address(this), _amount);
        
        // Emit event for tracking
        emit Withdrawal(msg.sender, _amount);
    }

    // Event for withdrawal tracking
    event Withdrawal(address indexed user, uint256 amount);
}