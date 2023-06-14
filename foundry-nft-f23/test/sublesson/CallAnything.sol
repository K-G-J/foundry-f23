// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";

// Encode Function Selector: encode first 4 bytes of function signature
// Get encode of function paramenters: abi.encode

contract CallAnything is Test {
    address public s_someAddress;
    uint256 public s_amount;

    function transfer(address someAddress, uint256 amount) public {
        s_someAddress = someAddress;
        s_amount = amount;
    }

    function getSelectorOne() public pure returns (bytes4 selector) {
        selector = bytes4(keccak256(bytes("transfer(address,uint256)")));
    }

    function getDataToCallTransfer(address someAddress, uint256 amount) public pure returns (bytes memory) {
        return abi.encodeWithSelector(getSelectorOne(), someAddress, amount);
    }

    function callTransferFunctionDirectly(address someAddress, uint256 amount) public returns (bytes4, bool) {
        // could be any address
        (bool success, bytes memory returnData) =
            address(this).call(abi.encodeWithSelector(getSelectorOne(), someAddress, amount));
        return (bytes4(returnData), success);
    }

    function callTransferFunctionDirectlySig(address someAddress, uint256 amount) public returns (bytes4, bool) {
        (bool success, bytes memory returnData) =
            address(this).call(abi.encodeWithSignature("transfer(address,uint256)", someAddress, amount));
        return (bytes4(returnData), success);
    }
}
