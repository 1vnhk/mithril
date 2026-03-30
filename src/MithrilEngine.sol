// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Mithril} from "src/Mithril.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title MithrilEngine
/// @author Ivan Hrekov (1vnhk)
/// The system is designed to be as minimal as possible.
/// It should maintain the peg where 1 token (MTRL) is worth 1 USD.
/// Stablecoin properties:
/// - Exogenous collateral (ETH & BTC)
/// - Algorithmic minting
/// - Dollar pegged
/// It is similar to DAI if DAI had no governance, no fees, and backed only by wBTC and wETH.
/// Our system should always be "overcollateralized." At no point, the value of all collateral <= $ backed value of all MTRL.
/// @notice This is the core of the Mithril system. It handles all logic for minting and redeeming MTRL, as well as
/// depositing and withdrawing collateral.
/// @notice This contract is loosely based on DAI.
contract MithrilEngine is ReentrancyGuard {
    using SafeERC20 for IERC20;

    error MithrilEngine__MustBeMoreThanZero();
    error MithrilEngine__TokenAddressesAndPriceFeedAddressesShouldBeSameLength();
    error MithrilEngine__NotAllowedCollateral();
    error MithrilEngine__TransferFailed();

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    Mithril private immutable i_mithril;

    event CollateralDeposited(address indexed user, address indexed collateral, uint256 amount);

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert MithrilEngine__MustBeMoreThanZero();
        }
        _;
    }

    modifier isAllowedCollateral(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert MithrilEngine__NotAllowedCollateral();
        }
        _;
    }

    constructor(address[] memory tokenCollaterals, address[] memory priceFeedAddresses, address mithrilToken) {
        if (tokenCollaterals.length != priceFeedAddresses.length) {
            revert MithrilEngine__TokenAddressesAndPriceFeedAddressesShouldBeSameLength();
        }
        // NOTE: this depends on the exact ordering in 2 different arrays. Not safe - rewrite
        for (uint256 i = 0; i < tokenCollaterals.length; i++) {
            s_priceFeeds[tokenCollaterals[i]] = priceFeedAddresses[i];
        }

        i_mithril = Mithril(mithrilToken);
    }

    function depositCollateralAndMintMtrl() external {}

    /// @notice follows CEI
    /// @param tokenCollateral - the address of the token to deposit a collateral
    /// @param amount - the amount of collateral to deposit
    function depositCollateral(address tokenCollateral, uint256 amount)
        external
        moreThanZero(amount)
        isAllowedCollateral(tokenCollateral)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateral] += amount;

        emit CollateralDeposited(msg.sender, tokenCollateral, amount);

        IERC20(tokenCollateral).safeTransferFrom(msg.sender, address(this), amount);
    }

    function redeemCollateralForMtrl() external {}

    function redeemCollateral() external {}

    function mintMtrl() external {}

    function burnMtrl() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
