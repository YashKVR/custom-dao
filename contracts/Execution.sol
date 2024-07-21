// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Execution {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transferBudgetToOwner() external {}

    function setASampleNumber() external {}
}
