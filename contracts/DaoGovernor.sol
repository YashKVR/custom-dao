// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IDaoContract {
    function addAdmins(address[] memory _admins) external;
}

contract DaoGovernor {
    IDaoContract public daoContract;
    address public daoContractAddress;

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

    function setDaoContract(address _daoContractAddress) external onlyOwner {
        daoContractAddress = _daoContractAddress;
        daoContract = IDaoContract(daoContractAddress);
    }

    function addDaoAdmins(address[] memory _admins) external onlyOwner {
        daoContract.addAdmins(_admins);
    }
}
