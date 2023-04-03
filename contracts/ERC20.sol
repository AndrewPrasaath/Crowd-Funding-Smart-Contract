// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

error ERC20__ZeroAddress();
error ERC20__InsufficientBalance(uint256 _balance);
error ERC20__InsufficientAllowance(uint256 _allownace);

/**
 * @title ERC20 Token
 * @author Andrew Prasaath
 * @notice This is simple ERC20 Token contract with mandate checks
 */
contract ERC20 {
    // State variables
    string public name = "METACRAFTERS CROWD FUND";
    string public symbol = "MCF";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
    event Mint(address indexed _from, uint256 _amount);
    event Burn(address indexed _from, uint256 _amount);

    // modular func to transfer tokens from on address to another
    function _transfer(address _from, address _to, uint256 _amount) internal {
        uint balance = balanceOf[_from];
        if(_to == address(0)) {
            revert ERC20__ZeroAddress();
        }
        if(balance < _amount){
            revert ERC20__InsufficientBalance(balance);
        }
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_from, _to, _amount);
    }

    // actual transfer functon
    function transfer(address _to, uint256 _amount) public returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        uint allowanceOfSender = allowance[_from][msg.sender];
        if(_amount > allowanceOfSender) {
            revert ERC20__InsufficientAllowance(allowanceOfSender);
        }
        allowance[_from][msg.sender] -= _amount;
        _transfer(_from, _to, _amount);
        return true;
    }

    function mint(uint _amount) public {
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
        emit Mint(msg.sender, _amount);
    }

    function burn(uint _amount) public {
        uint balance = balanceOf[msg.sender];
        if(balance < _amount){
            revert ERC20__InsufficientBalance(balance);
        }
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        emit Burn(msg.sender, _amount);
    }
}
