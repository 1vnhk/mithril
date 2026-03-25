// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Mithril} from "src/Mithril.sol";
import {DeployMithril} from "script/DeployMithril.s.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MithrilTest is Test {
    Mithril mithril;

    address USER = makeAddr("user");

    address i_owner;
    
    function setUp() public {
        DeployMithril deployer = new DeployMithril();
        mithril = deployer.deployMithril();
        
        i_owner = mithril.owner();
    }

    /*//////////////////////////////////////////////////////////////
                               ONLY OWNER
    //////////////////////////////////////////////////////////////*/
    function testOnlyOwnerCanMint() public {
        vm.prank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER)
        );
        mithril.mint(USER, 1);
    }

    function testOnlyOwnerCanBurn() public {
        vm.prank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER)
        );
        mithril.burn(1);
    }

    /*//////////////////////////////////////////////////////////////
                                  MINT
    //////////////////////////////////////////////////////////////*/
    modifier owner() {
        vm.prank(mithril.owner());
        _;
    }

    function testMintRevertsIfAmountIsZero() public owner {
        vm.expectRevert(Mithril.Mithril__MustBeMoreThanZero.selector);
        mithril.mint(USER, 0);
    }
    
    function testMintMintsCorrectAmount() public {
        vm.startPrank(i_owner);
        uint256 mintAmount = 10;

        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(address(0), USER, mintAmount);

        bool result = mithril.mint(USER, mintAmount);

        assertEq(result, true);
        assertEq(mithril.balanceOf(USER), mintAmount);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                                  BURN
    //////////////////////////////////////////////////////////////*/
    function testBurnRevertsIfAmountIsZero() public owner {
        vm.expectRevert(Mithril.Mithril__MustBeMoreThanZero.selector);
        mithril.burn(0);
    }

    function testBurnCallsERC20BurnableBurn() public {
        vm.startPrank(i_owner);
        uint256 burnAmount = 10;

        mithril.mint(i_owner, burnAmount);

        vm.expectEmit(true, true, false, true);
        emit IERC20.Transfer(i_owner, address(0), burnAmount);

        mithril.burn(burnAmount);
        assertEq(mithril.balanceOf(i_owner), 0);
        vm.stopPrank();
    }
}
