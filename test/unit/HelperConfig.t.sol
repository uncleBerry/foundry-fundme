// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract HelperConfigTest is Test {
    HelperConfig public helperConfig;

    //Definisikan variable konstanta untuk chianID
    uint256 constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ANVIL_CHAIN_ID = 31337;

    //Expected values untuk Sepolia
    address constant SEPOLIA_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function setUp() public {}

    // Test case 1: Deploy di Sepolia (chain ID 11155111)
    function test_ConstructorOnSepolia() public {
        // set chainid ke sepolia
        vm.chainId(SEPOLIA_CHAIN_ID);

        // Deploy contract
        helperConfig = new HelperConfig();

        // Ambil configurasi aktif
        address priceFeed = helperConfig.activeNetworkConfig();

        // Verifikasi hasil
        assertEq(priceFeed, SEPOLIA_PRICE_FEED, "priceFeed should match Sepolia config");
    }

    // Test case 2: Deploy di Anvil (Chain ID 31337)
    function test_ConstructorOnAnvil() public {
        if (address(helperConfig) != address(0)) {
            assertEq(
                helperConfig.activeNetworkConfig(), helperConfig.anvilConfig(), "priceFeed should match Anvil config"
            );
            console.log("Contract sudah di deploy");
        }
        vm.chainId(ANVIL_CHAIN_ID);

        // Deploy contract
        helperConfig = new HelperConfig();

        // Ambil configurasi aktif
        address priceFeed = helperConfig.activeNetworkConfig();

        // Verifikasi result
        assertEq(priceFeed, helperConfig.anvilConfig(), "priceFeed should match Anvil config");
    }

    function testViewSlotStorage() public view {
        for(uint256 i = 0; i < 5; i++){
            bytes32 value = vm.load(address(this), bytes32(i));
            console.log("Value at slot:", i);
            console.logBytes32(value);
        }
        console.log("PriceFeed address :", SEPOLIA_PRICE_FEED);
    }
}
