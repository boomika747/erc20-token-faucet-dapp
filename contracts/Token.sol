// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18; // 1 million tokens with 18 decimals
    address public minter;

    event MinterChanged(address indexed newMinter);

    constructor(address _minter) ERC20("Faucet Token", "FCKT") {
        minter = _minter;
        _mint(msg.sender, 1000 * 10**18); // Initial mint of 1000 tokens to deployer
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Only minter can call this function");
        _;
    }

    function mint(address to, uint256 amount) public onlyMinter {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds maximum supply");
        _mint(to, amount);
    }

    function setMinter(address newMinter) public onlyOwner {
        minter = newMinter;
        emit MinterChanged(newMinter);
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
    }
}
