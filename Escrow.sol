// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.35;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
 
contract Escrow{

    using SafeERC20 for IERC20;

    enum Phases{Waiting, Funded, Complete}

    address public immutable buyer;
    address public immutable seller;

    uint256 public immutable amount;

    IERC20 public immutable token;

    Phases public phase;

    error ZeroAddr();
    error ZeroAmt();
    error NotOwner();

    constructor(address _buyer, address _token, uint256 _amount){
        if(_buyer == address(0) || _token == address(0)) revert ZeroAddr();
        if(_amount == 0) revert ZeroAmt();
        if(_buyer == msg.sender) revert NotOwner();

        seller = msg.sender;
        token = IERC20(_token);
        amount = _amount;
        buyer = _buyer;
    }

    modifier OnlyBuyer {
        require(buyer == msg.sender, "Not a buyer");
        _;
    }
    error WrongPhase();
    event Funded(address indexed from, uint256 value);

    function deposit() external OnlyBuyer{
        if(phase != Phases.Waiting) revert WrongPhase();
        phase = Phases.Funded;
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit Funded(msg.sender, amount);
    }

    event Given(address indexed to, uint256 value);

    function releaseFunds() external OnlyBuyer{
        if(phase != Phases.Funded) revert WrongPhase();
        phase = Phases.Complete;
        token.safeTransfer(seller, amount);

        emit Given(seller, amount);
    }

    modifier OnlySeller{
        require(msg.sender == seller, "Only Seller");
        _;
    }

    function refund() external OnlySeller{
        if(phase != Phases.Funded) revert WrongPhase();
        phase = Phases.Complete;
        token.safeTransfer(buyer, amount);

        emit Given(buyer, amount);
    }
}