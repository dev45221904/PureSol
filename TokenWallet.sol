// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ERC-20 Token Wallet & Value Transfer
/// @notice Minimal ERC-20-style token implementing balanceOf, transfer, and
///         allowance-based transferFrom, with strict validation on every transfer.
contract TokenWallet {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @param _name Token name (e.g. "DecodeLabs Token")
    /// @param _symbol Token symbol (e.g. "DLT")
    /// @param _decimals Decimal precision (standard: 18)
    /// @param _initialSupply Initial supply, in whole tokens (will be scaled by decimals)
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        uint256 supply = _initialSupply * (10 ** uint256(_decimals));
        totalSupply = supply;
        balances[msg.sender] = supply;

        emit Transfer(address(0), msg.sender, supply);
    }

    /// @notice Returns the token balance of a given address. Gasless read, modifies no state.
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    /// @notice Transfers `amount` tokens from the caller to `to`.
    /// @dev Validates: non-zero recipient, non-zero amount, sufficient sender balance.
    ///      Solidity >=0.8.0 reverts automatically on underflow/overflow.
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approves `spender` to transfer up to `amount` tokens on the caller's behalf.
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "Approve to the zero address");
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Returns the remaining allowance `spender` has to transfer from `owner`.
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowances[owner][spender];
    }

    /// @notice Transfers `amount` tokens from `from` to `to`, using the caller's allowance.
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        uint256 currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");

        allowances[from][msg.sender] = currentAllowance - amount;
        _transfer(from, to, amount);
        return true;
    }

    /// @dev Core transfer logic shared by transfer() and transferFrom().
    ///      Input validation -> balance check -> state update -> event (Checks-Effects-Interactions).
    function _transfer(address from, address to, uint256 amount) internal {
        // --- Input validation (the security checkpoint) ---
        require(to != address(0), "Transfer to the zero address");
        require(from != address(0), "Transfer from the zero address");

        // --- Balance validation: cannot transfer more than current balance ---
        require(balances[from] >= amount, "Insufficient balance");

        // --- State update (Effects) ---
        balances[from] -= amount;
        balances[to] += amount;

        // --- Interactions: emit event for indexers/UI sync ---
        emit Transfer(from, to, amount);
    }
}
