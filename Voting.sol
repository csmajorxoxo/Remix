// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        string party;
        uint voteCount;
    }
    
    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;
    uint public candidatesCount;
    
    address public admin;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender; // Admin is the contract deployer
    }

    function addCandidate(string memory _name, string memory _party) public onlyAdmin {
        candidates[candidatesCount] = Candidate(_name, _party, 0);
        candidatesCount++;
    }

    function removeCandidate(uint _index) public onlyAdmin {
        delete candidates[_index];
    }

    function vote(uint _candidateIndex) public {
        require(!hasVoted[msg.sender], "You have already voted");
        candidates[_candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getCandidate(uint _index) public view returns (string memory, string memory, uint) {
        Candidate memory candidate = candidates[_index];
        return (candidate.name, candidate.party, candidate.voteCount);
    }
    function displayAllCandidates() public view returns(string[] memory names, string[] memory parties, uint[] memory voteCounts){
        require(candidatesCount > 0,"No Candidates to Display");
        
        // Initialize arrays with the correct size
        names = new string[](candidatesCount); 
        parties = new string[](candidatesCount);
        voteCounts= new uint[](candidatesCount);

       for(uint i; i < candidatesCount;i++){
           Candidate storage candidate=candidates[i];
            names[i]=candidate.name;
            parties[i] = candidate.party;
            voteCounts[i] = candidate.voteCount;

       }
    return(names,parties,voteCounts);
}

    function totalCandidates() public view returns (uint) {
        return candidatesCount;
    }
}
