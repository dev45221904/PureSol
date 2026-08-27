// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Decentralized Voting System with Smart Contracts
/// @notice Chairperson deploys, authorizes voters, creates proposals; voters cast one vote each.
contract VotingSystem {
    struct Voter {
        bool authorized;
        bool voted;
        uint256 vote; // index of proposal voted for
    }

    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    bool public votingOpen;

    event VoterAuthorized(address indexed voter);
    event ProposalAdded(uint256 indexed proposalIndex, bytes32 name);
    event VoteCasted(address indexed voter, uint256 indexed proposalIndex);
    event VotingClosed();

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call this");
        _;
    }

    modifier votingIsOpen() {
        require(votingOpen, "Voting is not open");
        _;
    }

    /// @param proposalNames Initial list of proposal names (bytes32, e.g. via keccak or short strings)
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].authorized = true;

        for (uint256 i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({name: proposalNames[i], voteCount: 0}));
            emit ProposalAdded(i, proposalNames[i]);
        }

        votingOpen = true;
    }

    /// @notice Chairperson authorizes an address to vote.
    function giveRightToVote(address voter) external onlyChairperson {
        require(!voters[voter].authorized, "Voter already authorized");
        require(!voters[voter].voted, "Voter already voted");
        voters[voter].authorized = true;
        emit VoterAuthorized(voter);
    }

    /// @notice Chairperson can add a new proposal before/during voting.
    function addProposal(bytes32 name) external onlyChairperson {
        proposals.push(Proposal({name: name, voteCount: 0}));
        emit ProposalAdded(proposals.length - 1, name);
    }

    /// @notice Cast a vote for a given proposal index. One vote per authorized address.
    function castVote(uint256 proposalIndex) external votingIsOpen {
        Voter storage sender = voters[msg.sender];

        // --- Checks ---
        require(sender.authorized, "Not authorized to vote");
        require(!sender.voted, "Already voted");
        require(proposalIndex < proposals.length, "Invalid proposal index");

        // --- Effects (state updated before external interaction, prevents re-entrancy) ---
        sender.voted = true;
        sender.vote = proposalIndex;

        // --- Interactions ---
        proposals[proposalIndex].voteCount += 1;

        emit VoteCasted(msg.sender, proposalIndex);
    }

    /// @notice Chairperson closes voting permanently.
    function closeVoting() external onlyChairperson votingIsOpen {
        votingOpen = false;
        emit VotingClosed();
    }

    /// @notice Returns the index of the proposal with the most votes, computed dynamically.
    function winningProposal() public view returns (uint256 winningIndex) {
        uint256 winningVoteCount = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningIndex = i;
            }
        }
    }

    /// @notice Returns the name of the winning proposal.
    function winnerName() external view returns (bytes32) {
        return proposals[winningProposal()].name;
    }

    /// @notice Returns the total number of proposals.
    function proposalsCount() external view returns (uint256) {
        return proposals.length;
    }

    /// @notice Returns full details of a proposal by index.
    function getProposal(uint256 index) external view returns (bytes32 name, uint256 voteCount) {
        require(index < proposals.length, "Invalid proposal index");
        Proposal storage p = proposals[index];
        return (p.name, p.voteCount);
    }
}
