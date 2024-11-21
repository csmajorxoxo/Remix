// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance {
    // State variables
    address public insurer; // Admin (Insurance company)
    uint public totalPolicies;
    uint public totalClaims;

    struct Policy {
        uint policyId;
        address policyHolder;
        uint premium; // Premium amount in Wei
        uint coverageAmount; // Coverage amount in Wei
        uint expirationDate; // Expiry timestamp
        bool isActive;
    }

    struct Claim {
        uint claimId;
        uint policyId;
        address claimant;
        uint claimAmount;
        bool approved;
        bool paidOut;
    }

    mapping(uint => Policy) public policies; // Mapping of policy ID to Policy
    mapping(uint => Claim) public claims; // Mapping of claim ID to Claim

    // Events
    event PolicyCreated(uint policyId, address policyHolder, uint premium, uint coverageAmount, uint expirationDate);
    event ClaimFiled(uint claimId, uint policyId, address claimant, uint claimAmount);
    event ClaimApproved(uint claimId);
    event PayoutIssued(uint claimId, uint amount);

    // Constructor
    constructor() {
        insurer = msg.sender; // Assign deployer as the insurer
    }

    // Modifier to restrict access to the insurer
    modifier onlyInsurer() {
        require(msg.sender == insurer, "Only the insurer can perform this action.");
        _;
    }

    // Modifier to ensure policy exists
    modifier policyExists(uint _policyId) {
        require(policies[_policyId].policyHolder != address(0), "Policy does not exist.");
        _;
    }

    // Function to create a new insurance policy
    function createPolicy(address _policyHolder, uint _premium, uint _coverageAmount, uint _durationInDays) public onlyInsurer {
        require(_premium > 0, "Premium must be greater than zero.");
        require(_coverageAmount > 0, "Coverage amount must be greater than zero.");

        uint policyId = totalPolicies++;
        uint expirationDate = block.timestamp + (_durationInDays * 1 days);

        policies[policyId] = Policy(policyId, _policyHolder, _premium, _coverageAmount, expirationDate, true);

        emit PolicyCreated(policyId, _policyHolder, _premium, _coverageAmount, expirationDate);
    }

    // Function for policyholders to pay their premium
    function payPremium(uint _policyId) public payable policyExists(_policyId) {
        Policy storage policy = policies[_policyId];
        require(msg.sender == policy.policyHolder, "You are not the policyholder.");
        require(policy.isActive, "Policy is no longer active.");
        require(msg.value == policy.premium, "Incorrect premium amount.");
    }

    // Function to file a claim
    function fileClaim(uint _policyId, uint _claimAmount) public policyExists(_policyId) {
        Policy storage policy = policies[_policyId];
        require(msg.sender == policy.policyHolder, "You are not the policyholder.");
        require(policy.isActive, "Policy is no longer active.");
        require(block.timestamp <= policy.expirationDate, "Policy has expired.");
        require(_claimAmount <= policy.coverageAmount, "Claim amount exceeds coverage.");

        uint claimId = totalClaims++;
        claims[claimId] = Claim(claimId, _policyId, msg.sender, _claimAmount, false, false);

        emit ClaimFiled(claimId, _policyId, msg.sender, _claimAmount);
    }

    // Function to approve a claim
    function approveClaim(uint _claimId) public onlyInsurer {
        Claim storage claim = claims[_claimId];
        require(!claim.approved, "Claim already approved.");
        require(!claim.paidOut, "Claim already paid out.");

        claim.approved = true;

        emit ClaimApproved(_claimId);
    }

    // Function to issue a payout for an approved claim
    function issuePayout(uint _claimId) public onlyInsurer {
        Claim storage claim = claims[_claimId];
        require(claim.approved, "Claim is not approved.");
        require(!claim.paidOut, "Payout already issued.");

        Policy storage policy = policies[claim.policyId];
        require(address(this).balance >= claim.claimAmount, "Insufficient contract balance.");

        claim.paidOut = true;
        policy.coverageAmount -= claim.claimAmount;

        payable(claim.claimant).transfer(claim.claimAmount);

        emit PayoutIssued(_claimId, claim.claimAmount);
    }

    // Payable function to deposit funds into the contract
    function depositFunds() public payable onlyInsurer {
        require(msg.value > 0, "Deposit amount must be greater than zero.");
    }

    // Function to get policy details
    function getPolicyDetails(uint _policyId) public view returns (address, uint, uint, uint, bool) {
        Policy memory policy = policies[_policyId];
        return (policy.policyHolder, policy.premium, policy.coverageAmount, policy.expirationDate, policy.isActive);
    }

    // Function to get claim details
    function getClaimDetails(uint _claimId) public view returns (uint, address, uint, bool, bool) {
        Claim memory claim = claims[_claimId];
        return (claim.policyId, claim.claimant, claim.claimAmount, claim.approved, claim.paidOut);
    }
}