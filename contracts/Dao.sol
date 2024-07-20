// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IStakingContract {
    function stakedValue(address _account) external view returns (uint256);
}

contract Dao {
    IStakingContract public stakingContract;
    address executionContractAddress;
    address public owner;
    address[] public admins;
    address[] public members;
    uint256 public nextProposal;

    constructor(
        address _stakingContractAddress,
        address _executionContractAddress
    ) {
        owner = msg.sender;
        nextProposal = 1;
        stakingContract = IStakingContract(_stakingContractAddress);
        executionContractAddress = _executionContractAddress;
    }

    struct singleChoiceProposal {
        uint256 id;
        bool exists;
        string description;
        uint256 votesUp;
        uint256 votesDown;
        mapping(address => bool) voteStatus;
        bool countConducted;
        string callData;
        bool passed;
    }

    mapping(uint256 => singleChoiceProposal) public SingleChoiceProposals;

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

    modifier onlyTokenStaker() {
        require(
            stakingContract.stakedValue(msg.sender) > 0,
            "Stake your tokens first to vote on proposals."
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

    function addAdmins(address[] memory _admins) public {
        for (uint i = 0; i < _admins.length; i++) {
            admins.push(_admins[i]);
        }
    }

    function addMembers(address[] memory _members) public {
        for (uint i = 0; i < _members.length; i++) {
            members.push(_members[i]);
        }
    }

    function createSingleChoiceProposal(
        string memory _description
    ) public onlyAdmin {
        singleChoiceProposal storage newProposal = SingleChoiceProposals[
            nextProposal
        ];
        newProposal.id = nextProposal;
        newProposal.exists = true;
        newProposal.description = _description;

        // emit proposalCreated(
        //     nextProposal,
        //     _description,
        //     _canVote.length,
        //     msg.sender
        // );
        nextProposal++;
    }

    function voteOnSingleChoiceProposal(
        uint256 _id,
        bool _vote
    ) public onlyMember onlyTokenStaker {
        require(
            SingleChoiceProposals[_id].exists,
            "This proposal does not exist."
        );
        require(
            !SingleChoiceProposals[_id].voteStatus[msg.sender],
            "You have already voted on this Proposal."
        );

        singleChoiceProposal storage p = SingleChoiceProposals[_id];

        if (_vote) {
            if (stakingContract.stakedValue(msg.sender) <= 100e8) {
                p.votesUp++;
            } else if (
                stakingContract.stakedValue(msg.sender) <= 1000e8 &&
                stakingContract.stakedValue(msg.sender) > 100e8
            ) {
                p.votesUp = p.votesUp + 10;
            } else if (
                stakingContract.stakedValue(msg.sender) <= 10000e8 &&
                stakingContract.stakedValue(msg.sender) > 1000e8
            ) {
                p.votesUp = p.votesUp + 100;
            } else {
                p.votesUp = p.votesUp + 1000;
            }
        } else {
            if (stakingContract.stakedValue(msg.sender) <= 100e8) {
                p.votesDown++;
            } else if (
                stakingContract.stakedValue(msg.sender) <= 1000e8 &&
                stakingContract.stakedValue(msg.sender) > 100e8
            ) {
                p.votesDown = p.votesDown + 10;
            } else if (
                stakingContract.stakedValue(msg.sender) <= 10000e8 &&
                stakingContract.stakedValue(msg.sender) > 1000e8
            ) {
                p.votesDown = p.votesDown + 100;
            } else {
                p.votesDown = p.votesDown + 1000;
            }
        }

        p.voteStatus[msg.sender] = true;

        // emit newVote(p.votesUp, p.votesDown, msg.sender, _id, _vote);
    }

    function countVotesOnProposal(uint256 _id) public onlyAdmin {
        require(
            SingleChoiceProposals[_id].exists,
            "This Proposal does not exist."
        );
        require(
            !SingleChoiceProposals[_id].countConducted,
            "Count already conducted"
        );

        singleChoiceProposal storage p = SingleChoiceProposals[_id];
        if (
            SingleChoiceProposals[_id].votesDown <
            SingleChoiceProposals[_id].votesUp
        ) {
            p.passed = true;
        }
        p.countConducted = true;
        // emit proposalCount(_id, p.passed);
    }

    function executeProposal(
        uint256 _id
    ) public onlyAdmin returns (bytes4, bool) {
        singleChoiceProposal storage p = SingleChoiceProposals[_id];

        (bool success, bytes memory returnData) = executionContractAddress.call(
            abi.encodeWithSignature(p.callData)
        );
        return (bytes4(returnData), success);
    }
}
