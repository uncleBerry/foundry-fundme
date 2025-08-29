// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/InteractionScript.s.sol";

contract IntergartionTest is Test {
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_USER_BALANCE = 10 ether;
    FundMe fundMe;
    address Alice = makeAddr("Alice");

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(Alice, STARTING_USER_BALANCE);
    }

    function test_UserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(Alice).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(Alice);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(Alice).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
