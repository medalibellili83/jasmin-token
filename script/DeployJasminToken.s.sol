// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {JasminToken} from "../src/JasminToken.sol";

/// @notice Déploie le Jasmin Token. Celui qui lance le script reçoit tous les tokens.
contract DeployJasminToken is Script {
    uint256 constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million de JSM

    function run() external returns (JasminToken token) {
        vm.startBroadcast();
        token = new JasminToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        console.log("JasminToken deployed at:", address(token));
    }
}
