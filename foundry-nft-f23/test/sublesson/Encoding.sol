// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";

contract Encoding is Test {
    function combineStrings() public pure returns (string memory) {
        return string(abi.encodePacked("Hi Mom ", "Miss you!"));
    }

    function encodeNumber() public pure returns (bytes memory) {
        bytes memory number = abi.encode(1);
        return number;
    }

    function encodeString() public pure returns (bytes memory) {
        bytes memory str = abi.encode("Hello World");
        return str;
    }

    function encodeStringPacked() public pure returns (bytes memory) {
        bytes memory str = abi.encodePacked("Hello World");
        return str;
    }

    function encodeStringBytes() public pure returns (bytes memory) {
        bytes memory str = bytes("Hello World");
        return str;
    }

    function decodeString() public pure returns (string memory) {
        // provide what to decode and what type to decode to
        string memory str = abi.decode(encodeString(), (string));
        return str;
    }

    function multiEncode() public pure returns (bytes memory) {
        bytes memory str = abi.encode("Hello World ", "I am here!");
        return str;
    }

    function multiDecode() public pure returns (string memory, string memory) {
        (string memory str1, string memory str2) = abi.decode(multiEncode(), (string, string));
        return (str1, str2);
    }

    function multiEncodePacked() public pure returns (bytes memory) {
        bytes memory str = abi.encodePacked("Hello World ", "I am here!");
        return str;
    }

    // NOTE: this will not work!
    function multiDecodePacked() public pure returns (string memory, string memory) {
        (string memory str1, string memory str2) = abi.decode(multiEncodePacked(), (string, string));
        return (str1, str2);
    }

    function mutliStringCastPacked() public pure returns (string memory) {
        string memory str = string(multiEncodePacked());
        return str;
    }

    function test() public view {
        // console.log(combineStrings());
        // console.logBytes(encodeNumber());
        // console.logBytes(encodeString());
        // console.logBytes(encodeStringPacked());
        // console.logBytes(encodeStringBytes());
        // console.log(decodeString());
        // console.logBytes(multiEncode());
    }
}
