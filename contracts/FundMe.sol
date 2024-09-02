// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner(); // Save gas since it is not a string (so array)

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    
    address public immutable i_owner;

    // Set right away when contract deployed
    constructor() {
        i_owner = msg.sender;
    } 

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't sent enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // for loop
        // for(/* starting index, ending, step amount */)
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset and withdraw
        funders = new address[](0);

        // https://solidity-by-example.org/sending-ether/
        /* Transfer */
        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);
        /* Send */
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        /* Call : RECOMMENDED WAY */
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner");
        if(msg.sender != i_owner) {
            revert NotOwner();
        }
        _; // Add the step of the function with modifier applied
        // Comeback and nothing to do
    }

    // receive() -> when a transaction is sent without data (be sure that pass by fundme function)
    receive() external payable {
        fund();
    }
    // fallback() -> transaction sent with data
    fallback() external payable {
        fund();
    }
}