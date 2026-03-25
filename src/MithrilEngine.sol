// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

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
contract MithrilEngine {
    error MithrilEngine__MustBeMoreThanZero();

    mapping(address token => address priceFeed) private s_priceFeeds;

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert MithrilEngine__MustBeMoreThanZero();
        }
        _;
    }

    // modifier isAllowedCollateral(address token) {

    // }

    constructor() {}

    function depositCollateralAndMintMtrl() external {}

    /// @param tokenCollateral - the address of the token to deposit a collateral
    /// @param amount - the amount of collateral to deposit
    function depositCollateral(address tokenCollateral, uint256 amount) external moreThanZero(amount) {}

    function redeemCollateralForMtrl() external {}

    function redeemCollateral() external {}

    function mintMtrl() external {}

    function burnMtrl() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
