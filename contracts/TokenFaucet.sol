// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenFaucet is ReentrancyGuard {
    Token public tokenContract;
    address public admin;
    
    uint256 public constant FAUCET_AMOUNT = 10 * 10**18; // 10 tokens per claim
    uint256 public constant COOLDOWN_TIME = 24 hours;
    uint256 public constant MAX_CLAIM_AMOUNT = 500 * 10**18; // 500 tokens lifetime limit
    
    mapping(address => uint256) public lastClaimAt;
    mapping(address => uint256) public totalClaimed;
    
    bool public paused = false;
    
    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event FaucetPaused(bool paused);
    
    constructor(address tokenAddress) {
        tokenContract = Token(tokenAddress);
        admin = msg.sender;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    modifier notPaused() {
        require(!paused, "Faucet is paused");
        _;
    }
    
    function requestTokens() public nonReentrant notPaused {
        require(canClaim(msg.sender), "You cannot claim tokens at this time");
        require(remainingAllowance(msg.sender) >= FAUCET_AMOUNT, "Insufficient remaining allowance");
        
        // Update state
        lastClaimAt[msg.sender] = block.timestamp;
        totalClaimed[msg.sender] += FAUCET_AMOUNT;
        
        // Mint tokens
        tokenContract.mint(msg.sender, FAUCET_AMOUNT);
        
        emit TokensClaimed(msg.sender, FAUCET_AMOUNT, block.timestamp);
    }
    
    function canClaim(address user) public view returns (bool) {
        if (paused) return false;
        if (block.timestamp < lastClaimAt[user] + COOLDOWN_TIME) return false;
        if (totalClaimed[user] >= MAX_CLAIM_AMOUNT) return false;
        return true;
    }
    
    function remainingAllowance(address user) public view returns (uint256) {
        uint256 remaining = MAX_CLAIM_AMOUNT - totalClaimed[user];
        return remaining > 0 ? remaining : 0;
    }
    
    function isPaused() public view returns (bool) {
        return paused;
    }
    
    function setPaused(bool _paused) public onlyAdmin {
        paused = _paused;
        emit FaucetPaused(_paused);
    }
}
