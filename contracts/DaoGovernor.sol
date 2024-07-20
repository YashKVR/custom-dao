// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract DaoGovernor {
    address public owner;
    address[] public admins;
    address[] public members;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }

    modifier onlyAdmin() {
        require(
            isAddressInArray(admins, msg.sender),
            "Only Admins can call this function"
        );
        _;
    }

    modifier onlyMember() {
        require(
            isAddressInArray(members, msg.sender),
            "Only Members can call this function"
        );
        _;
    }

    function isAddressInArray(
        address[] memory _array,
        address _addressToCheck
    ) public pure returns (bool) {
        for (uint i = 0; i < _array.length; i++) {
            if (_array[i] == _addressToCheck) {
                return true;
            }
        }
        return false;
    }

    function addAdmins(address[] memory _admins) public onlyOwner {
        for (uint i = 0; i < _admins.length; i++) {
            admins.push(_admins[i]);
        }
    }

    function addMembers(address[] memory _members) public onlyAdmin {
        for (uint i = 0; i < _members.length; i++) {
            members.push(_members[i]);
        }
    }

    function getAdmins() external view returns (address[] memory) {
        return admins;
    }

    function getMembers() external view returns (address[] memory) {
        return members;
    }
}
