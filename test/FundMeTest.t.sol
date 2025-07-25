// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

error NotEnoughFunds();
contract FundMeTest is Test {
    FundMe public fundMe;

    // Function untuk membuat instance contract FundMe
    function setUp() public{
      fundMe = new FundMe();
    }

    // Function untuk tes nilai varaible MINIMUM_USD sama dengan 5e18/5 USD
    function testMinimumFiveUSD() public view{
        assertEq(fundMe.MINIMUM_USD(), 5e18);     // Apakah varaible MINIMUM_USD sama dengan 5e18/5 USD
        console.log("Variable MINIMUM_USD bernilai", fundMe.MINIMUM_USD());
    }

    // Function untuk tes apakah owner (pemiliki contract) 
    function testOwnerIsMsgSender() public view {
      assertEq(fundMe.i_owner(), address(this));
      console.log(fundMe.i_owner());
    }

    // Function untuk test atau memastikan versi priceFeed sama dengan 4
    function testPriceFeedVersionIsAccurate() public view{
      uint256 version = fundMe.getVersion();
      assertEq(version, 4);
    }

    function testFundSuccess() public {
      address userTest = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
      vm.deal(userTest, 1 ether);
      vm.prank(userTest);
      fundMe.fund{value: 0.0016 ether}();

      assertEq(fundMe.funders(0), userTest);
      assertEq(fundMe.fundersLength(), 1);
      assertEq(fundMe.addressAmountFunded(userTest), 0.0016 ether);
    }

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

//     function testWithdrawOnlyOwner() public {
//       address userAccount = address(this);
//       vm.prank(userAccount);
//       fundMe.withdraw();
//       assertEq(fundMe.i_owner(), userAccount);
//     }
}