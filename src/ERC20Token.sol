// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

error ERC20Token__BalanceMisMatch();

 contract ERC20Token {

event Transfer(address indexed _from, address indexed _to, uint256 _value)
event Approval(address indexed _owner, address indexed _spender, uint256 _value)


    mapping(address => uint256) private s_balances;


    function name() public pure returns(string memory) {
        return "NomadCrisis";
    }

    function totalSupply() public pure returns(uint256) {
        return 100 ether; // 100 * 10^18
    }

    function decimal() public pure returns(uint8) {
        return 18;
    }

    function balanceOf(address) public view returns(uint256) {
        return s_balances[msg.sender];
    }

    function transfer(address _to, uint256 amount) public returns(bool success) {
        uint256 previousBalances = balanceOf(msg.sender) + balanceOf(_to);
        s_balances[msg.sender] -= amount;
        s_balances[_to] += amount;

        if(previousBalances != balanceOf(msg.sender) + balanceOf(_to)) {
            revert ERC20Token__BalanceMisMatch();
        }

        success = true;

        return success;

      }

    function transferFrom(address _from, address _to, uint256 amount) public view returns(bool success) {

    }


 }
