// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.35;

import {ERC20} from "@openzepplin/contracts/token/ERC20/ERC20.sol";

contract token is ERC20{
    constructor(uint256 supply) ERC20("REDJOHN", "RED"){
        _mint(msg.sender, supply);
    }
}