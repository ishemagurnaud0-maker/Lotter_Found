//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


import {ERC20} from "@solmate/tokens/ERC20.sol";

interface ERC677Receiver {
    function onTokenTransfer(address sender, uint256 value, bytes calldata data) external returns (bool success);
}

contract LinkToken is ERC20 {

    uint256 constant INITIAL_SUPPLY = 10**27; 
    uint8 constant DECIMALS = 18;

    constructor() ERC20("ChainLink Token", "LINK", 18) {
        _mint(msg.sender, 1000000 ether);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success) {
        super.transfer(to, value);
        if (isContract(to)) {
            success = contractFallback(to, value, data);
        } else {
            success = true;
        }
    }

    function contractFallback(address to, uint256 value, bytes calldata data) internal returns (bool success) {
        ERC677Receiver receiver = ERC677Receiver(to);
        success = receiver.onTokenTransfer(msg.sender, value, data);
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

}