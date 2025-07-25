// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";


contract DeployFundMe is Script {
   function run() external returns (FundMe) {
        vm.startBroadcast();       // Memulai broadcast transaksi
        FundMe fundMe = new FundMe();              // Membuat instance dari kontrak FundMe
        vm.stopBroadcast();        // Mengakhiri broadcast
        return fundMe;
    }
}
