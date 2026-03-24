// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {Mithril} from "src/Mithril.sol";
import {DeployMithril} from "script/DeployMithril.s.sol";

contract MithrilTest is Test {
    Mithril mithril;

    address MINTER = makeAddr("minter");

    function setUp() public {
        DeployMithril deployer = new DeployMithril();
        mithril = deployer.deployMithril();
        
        // TODO: perform any addition actions
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
        mithril.mint(MINTER, 0);
    }
}
