// SPDX-License-Identifier: MIT

pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {Mithril} from "src/Mithril.sol";

contract DeployMithril is Script {
    function run() public {
        deployMithril();
    }

    function deployMithril() public returns (Mithril) {
        vm.startBroadcast();
        Mithril mithril = new Mithril();
        vm.stopBroadcast();

        return mithril;
    }
}
