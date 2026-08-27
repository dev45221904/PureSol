// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {pricegetter} from "./price.sol";

contract Funder is pricegetter {
    address immutable owner;

    constructor() {
        owner = msg.sender;
    }

    event log(address from, address to, uint256 amount);

    function store() public payable {}

    function showbal() public view returns (uint256) {
        return address(this).balance;
    }

    function sendEth(address payable _to, uint256 _amount) public {
        require(msg.sender == owner, "Not owner");
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
        emit log(msg.sender, _to, _amount);
    }
}