// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "./base64.sol";

contract Base64Encoder {
    function encodeToBase64(string memory text) public pure returns (string memory) {
         bytes memory data = bytes(text);
        return Base64.encode(data);
    }
}
