// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// @title Mithril (Decentralized Stable Coin)
// @author Ivan Hrekov (1vnhk)
// Collateral: Exogenous (ETH & BTC)
// Minting: Algorithmic
// Relative Stability: Pegged to USD
// This is the contract meant to be governed by MithrilEngine.
// This contract is just the ERC20 implementation of the stablecoin system.
contract Mithril is ERC20Burnable, Ownable {
    error Mithril__MustBeMoreThanZero();
    error Mithril__BurnAmountExceedsBalance();
    error Mithril__NotZeroAddress();

    constructor() ERC20("Mithril", "MTRL") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner {
        require(_amount > 0, Mithril__MustBeMoreThanZero());

        uint256 balance = balanceOf(msg.sender);
        require(balance >= _amount, Mithril__BurnAmountExceedsBalance());

        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        require(_to != address(0), Mithril__NotZeroAddress());
        require(_amount > 0, Mithril__MustBeMoreThanZero());

        _mint(_to, _amount);

        return true;
    }
}
