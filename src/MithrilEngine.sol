// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Mithril} from "src/Mithril.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

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
    error MithrilEngine__BreaksHealthFactor(uint256 healthFactor);

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50; // 200% overcollateralized
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1;

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountMtrlMinted) private s_mtrlMinted;
    address[] private s_collateralTokens;

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
            s_collateralTokens.push(tokenCollaterals[i]);
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

    /// @notice follows CEI
    /// @param amountToMint - the amount of Mithril token to mint
    /// @notice minted tokens must have more collateral value than the minimum threshold
    function mintMtrl(uint256 amountToMint) external moreThanZero(amountToMint) nonReentrant {
        s_mtrlMinted[msg.sender] += amountToMint;

        _revertIfHealthFactorIsBroken(msg.sender);

        // emit event

        // transfer tokens
    }

    function burnMtrl() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}

    // Q: why not private/internal. when to use which?
    function _getAccountInformation(address user) private view returns (uint256 totalMtrlMinted, uint256 collateralValueInUSD) {
        totalMtrlMinted = s_mtrlMinted[user];
        collateralValueInUSD = getAccountCollateralValue(user);
    }

    /// @return uint256 how close to liquidation a user is
    /// if a user goes below 1, then they can get liquidated
    function _healthFactor(address user) internal view returns (uint256) {
        // 1. Get total collateral
        // 2. Get total MTRL minted
        (uint256 totalMtrlMinted, uint256 collateralValueInUSD) = _getAccountInformation(user);
        // 1000 ETH * 50 / 100 = 50,000 / 100 = 500
        uint256 collateralAdjustedForThreshold = (collateralValueInUSD * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totalMtrlMinted;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        uint256 healthFactor = _healthFactor(user);
        if (healthFactor < MIN_HEALTH_FACTOR) {
            revert MithrilEngine__BreaksHealthFactor(healthFactor);
        }
    }

    function getAccountCollateralValue(address user) public view returns (uint256 collateralValueInUSD) {
        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[msg.sender][token];

            collateralValueInUSD += getUsdValue(token, amount);
        }
        return collateralValueInUSD;
    }

    // TODO: tests
    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface feed = AggregatorV3Interface(s_priceFeeds[token]);
        (,int256 price,,,) = feed.latestRoundData();

        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    } 
}
