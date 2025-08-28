// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";

error NotEnoughFunds();

contract FundMeTest is Test {
    DeployFundMe deployFundMe;
    FundMe public fundMe;

    uint256 constant PRICE_FEED_VERSION = 4;
    uint256 constant DECIMAL = 8;
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant GAS_PRICE = 5 gwei;

    // Function untuk membuat instance contract FundMe
    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    // Function untuk tes nilai varaible MINIMUM_USD sama dengan 5e18/5 USD
    function testMinimumFiveUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18,"Not Enough Eth!"); // Apakah varaible MINIMUM_USD sama dengan 5e18/5 USD
    }

    // Function untuk tes apakah owner (pemiliki contract)
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // Function untuk test atau memastikan versi priceFeed sama dengan 4
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, PRICE_FEED_VERSION);
    }

    function testGetDecimal() public view {
        uint256 decimal = fundMe.getDecimals();
        assertEq(decimal, DECIMAL);
    }

    // Function untuk test mengirim eth mengggunakan function fund()
    function testFundSuccess() public {
        address userTest = makeAddr("userTest"); // address user
        vm.deal(userTest, 1 ether); // Memberikan 1 eth kedalam address user
        vm.prank(userTest); // Jadikan address user yang memamgil function
        fundMe.fund{value: 0.0016 ether}(); // Panggil function fund() dan mengirimkan eth ke function fund()

        assertEq(fundMe.getFunders(0), userTest); // mamastikan array dengan index 0 berisi address user
        assertEq(fundMe.fundersLength(), 1); // Memastikan panjang array sama dengan 1
        assertEq(fundMe.getaddressToAmountFunded(userTest), 0.0016 ether); // memastikan address user berisi eth sebanyak ...
    }

    // Function untuk melakukan test mengirim eth mengggunakan function fund() namun dengan sedikit eth
    function testFundFailed() public {
        address userTest = makeAddr("userTest");
        vm.deal(userTest, 1 ether);
        vm.prank(userTest);

        // Harapkan transaksi revert dengan error NotEnoughFunds
        vm.expectRevert(NotEnoughFunds.selector);
        fundMe.fund{value: 0.0011 ether}();

        // Verifikasi bahwa array funders tetap kosong
        assertEq(fundMe.fundersLength(), 0);
    }

    function testWithdrawOnlyOwner() public {
        address ownerContract = msg.sender; //simpan msg.sender sebagai ownerContract
        vm.deal(ownerContract, 2 ether); //berikan eth ke alamt ownerAccount

        vm.startPrank(ownerContract); //jadikan ownerContract yang memangil function fund() & withdraw()
        fundMe.fund{value: 1 ether}(); //panggil function fund() dan kirim 1 eth
        fundMe.withdraw(); //panggil function withdraw untuk menarik saldo/eth
        vm.stopPrank();

        assertEq(fundMe.i_owner(), ownerContract); //verifikasi apakah alamat owner == ownerContract
    }

    function testWithDrawOtherPeople() public {
        address Marlon = makeAddr("Marlon"); //membuat address buatan 

        vm.expectRevert(); //kita prediksi kalo transaksi ini akan gagal
        vm.prank(Marlon); //kita jadikan marlon yang memangil function withdraw()
        fundMe.withdraw(); //panggil function withdraw()
    }

    // function test untuk cek apakah eth yang dikirim user sudah masuk ke mapping
    function testCekDataFund() public {
        address ucok = makeAddr("ucok"); // no vm.

        vm.deal(ucok, 1 ether);

        // simulasikan ucok memangil function
        vm.prank(ucok);

        //panggil function fund()
        fundMe.fund{value: 1 ether}();

        uint256 alamatUcok = fundMe.getaddressToAmountFunded(ucok);

        assertEq(alamatUcok, 1 ether, "ethereum belum masuk");
    }

    // Apakah array funders (funders[]) terisi dengan alamat pengirim (msg.sender) saat orang melakukan fund()?
    function testAddsFunderToArrayOfFunders() public {
        address Alice = makeAddr("Alice");
        vm.deal(Alice, 5 ether);

        vm.prank(Alice);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        assertEq(funder, Alice);
    }

    // Apakah fungsi withdraw hanya bisa dipanggil oleh pemilik kontrak?
    function testWithdrawNonOwner() public {
        address Adit = makeAddr("Adit");
        vm.deal(Adit, 5 ether);

        vm.startPrank(Adit);
        fundMe.fund{value: SEND_VALUE}();
        vm.expectRevert();
        fundMe.withdraw();
        vm.stopPrank();
        
    }

    //Mengetes Withdraw oleh Owner (Single Funder) use method AAA
    function testWithdrawFromASingleFunder() public {

        // Arrange atau mengatur
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Act or bertindak
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert or menegaskan
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function test_WithdrawFromMultipleFunders() public {
        uint160 funderGrup = 100;

        for(uint160 i = 1; i < funderGrup; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

       uint256 startingFundMeBlanace = address(fundMe).balance;
       uint256 startingOwnerBalance = fundMe.getOwner().balance;

       vm.startPrank(fundMe.getOwner());
       fundMe.withdraw();
       vm.stopPrank();

       assert(address(fundMe).balance == 0);
       assert(startingFundMeBlanace + startingOwnerBalance == fundMe.getOwner().balance);

    }

    function test_CheeperWithdrawFromMultipleFunders() public {
        uint160 funderGrup = 100;

        for(uint160 i = 1; i < funderGrup; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

       uint256 startingFundMeBlanace = address(fundMe).balance;
       uint256 startingOwnerBalance = fundMe.getOwner().balance;

       vm.startPrank(fundMe.getOwner());
       fundMe.withdrawCheeper();
       vm.stopPrank();

       assert(address(fundMe).balance == 0);
       assert(startingFundMeBlanace + startingOwnerBalance == fundMe.getOwner().balance);

    }

    function test_GetOwnerAddress() public view{
        address ownerAddress = fundMe.getOwner();
        assertEq(ownerAddress, msg.sender);   
    }

   function testViewStorageSlot() public view {
    for(uint256 i = 0; i < 4; i++){
        bytes32 value = vm.load(address(fundMe), bytes32(i));
        console.log("The slot is", i);
        console.logBytes32(value);
    }
    console.log("PriceFeed address :", address(fundMe.getPriceFeedAddress()));
   }
    
}