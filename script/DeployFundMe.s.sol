// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        vm.startBroadcast(); // Memulai broadcast transaksi
        address PriceFeed = vm.envAddress("SEPOLIA_PRICE_FEED");
        FundMe fundMe = new FundMe(PriceFeed); // Membuat instance dari kontrak FundMe
        vm.stopBroadcast(); // Mengakhiri broadcast
        return fundMe;
    }
}
