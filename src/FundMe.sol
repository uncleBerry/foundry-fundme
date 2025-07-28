// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotEnoughFunds();
error OnlyOwner();
error TransferFailed();

contract FundMe {
    
    AggregatorV3Interface private s_priceFeed;

    // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;

    function fundersLength() public view returns (uint256) {
        return funders.length;
    }

    mapping(address funder => uint256 amount) public addressAmountFunded;

    address public immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier _onlyowner() {
        if (msg.sender != i_owner) revert OnlyOwner();
        _;
    }

    function fund() public payable {
        if (PriceConverter.getConversionRate(s_priceFeed, msg.value) < MINIMUM_USD) {
            revert NotEnoughFunds();
        }
        funders.push(msg.sender); //
        addressAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public _onlyowner {
        for (uint256 indexArray = 0; indexArray < funders.length; indexArray++) {
            address funder = funders[indexArray];
            addressAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) revert TransferFailed();
    }

    function getDecimals() public view returns (uint256) {
        return s_priceFeed.decimals();
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
