// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract FundMe {
    function fund() public payable {
        require(msg.value > 1e18, "didn't sent enough ETH");
    }

    // function withdraw() public {}
}