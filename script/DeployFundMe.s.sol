// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    HelperConfig helperConfig = new HelperConfig();
    

    function run() external returns (FundMe) {
        vm.startBroadcast();

        FundMe fundMe = new FundMe(helperConfig.activeNetworkConfig());

        vm.stopBroadcast();
        return fundMe;
    }
}
