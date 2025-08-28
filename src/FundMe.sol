// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {AggregatorV3Interface} from "@chainlink/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotEnoughFunds();
error OnlyOwner();
error TransferFailed();

contract FundMe {

    //=================
    // STATE VARIABLES
    //=================
    
    uint256 public constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;
    address[] private s_funders;
    address public i_owner;
    mapping(address funder => uint256 amount) private s_addressAmountFunded;

    //=================
    // CONSTRUCTORS
    //=================
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    //=================
    // MODIFIERS
    //=================
    modifier _onlyowner() {
        if (msg.sender != i_owner) revert OnlyOwner();
        _;
    }

    //=================
    // VIEW/PUBLIC FUNCTIONS
    //=================
    function getaddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressAmountFunded[fundingAddress];
    }

    // Getter function s_funders
    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function fundersLength() public view returns (uint256) {
        return s_funders.length;
    }

    function getDecimals() public view returns (uint256) {
        return s_priceFeed.decimals();
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getOwner() public view returns (address){
        return i_owner;
    }

    function fund() public payable {
        if (PriceConverter.getConversionRate(s_priceFeed, msg.value) < MINIMUM_USD) {
            revert NotEnoughFunds();
        }
        s_funders.push(msg.sender); //
        s_addressAmountFunded[msg.sender] += msg.value;
    }

    function getPriceFeedAddress() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
    //=================
    // OWNER FUNCTIONS
    //=================
    function withdrawCheeper() public _onlyowner {  
        uint256 funder = s_funders.length;
        for(uint256 indexArray = 1; indexArray < funder; indexArray++) {
            address funders = s_funders[indexArray];
            s_addressAmountFunded[funders] = 0;
        }
        s_funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) revert TransferFailed();
    }

     function withdraw() public _onlyowner {  
        for(uint256 indexArray = 1; indexArray < s_funders.length; indexArray++) {
            address funder = s_funders[indexArray];
            s_addressAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) revert TransferFailed();
    }
    //=================
    // FALLBACK & RCIEVE
    //=================
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
