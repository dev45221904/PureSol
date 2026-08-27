// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; 

contract pricegetter{
    function getprice() public view returns(uint256){
        AggregatorV3Interface price = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 answer,,,) = price.latestRoundData();
       uint256 main =   uint256 (answer * 1e18);
       return main;
    }

    function convert(uint256 EThAmount) external view returns(uint256)  {
       uint256 converter = getprice();
       uint256 InUSD = (EThAmount * converter)/1e26;
       return InUSD;
    }
}