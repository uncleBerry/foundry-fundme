// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {FundMe} from "../src/FundMe.sol";

error NotEnoughFunds();

contract FundMeTest is Test {

    DeployFundMe deployFundMe;

    FundMe public fundMe;

    // Function untuk membuat instance contract FundMe
    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    // Function untuk tes nilai varaible MINIMUM_USD sama dengan 5e18/5 USD
    function testMinimumFiveUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // Apakah varaible MINIMUM_USD sama dengan 5e18/5 USD
        console.log("Variable MINIMUM_USD bernilai", fundMe.MINIMUM_USD());
    }

    // Function untuk tes apakah owner (pemiliki contract)
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // Function untuk test atau memastikan versi priceFeed sama dengan 4
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    // Function untuk test mengirim eth mengggunakan function fund()
    function testFundSuccess() public {
        address userTest = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // address user
        vm.deal(userTest, 1 ether); // Memberikan 1 eth kedalam address user
        vm.prank(userTest); // Jadikan address user yang memamgil function
        fundMe.fund{value: 0.0016 ether}(); // Panggil function fund() dan mengirimkan eth ke function fund()

        assertEq(fundMe.funders(0), userTest); // mamastikan array dengan index 0 berisi address user
        assertEq(fundMe.fundersLength(), 1); // Memastikan panjang array sama dengan 1
        assertEq(fundMe.addressAmountFunded(userTest), 0.0016 ether); // memastikan address user berisi eth sebanyak ...
    }

    // Function untuk melakukan test mengirim eth mengggunakan function fund() namun dengan sedikit eth
    function testFundFailed() public {
        address userTest = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        vm.deal(userTest, 1 ether);
        vm.prank(userTest);

        // Harapkan transaksi revert dengan error NotEnoughFunds
        vm.expectRevert(NotEnoughFunds.selector);
        fundMe.fund{value: 0.0011 ether}();

        // Verifikasi bahwa array funders tetap kosong
        assertEq(fundMe.fundersLength(), 0);
    }

        function testWithdrawOnlyOwner() public {
          address userAccount = msg.sender;
          vm.prank(userAccount);
          fundMe.withdraw();
          assertEq(fundMe.i_owner(), userAccount);
        }

        function testWithDrawOtherPeople() public {
            address userAccount = address(this);
            vm.prank(userAccount);
            fundMe.fund{value: 1 ether}();

            vm.expectRevert();
            fundMe.withdraw();
            console.log(userAccount);
            console.log(msg.sender);
        }
}
