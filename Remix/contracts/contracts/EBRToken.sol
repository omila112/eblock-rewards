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
}